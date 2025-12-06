#!/usr/bin/env bash
set -euo pipefail

# Run user-service locally
cd "$(dirname "$0")"

export JWT_SECRET=${JWT_SECRET:-dev-secret}
export USER_DB_PATH=${USER_DB_PATH:-./data/user.db}
export USER_LISTEN_ADDR=${USER_LISTEN_ADDR:-:8443}

mkdir -p data

go run ./cmd/user-service
