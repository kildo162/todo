package models

import (
	"time"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// User is the main user model
type User struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`

	Email    string `gorm:"uniqueIndex;size:255" json:"email"`
	Password string `json:"-"`
	FullName string `json:"full_name"`
}

func (u *User) SetPassword(raw string) error {
	h, err := bcrypt.GenerateFromPassword([]byte(raw), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	u.Password = string(h)
	return nil
}

func (u *User) CheckPassword(raw string) bool {
	if err := bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(raw)); err != nil {
		return false
	}
	return true
}

// Role represents a role like admin/user
type Role struct {
	ID   uint   `gorm:"primaryKey" json:"id"`
	Name string `gorm:"uniqueIndex;size:100" json:"name"`
}

// UserRole join table
type UserRole struct {
	ID     uint `gorm:"primaryKey" json:"id"`
	UserID uint `gorm:"index"`
	RoleID uint `gorm:"index"`
}
