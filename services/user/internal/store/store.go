package store

import (
	"errors"

	"services/user/internal/models"

	"gorm.io/gorm"
)

var (
	ErrNotFound = errors.New("record not found")
)

type Store struct {
	db *gorm.DB
}

func NewStore(db *gorm.DB) *Store {
	return &Store{db: db}
}

func (s *Store) CreateUser(u *models.User) error {
	return s.db.Create(u).Error
}

func (s *Store) GetUserByID(id uint) (*models.User, error) {
	var u models.User
	if err := s.db.First(&u, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	return &u, nil
}

func (s *Store) GetUserByEmail(email string) (*models.User, error) {
	var u models.User
	if err := s.db.Where("email = ?", email).First(&u).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	return &u, nil
}

func (s *Store) ListUsers() ([]models.User, error) {
	var us []models.User
	if err := s.db.Find(&us).Error; err != nil {
		return nil, err
	}
	return us, nil
}

func (s *Store) UpdateUser(u *models.User) error {
	return s.db.Save(u).Error
}

func (s *Store) DeleteUser(id uint) error {
	return s.db.Delete(&models.User{}, id).Error
}

func (s *Store) CreateRole(r *models.Role) error {
	return s.db.Create(r).Error
}

func (s *Store) GetRoleByName(name string) (*models.Role, error) {
	var r models.Role
	if err := s.db.Where("name = ?", name).First(&r).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	return &r, nil
}

func (s *Store) AssignRoleToUser(userID, roleID uint) error {
	ur := models.UserRole{UserID: userID, RoleID: roleID}
	return s.db.Create(&ur).Error
}

func (s *Store) GetUserRoles(userID uint) ([]models.Role, error) {
	var roles []models.Role
	if err := s.db.Table("roles").Select("roles.*").Joins("join user_roles on user_roles.role_id = roles.id").Where("user_roles.user_id = ?", userID).Scan(&roles).Error; err != nil {
		return nil, err
	}
	return roles, nil
}
