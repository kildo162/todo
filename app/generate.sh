#!/usr/bin/env bash
set -euo pipefail

# generate.sh - Generate Dart protobuf models from backend proto files
# Usage: cd app && ./generate.sh

PROTO_DIR="../services/user/proto"
OUT_DIR="lib/src/proto"

mkdir -p "$OUT_DIR"

# Detect protoc
if ! command -v protoc >/dev/null 2>&1; then
  echo "protoc not found. Please install protoc (https://grpc.io/docs/protoc-installation/)."
  exit 1
fi

# Ensure dart protobuf plugin is available
if ! command -v protoc-gen-dart >/dev/null 2>&1; then
  echo "protoc-gen-dart not found. Installing using 'dart pub global activate protoc_plugin'"
  dart pub global activate protoc_plugin
  export PATH="$(dart pub global list | awk '/protoc_plugin/ {print (split($0,a,":")[1])}'):$PATH" || true
fi

# Try to activate grpc plugin for dart (protoc-gen-grpc-dart)
if ! command -v protoc-gen-grpc-dart >/dev/null 2>&1; then
  echo "protoc-gen-grpc-dart not found. Installing grpc plugin to generate gRPC Dart stubs"
  dart pub global activate protoc_plugin # includes protoc-gen-dart
  # grpc plugin installation may vary: ensure `protoc-gen-grpc-dart` is in PATH
  if ! command -v protoc-gen-grpc-dart >/dev/null 2>&1; then
    echo "Could not find protoc-gen-grpc-dart on PATH. Continuing without grpc stubs. It's optional for REST usage."
  fi
fi

# Generate Dart protos (messages only, no gRPC if plugin missing)
for p in "$PROTO_DIR"/*.proto; do
  echo "Generating Dart types for $p"
  if command -v protoc-gen-grpc-dart >/dev/null 2>&1; then
    protoc --dart_out=grpc:$OUT_DIR -I="$PROTO_DIR" "$p"
  else
    protoc --dart_out=$OUT_DIR -I="$PROTO_DIR" "$p"
  fi
done

# Add formatting
if command -v dart >/dev/null 2>&1; then
  dart format "$OUT_DIR"
fi

echo "Done. Generated Dart proto files are available under $OUT_DIR"
