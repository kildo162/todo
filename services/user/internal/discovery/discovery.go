package discovery

import (
	"context"
	"encoding/json"
	"log"
	"net"
	"strings"
	"time"
)

// Message used to discover the user service
const DiscoverMsg = "DISCOVER_USER_SERVICE"

type Options struct {
	MulticastAddr string // e.g., 239.255.255.250:9999
	ServiceName   string
	ServicePort   int
	Enabled       bool
}

type Response struct {
	Service string `json:"service"`
	Addr    string `json:"addr"`
	Port    int    `json:"port"`
	When    int64  `json:"when"`
}

// StartDiscovery listens for multicast discovery messages and replies with service info.
// It runs in a background goroutine and stops when ctx is cancelled.
func StartDiscovery(ctx context.Context, opts Options) error {
	if !opts.Enabled {
		log.Printf("discovery disabled")
		return nil
	}
	if opts.MulticastAddr == "" {
		opts.MulticastAddr = "239.255.255.250:9999"
	}
	if opts.ServiceName == "" {
		opts.ServiceName = "user-service"
	}
	if opts.ServicePort == 0 {
		opts.ServicePort = 8081
	}

	go func() {
		log.Printf("starting discovery responder on %s", opts.MulticastAddr)
		// Bind to all interfaces on the multicast port
		addr, err := net.ResolveUDPAddr("udp", opts.MulticastAddr)
		if err != nil {
			log.Printf("discovery: invalid multicast addr: %v", err)
			return
		}
		conn, err := net.ListenMulticastUDP("udp", nil, addr)
		if err != nil {
			log.Printf("discovery: failed to listen multicast: %v", err)
			return
		}
		defer conn.Close()
		conn.SetReadBuffer(2048)
		// loop and respond
		buf := make([]byte, 2048)
		for {
			select {
			case <-ctx.Done():
				log.Printf("discovery responder shutting down")
				return
			default:
			}
			conn.SetReadDeadline(time.Now().Add(2 * time.Second))
			n, src, err := conn.ReadFromUDP(buf)
			if err != nil {
				if ne, ok := err.(net.Error); ok && ne.Timeout() {
					continue
				}
				log.Printf("discovery: read error: %v", err)
				continue
			}
			msg := strings.TrimSpace(string(buf[:n]))
			if msg != DiscoverMsg {
				continue
			}
			// Build response
			// determine local address to reach back to the src (try via src IP)
			respAddr := ""
			// Get a reasonable local IP to respond with (use src's IP if possible)
			if src != nil {
				// Establish a UDP connection to src and get local addr
				tmpConn, err := net.DialUDP("udp", nil, src)
				if err == nil {
					local := tmpConn.LocalAddr()
					if la, ok := local.(*net.UDPAddr); ok {
						respAddr = la.IP.String()
					}
					tmpConn.Close()
				}
			}
			if respAddr == "" {
				respAddr = "127.0.0.1"
			}
			r := Response{Service: opts.ServiceName, Addr: respAddr, Port: opts.ServicePort, When: time.Now().Unix()}
			data, _ := json.Marshal(r)
			// send response back to src
			dst := &net.UDPAddr{IP: src.IP, Port: src.Port}
			dconn, err := net.DialUDP("udp", nil, dst)
			if err != nil {
				log.Printf("discovery: error dialing back to %v: %v", dst, err)
				continue
			}
			_, err = dconn.Write([]byte(data))
			if err != nil {
				log.Printf("discovery: failed to write response to %v: %v", dst, err)
			}
			dconn.Close()
			log.Printf("discovery: responded to %v with addr %s:%d", src, respAddr, opts.ServicePort)
		}
	}()
	return nil
}

// QueryDiscovery sends a multicast query and returns a Response from the first responder.
func QueryDiscovery(multicastAddr string, timeout time.Duration) (*Response, error) {
	if multicastAddr == "" {
		multicastAddr = "239.255.255.250:9999"
	}
	addr, err := net.ResolveUDPAddr("udp", multicastAddr)
	if err != nil {
		return nil, err
	}
	// open a single UDP socket bound to an ephemeral local port; send and receive on it
	laddr, err := net.ResolveUDPAddr("udp", ":0")
	if err != nil {
		return nil, err
	}
	lconn, err := net.ListenUDP("udp", laddr)
	if err != nil {
		return nil, err
	}
	defer lconn.Close()
	if _, err := net.ResolveUDPAddr("udp", multicastAddr); err != nil {
		return nil, err
	}
	// send DISCOVER_USER_SERVICE using same local socket
	if _, err := lconn.WriteToUDP([]byte(DiscoverMsg), addr); err != nil {
		return nil, err
	}
	lconn.SetReadDeadline(time.Now().Add(timeout))
	buf := make([]byte, 2048)
	n, _, err := lconn.ReadFromUDP(buf)
	if err != nil {
		return nil, err
	}
	var r Response
	if err := json.Unmarshal(buf[:n], &r); err != nil {
		return nil, err
	}
	return &r, nil
}
