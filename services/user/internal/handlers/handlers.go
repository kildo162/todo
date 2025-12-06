package handlers

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"

	"services/user/internal/auth"
	"services/user/internal/models"
	"services/user/internal/store"
)

type Handler struct {
	store *store.Store
	jwt   *auth.JWTManager
}

func NewHandler(s *store.Store, jwt *auth.JWTManager) *Handler {
	return &Handler{store: s, jwt: jwt}
}

func writeJSON(w http.ResponseWriter, code int, v interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, code int, msg string) {
	writeJSON(w, code, map[string]string{"error": msg})
}

func parseBody(r *http.Request, v interface{}) error {
	return json.NewDecoder(r.Body).Decode(v)
}

// Register request
type RegisterRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
	FullName string `json:"full_name"`
}

func (h *Handler) Register(w http.ResponseWriter, r *http.Request) {
	var req RegisterRequest
	if err := parseBody(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid payload")
		return
	}
	log.Printf("register attempt: email=%s, remote=%s", req.Email, r.RemoteAddr)
	u := &models.User{Email: strings.TrimSpace(req.Email), FullName: req.FullName}
	if err := u.SetPassword(req.Password); err != nil {
		writeError(w, http.StatusInternalServerError, "failed to set password")
		return
	}
	if err := h.store.CreateUser(u); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	// assign default role
	role, err := h.store.GetRoleByName("user")
	if err != nil {
		// create role
		roleObj := &models.Role{Name: "user"}
		h.store.CreateRole(roleObj)
		role, _ = h.store.GetRoleByName("user")
	}
	h.store.AssignRoleToUser(u.ID, role.ID)
	writeJSON(w, http.StatusCreated, map[string]interface{}{"id": u.ID, "email": u.Email})
	log.Printf("register success: userID=%d, email=%s, remote=%s", u.ID, u.Email, r.RemoteAddr)
}

// Login
type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func (h *Handler) Login(w http.ResponseWriter, r *http.Request) {
	var req LoginRequest
	if err := parseBody(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid payload")
		return
	}
	log.Printf("login attempt: email=%s, remote=%s", req.Email, r.RemoteAddr)
	u, err := h.store.GetUserByEmail(strings.TrimSpace(req.Email))
	if err != nil {
		log.Printf("login failed: user not found email=%s, remote=%s", strings.TrimSpace(req.Email), r.RemoteAddr)
		writeError(w, http.StatusUnauthorized, "invalid credentials")
		return
	}
	if !u.CheckPassword(req.Password) {
		log.Printf("login failed: bad password for email=%s, remote=%s", req.Email, r.RemoteAddr)
		writeError(w, http.StatusUnauthorized, "invalid credentials")
		return
	}
	roles, _ := h.store.GetUserRoles(u.ID)
	var roleNames []string
	for _, r := range roles {
		roleNames = append(roleNames, r.Name)
	}
	token, err := h.jwt.Generate(u.ID, u.Email, roleNames)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to generate token")
		return
	}
	writeJSON(w, http.StatusOK, map[string]interface{}{"token": token, "user": map[string]interface{}{"id": u.ID, "email": u.Email, "full_name": u.FullName}})
	log.Printf("login success: userID=%d, email=%s, remote=%s", u.ID, u.Email, r.RemoteAddr)
}

// Admin check helper
func hasRole(roles []string, name string) bool {
	for _, r := range roles {
		if r == name {
			return true
		}
	}
	return false
}

// AuthMiddleware extracts the user claims and sets them in context
func AuthMiddleware(jwt *auth.JWTManager) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			auth := r.Header.Get("Authorization")
			if auth == "" {
				log.Printf("auth missing from request: remote=%s, method=%s, path=%s", r.RemoteAddr, r.Method, r.URL.Path)
				writeError(w, http.StatusUnauthorized, "missing auth")
				return
			}
			parts := strings.Split(auth, " ")
			if len(parts) != 2 || parts[0] != "Bearer" {
				log.Printf("auth malformed header: remote=%s, header=%s", r.RemoteAddr, auth)
				writeError(w, http.StatusUnauthorized, "invalid auth header")
				return
			}
			claims, err := jwt.Verify(parts[1])
			if err != nil {
				log.Printf("invalid token: remote=%s, err=%v", r.RemoteAddr, err)
				writeError(w, http.StatusUnauthorized, "invalid token")
				return
			}
			// store claims in ctx
			ctx := r.Context()
			ctx = contextWithClaims(ctx, claims)
			r = r.WithContext(ctx)
			next.ServeHTTP(w, r)
		})
	}
}

// getClaims from context
func GetClaims(r *http.Request) *auth.Claims {
	c := r.Context().Value(claimsContextKey{})
	if c == nil {
		return nil
	}
	if v, ok := c.(*auth.Claims); ok {
		return v
	}
	return nil
}

// Handler helpers for roles
func isAdmin(r *http.Request) bool {
	c := GetClaims(r)
	if c == nil {
		return false
	}
	for _, rr := range c.Roles {
		if rr == "admin" {
			return true
		}
	}
	return false
}

