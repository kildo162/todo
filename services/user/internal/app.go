package internal

import (
	"context"
	"log"
	"net"
	"net/http"
	"os"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/rs/cors"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"

	"services/user/internal/auth"
	"services/user/internal/discovery"
	"services/user/internal/handlers"
	"services/user/internal/models"
	"services/user/internal/store"
)

// App encapsulates the web server and dependencies
type App struct {
	cfg  *Config
	http *http.Server
	db   *gorm.DB
	ln   net.Listener
}

func NewApp(cfg *Config) (*App, error) {
	if err := os.MkdirAll("./data", 0755); err != nil {
		return nil, err
	}
	db, err := gorm.Open(sqlite.Open(cfg.DBPath), &gorm.Config{Logger: logger.Default.LogMode(logger.Info)})
	if err != nil {
		return nil, err
	}
	// perform auto-migrations
	if err := db.AutoMigrate(&models.User{}, &models.Role{}, &models.UserRole{}); err != nil {
		log.Printf("error running auto-migration: %v", err)
		return nil, err
	}
	log.Printf("database migrated, path=%s", cfg.DBPath)

	repo := store.NewStore(db)
	jwtManager := auth.NewJWTManager(cfg.JWTSecret)
	h := handlers.NewHandler(repo, jwtManager)
	// Ensure a default admin user exists
	if u, err := repo.GetUserByEmail("admin@local"); err != nil {
		log.Printf("default admin not found, creating admin=admin@local")
		admin := &models.User{Email: "admin@local", FullName: "Administrator"}
		admin.SetPassword("admin")
		if err := repo.CreateUser(admin); err != nil {
			log.Printf("failed to create default admin: %v", err)
		} else {
			log.Printf("default admin created: id=%d", admin.ID)
		}
		// ensure admin role exists
		if _, err := repo.GetRoleByName("admin"); err != nil {
			repo.CreateRole(&models.Role{Name: "admin"})
		}
		if r, _ := repo.GetRoleByName("admin"); r != nil {
			if err := repo.AssignRoleToUser(admin.ID, r.ID); err != nil {
				log.Printf("failed to assign admin role to default admin: %v", err)
			} else {
				log.Printf("assigned admin role to default admin id=%d", admin.ID)
			}
		}
	} else {
		log.Printf("default admin exists: id=%d, email=%s", u.ID, u.Email)
	}

	r := chi.NewRouter()
	log.Printf("registering routes and middleware")
	r.Use(middleware.Logger)
	// allow CORS for development (adjust as needed in production)
	c := cors.New(cors.Options{AllowCredentials: true, AllowedOrigins: []string{"*"}, AllowedMethods: []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}, AllowedHeaders: []string{"*"}})
	r.Use(c.Handler)
	// public endpoints
	r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("ok"))
	})
	log.Printf("registered route GET /health")

	// auth
	r.Post("/auth/register", h.Register)
	r.Post("/auth/login", h.Login)
	log.Printf("registered routes POST /auth/register, POST /auth/login")

	// apply auth middleware
	r.Route("/api", func(r chi.Router) {
		r.Use(handlers.AuthMiddleware(jwtManager))
		r.Get("/users", h.ListUsers)
		r.Get("/users/{id}", h.GetUser)
		r.Put("/users/{id}", h.UpdateUser)
		r.Delete("/users/{id}", h.DeleteUser)
		r.Post("/roles", h.CreateRole)
		r.Post("/users/{id}/roles", h.AssignRole)
	})
	log.Printf("registered /api endpoints (users, roles)")

	hs := &http.Server{
		Addr:    cfg.ListenAddr,
		Handler: r,
	}
	log.Printf("configured http server on %s", cfg.ListenAddr)
	// Start multicast discovery responder if enabled
	if cfg.DiscoveryEnabled {
		// try to determine port
		port := 8081
		if strings.Contains(cfg.ListenAddr, ":") {
			host, p, err := net.SplitHostPort(cfg.ListenAddr)
			if err == nil && p != "" {
				if n, pe := strconv.Atoi(p); pe == nil {
					port = n
				}
			} else if strings.HasPrefix(cfg.ListenAddr, ":") {
				// built like :8081
				p := strings.TrimPrefix(cfg.ListenAddr, ":")
				if n, pe := strconv.Atoi(p); pe == nil {
					port = n
				}
			} else if host != "" {
				// if host includes port
				if n, pe := strconv.Atoi(host); pe == nil {
					port = n
				}
			}
		}
		// background discovery responder
		ctx := context.Background()
		discovery.StartDiscovery(ctx, discovery.Options{MulticastAddr: cfg.DiscoveryAddr, ServiceName: "user-service", ServicePort: port, Enabled: cfg.DiscoveryEnabled})
	}

	return &App{cfg: cfg, http: hs, db: db}, nil
}

func (a *App) ListenAndServe() error {
	// create a network listener so we can get the real bound address (and port)
	ln, err := net.Listen("tcp", a.cfg.ListenAddr)
	if err != nil {
		return err
	}
	a.ln = ln
	// Log the actual listener address and list accessible IPs with bound port
	addr := ln.Addr().String()
	log.Printf("listening on %s", addr)
	// attempt to print reachable IPs on local interfaces for the same port
	if tcpAddr, ok := ln.Addr().(*net.TCPAddr); ok {
		port := tcpAddr.Port
		addrs := getLocalIPv4Addresses()
		for _, ip := range addrs {
			log.Printf("accessible via: %s:%d", ip, port)
		}
	}
	return a.http.Serve(ln)
}

func (a *App) Shutdown(ctx context.Context) error {
	if a.ln != nil {
		_ = a.ln.Close()
	}
	return a.http.Shutdown(ctx)
}

// getLocalIPv4Addresses returns a list of non-empty IPv4 addresses from local interfaces
func getLocalIPv4Addresses() []string {
	var ips []string
	ifs, err := net.Interfaces()
	if err != nil {
		return ips
	}
	for _, iface := range ifs {
		if (iface.Flags & net.FlagUp) == 0 {
			continue
		}
		addrs, _ := iface.Addrs()
		for _, a := range addrs {
			switch v := a.(type) {
			case *net.IPNet:
				ip := v.IP
				if ip == nil || ip.To4() == nil {
					continue
				}
				ips = append(ips, ip.String())
			case *net.IPAddr:
				ip := v.IP
				if ip == nil || ip.To4() == nil {
					continue
				}
				ips = append(ips, ip.String())
			}
		}
	}
	return ips
}
