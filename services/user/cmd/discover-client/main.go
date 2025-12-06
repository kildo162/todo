package main

import (
	"fmt"
	"log"
	"services/user/internal/discovery"
	"time"
)

func main() {
	res, err := discovery.QueryDiscovery("", 2*time.Second)
	if err != nil {
		log.Fatalf("discovery query failed: %v", err)
	}
	fmt.Printf("found: service=%s addr=%s port=%d when=%d\n", res.Service, res.Addr, res.Port, res.When)
}
