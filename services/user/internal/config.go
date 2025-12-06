package internal

import (
	"log"
	"os"
)

// Config holds application configuration
type Config struct {
	DBPath           string
	JWTSecret        string
	ListenAddr       string
	DiscoveryEnabled bool
	DiscoveryAddr    string
}

func NewConfigFromEnv() *Config {
	db := os.Getenv("USER_DB_PATH")
	if db == "" {
		db = "./data/user.db"
	}
	jwt := os.Getenv("JWT_SECRET")
	if jwt == "" {
		jwt = "dev-secret"
	}
	addr := os.Getenv("USER_LISTEN_ADDR")
	if addr == "" {
		addr = ":8081"
	}
	disc := os.Getenv("DISCOVERY_ENABLED")
	if disc == "" {
		disc = "true"
	}
	discoveryEnabled := false
	if disc == "true" || disc == "1" || disc == "yes" {
		discoveryEnabled = true
	}
	discAddr := os.Getenv("DISCOVERY_ADDR")
	if discAddr == "" {
		discAddr = "239.255.255.250:9999"
	}
	log.Printf("config: DBPath=%s, Listen=%s", db, addr)
	return &Config{DBPath: db, JWTSecret: jwt, ListenAddr: addr, DiscoveryEnabled: discoveryEnabled, DiscoveryAddr: discAddr}
}
