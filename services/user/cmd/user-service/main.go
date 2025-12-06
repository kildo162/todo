package main

import (
	"log"

	"services/user/internal"
)

func main() {
	log.SetFlags(log.LstdFlags | log.Lmicroseconds | log.LUTC)
	cfg := internal.NewConfigFromEnv()
	app, err := internal.NewApp(cfg)
	if err != nil {
		log.Fatalf("failed to create app: %v", err)
	}
	log.Printf("user-service starting on %s", cfg.ListenAddr)
	if err := app.ListenAndServe(); err != nil {
		log.Fatalf("server exited: %v", err)
	}
}
