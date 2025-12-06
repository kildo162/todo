#!/usr/bin/env bash
set -euo pipefail

# generate.sh - Generate Go code from proto definitions
# Usage: ./generate.sh [--with-gateway]

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

PROTO_DIR="./proto"
OUT_DIR="$PROTO_DIR"

echo "Generating proto files in: $PROTO_DIR -> $OUT_DIR"

if ! command -v protoc >/dev/null 2>&1; then
  echo "protoc not found. Please install protoc: https://grpc.io/docs/protoc-installation/"
  exit 1
fi

GOBIN=$(go env GOBIN 2>/dev/null || true)
if [[ -z "$GOBIN" ]]; then
  GOPATH=$(go env GOPATH)
  GOBIN="$GOPATH/bin"
fi
export PATH="$GOBIN:$PATH"

install_plugin_if_missing() {
  local pkg=$1
  local bin=$2
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "Installing $pkg..."
    go install "$pkg" || { echo "Failed to install $pkg"; exit 1; }
  fi
}

install_plugin_if_missing "google.golang.org/protobuf/cmd/protoc-gen-go@latest" "protoc-gen-go"
install_plugin_if_missing "google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest" "protoc-gen-go-grpc"

WITH_GATEWAY=false
if [[ "${1:-}" == "--with-gateway" ]]; then
  WITH_GATEWAY=true
  install_plugin_if_missing "github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest" "protoc-gen-grpc-gateway"
  install_plugin_if_missing "github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest" "protoc-gen-openapiv2"
fi

echo "Using protoc: $(protoc --version)"
echo "Using PATH: $PATH"

PROTO_FILES=($PROTO_DIR/*.proto)
if [[ ${#PROTO_FILES[@]} -eq 0 ]]; then
  echo "No proto files found in $PROTO_DIR"
  exit 1
fi

for f in "${PROTO_FILES[@]}"; do
  echo "Generating: $f"
  protoc -I "$PROTO_DIR" \
    --go_out=paths=source_relative:"$OUT_DIR" \
    --go-grpc_out=paths=source_relative:"$OUT_DIR" \
    "$f"

  if $WITH_GATEWAY; then
    protoc -I "$PROTO_DIR" \
      --grpc-gateway_out=paths=source_relative,logtostderr=true:"$OUT_DIR" \
      --openapiv2_out=allow_merge=true,merge_file_name=api:"$OUT_DIR" \
      "$f"
  fi
done

echo "Running go fmt..."
gofmt -w .

echo "Done. Generated protobuf Go files are in: $OUT_DIR"
echo "Tip: run 'go mod tidy' if you change proto options or add grpc gateway support."

exit 0
