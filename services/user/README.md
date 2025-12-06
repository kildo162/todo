# User Service (Go)

This service provides user management and role-based authorization for the TODO app.

Features:
- SQLite database via GORM
- JWT authentication
- Role-based middleware supporting at least `admin` and `user`
- REST API for user CRUD, login, and role assignment
- Protobuf definitions for messages

# Run:
```bash
cd services/user
# Requires Go 1.24+
go run ./cmd/user-service
```

Notes:
- The service stores SQLite DB in `./data/user.db` by default.
- JWT secret is read from environment variable `JWT_SECRET`.

Examples:

Register user:
```
curl -X POST http://localhost:8081/auth/register -H 'Content-Type: application/json' -d '{"email":"user1@local","password":"pass","full_name":"User One"}'
```

Login:
```
curl -X POST http://localhost:8081/auth/login -H 'Content-Type: application/json' -d '{"email":"user1@local","password":"pass"}'
```

Admin actions (assign role, list users) require an admin token (default admin@local/admin):
```
# get admin token
TOKEN=$(curl -s -X POST http://localhost:8081/auth/login -H 'Content-Type: application/json' -d '{"email":"admin@local","password":"admin"}' | jq -r '.token')

# assign role
curl -X POST http://localhost:8081/api/users/2/roles -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -d '{"role_name":"admin"}'
```

Protobuf:
 - The `proto/user.proto` file includes the messages used by the service. Use `protoc` to generate stubs if needed (not required to run the REST API).

Generating code from proto:
 - A helper script `generate.sh` is provided to generate Go code for the proto definitions and optional grpc-gateway/OpenAPI. It will also install `protoc-gen-go` and `protoc-gen-go-grpc` plugins if missing.
 - Prerequisites: `protoc`, `go` toolchain (Go >=1.20). Ensure `$(go env GOBIN)` or `$(go env GOPATH)/bin` is in your PATH so `go install`ed plugins are available.

Usage:
```
# Run go generate for proto files
cd services/user
./generate.sh

# Generate also grpc-gateway/OpenAPI
./generate.sh --with-gateway
```

Troubleshooting:
 - If you receive "protoc not found" please install protoc manually: https://grpc.io/docs/protoc-installation/
 - If plugin binaries are installed but not found, add your $(go env GOPATH)/bin to PATH.

Discovery (mobile app LAN detection):
 - The service supports a simple UDP multicast discovery mechanism. If a mobile app is on the same LAN, it can send a UDP packet with the content `DISCOVER_USER_SERVICE` to the multicast address (default `239.255.255.250:9999`) and the service will reply with JSON containing the local service IP and port.
 - Enable/Disable discovery with these env vars:
	 - `DISCOVERY_ENABLED` (true/false: default true)
	 - `DISCOVERY_ADDR` (multicast address; default `239.255.255.250:9999`)

Dart / Flutter example (UDP) to detect LAN service:
```dart
import 'dart:convert';
import 'dart:io';

Future<void> discover() async {
	final RawDatagramSocket socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
	final message = utf8.encode('DISCOVER_USER_SERVICE');
	final address = InternetAddress('239.255.255.250');
	const port = 9999;
	socket.send(message, address, port);

	// Wait for replies
	socket.timeout(const Duration(seconds: 2)).listen((event) {
		if (event == RawSocketEvent.read) {
			final dg = socket.receive();
			if (dg != null) {
				final data = utf8.decode(dg.data);
				print('found service: $data');
			}
		}
	}).onDone(() => socket.close());
}
```

From mobile app perspective:
 - Try discovery first. If you receive a response, use its `addr:port` directly (connect over LAN).
 - If no response, fallback to public domain `https://api.khanhnd.com`.

Logs:
 - The service logs important lifecycle, DB migration, and request events to stdout. You can run the service in foreground to see logs:
```
cd services/user
./user-service
```
 - Logs contain timestamps and include info like GORM SQL queries, request auth attempts, user/register/login actions, and role changes.
 - In production, configure your logging and security settings (e.g., hide sensitive info, use JSON structured logs, or integrate with a logging backend).

## Deploy to a remote server

This repository includes a deploy helper script `deploy_to_server.sh` which packages the `services/user` folder and deploys it to a remote host, then runs `docker compose up -d --build` on that host.

Prerequisites on remote host:
- Linux host with `docker` and `docker compose` (or `docker-compose`) installed
- The remote user `khanhnd` should have permission to run docker (either via sudo or group membership)

From your local workstation, run:
```bash
cd services/user
chmod +x deploy_to_server.sh
./deploy_to_server.sh -h 192.168.1.100 -u khanhnd -p '1'
```

Notes:
- Using `-p` with a password is insecure—prefer SSH keys configured for the `khanhnd` user.
- If docker or docker-compose isn't installed on the remote machine, you must install them first. The script will check and fail with a message if they are missing.
- The script will copy the project (excluding the `data` directory) to `~/user-service` on the remote host and then do a `docker compose up -d --build` there.

Firewall:
- Ensure TCP/8443 is reachable from desired clients. Discovery requires UDP multicast on `239.255.255.250:9999` to reply to LAN clients.