// ListUsers - admin only
func (h *Handler) ListUsers(w http.ResponseWriter, r *http.Request) {
	if !isAdmin(r) {
		writeError(w, http.StatusForbidden, "admin only")
		return
	}
	claims := GetClaims(r)
	if claims != nil {
		log.Printf("list users requested by userID=%d", claims.UserID)
	}
	us, err := h.store.ListUsers()
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	// attach roles
	out := make([]map[string]interface{}, 0, len(us))
	for _, u := range us {
		roles, _ := h.store.GetUserRoles(u.ID)
		var names []string
		for _, rr := range roles {
			names = append(names, rr.Name)
		}
		out = append(out, map[string]interface{}{"id": u.ID, "email": u.Email, "full_name": u.FullName, "roles": names})
	}
	writeJSON(w, http.StatusOK, out)
	log.Printf("list users returned: count=%d", len(out))
}

// GetUser
func (h *Handler) GetUser(w http.ResponseWriter, r *http.Request) {
	idStr := chi.URLParam(r, "id")
	id, _ := strconv.Atoi(idStr)
	claims := GetClaims(r)
	if !isAdmin(r) && claims.UserID != uint(id) {
		writeError(w, http.StatusForbidden, "forbidden")
		return
	}
	u, err := h.store.GetUserByID(uint(id))
	if err != nil {
		writeError(w, http.StatusNotFound, "not found")
		return
	}
	if claims != nil {
		log.Printf("get user: requestedBy=%d, target=%d", claims.UserID, id)
	}
	roles, _ := h.store.GetUserRoles(u.ID)
	var names []string
	for _, rr := range roles {
		names = append(names, rr.Name)
	}
	writeJSON(w, http.StatusOK, map[string]interface{}{"id": u.ID, "email": u.Email, "full_name": u.FullName, "roles": names})
}

// UpdateUser
type UpdateUserReq struct {
	FullName string `json:"full_name"`
	Password string `json:"password"`
}

func (h *Handler) UpdateUser(w http.ResponseWriter, r *http.Request) {
	idStr := chi.URLParam(r, "id")
	id, _ := strconv.Atoi(idStr)
	claims := GetClaims(r)
	if !isAdmin(r) && claims.UserID != uint(id) {
		writeError(w, http.StatusForbidden, "forbidden")
		return
	}
	var req UpdateUserReq
	log.Printf("update user attempt: requestedBy=%d, target=%d", claims.UserID, id)
	if err := parseBody(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid")
		return
	}
	u, err := h.store.GetUserByID(uint(id))
	if err != nil {
		writeError(w, http.StatusNotFound, "not found")
		return
	}
	if req.FullName != "" {
		u.FullName = req.FullName
	}
	if req.Password != "" {
		u.SetPassword(req.Password)
	}
	h.store.UpdateUser(u)
	writeJSON(w, http.StatusOK, map[string]interface{}{"id": u.ID, "email": u.Email})
}

// DeleteUser
func (h *Handler) DeleteUser(w http.ResponseWriter, r *http.Request) {
	if !isAdmin(r) {
		writeError(w, http.StatusForbidden, "admin only")
		return
	}
	idStr := chi.URLParam(r, "id")
	id, _ := strconv.Atoi(idStr)
	log.Printf("delete user attempt: requestedBy admin, target=%d", id)
	_ = h.store.DeleteUser(uint(id))
	log.Printf("deleted user: id=%d", id)
	writeJSON(w, http.StatusOK, map[string]string{"status": "deleted"})
}

// CreateRole
type CreateRoleReq struct {
	Name string `json:"name"`
}

func (h *Handler) CreateRole(w http.ResponseWriter, r *http.Request) {
	if !isAdmin(r) {
		writeError(w, http.StatusForbidden, "admin only")
		return
	}
	var req CreateRoleReq
	if err := parseBody(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid")
		return
	}
	claims := GetClaims(r)
	if claims != nil {
		log.Printf("create role attempt: name=%s, requestedBy=%d", req.Name, claims.UserID)
	}
	role := &models.Role{Name: req.Name}
	if err := h.store.CreateRole(role); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	if claims != nil {
		log.Printf("create role success: name=%s, requestedBy=%d", role.Name, claims.UserID)
	}
	writeJSON(w, http.StatusCreated, role)
}

// AssignRole
type AssignRoleReq struct {
	RoleName string `json:"role_name"`
}

func (h *Handler) AssignRole(w http.ResponseWriter, r *http.Request) {
	if !isAdmin(r) {
		writeError(w, http.StatusForbidden, "admin only")
		return
	}
	idStr := chi.URLParam(r, "id")
	id, _ := strconv.Atoi(idStr)
	var req AssignRoleReq
	if err := parseBody(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid")
		return
	}
	role, err := h.store.GetRoleByName(req.RoleName)
	if err != nil {
		writeError(w, http.StatusNotFound, "role not found")
		return
	}
	claims := GetClaims(r)
	if claims != nil {
		log.Printf("assign role attempt: role=%s, target=%d, requestedBy=%d", role.Name, id, claims.UserID)
	}
	if err := h.store.AssignRoleToUser(uint(id), role.ID); err != nil {
		writeError(w, http.StatusInternalServerError, "failed to assign role")
		return
	}
	if claims != nil {
		log.Printf("assign role success: role=%s, target=%d, requestedBy=%d", role.Name, id, claims.UserID)
	}
	writeJSON(w, http.StatusOK, map[string]string{"status": "assigned"})
}

// Context claims helper

type claimsContextKey struct{}

func contextWithClaims(ctx context.Context, c *auth.Claims) context.Context {
	return context.WithValue(ctx, claimsContextKey{}, c)
}
