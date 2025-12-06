FROM golang:1.24.11-alpine
WORKDIR /app
ENV USER_LISTEN_ADDR=:8443
ENV DISCOVERY_ENABLED=true

# Ensure we cache module downloads during build
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the app and build binary
COPY . .
ENV CGO_ENABLED=1
RUN apk add --no-cache build-base sqlite-dev
RUN go build -o user-service ./cmd/user-service
EXPOSE 8443
CMD ["/app/user-service"]
