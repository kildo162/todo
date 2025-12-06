#!/usr/bin/env bash
set -euo pipefail

# deploy_to_server.sh
# Usage: ./deploy_to_server.sh -h <host> -u <user> [-p <password>] [-d <remote_dir>] [-P <port>]
# This script copies the 'services/user' directory to the remote server and runs 'docker compose' there.
# It prefers SSH key authentication. If you provide -p <password>, it will try to use sshpass.

usage() {
  cat <<EOF
Usage: $0 -h <host> -u <user> [-p <password>] [-d <remote_dir>] [-P <port>]
  -h <host>       Remote host to deploy to (default: 192.168.1.100)
  -u <user>       Remote ssh user (default: khanhnd)
  -p <password>   Remote ssh password (insecure; use only for quick test)
  -d <remote_dir> Remote directory to deploy into (default: /home/<user>/user-service)
  -P <port>       Remote SSH port (default: 22)

Note: This script requires 'ssh', 'scp', and 'tar' locally and 'docker' + 'docker compose' on the remote host.
EOF
  exit 1
}

HOST=192.168.1.100
USER=khanhnd
PASS=""
REMOTE_DIR=""
SSH_PORT=22

while getopts "h:u:p:d:P:" opt; do
  case ${opt} in
    h) HOST=${OPTARG} ;;
    u) USER=${OPTARG} ;;
    p) PASS=${OPTARG} ;;
    d) REMOTE_DIR=${OPTARG} ;;
    P) SSH_PORT=${OPTARG} ;;
    *) usage ;;
  esac
done

if [ -z "${REMOTE_DIR}" ]; then
  REMOTE_DIR="/home/${USER}/user-service"
fi

ROOT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_DIR="${ROOT_DIR}"

TARBALL="/tmp/user-service-$(date +%s).tar.gz"

echo "Packaging ${PROJECT_DIR} -> ${TARBALL}"
(cd "${PROJECT_DIR}" && tar czf "${TARBALL}" --exclude='./data' --exclude='*.db' .)

SSHCMD=(ssh -p ${SSH_PORT} ${USER}@${HOST})
SCPDEST="${USER}@${HOST}:~/"

# If password specified, prefer sshpass for non-interactive
if [ -n "${PASS}" ]; then
  if ! command -v sshpass >/dev/null 2>&1; then
    echo "sshpass not found; install it or use SSH keys. Attempting interactive scp..."
  else
    SCP=(sshpass -p "${PASS}" scp -P ${SSH_PORT})
    SSH=(sshpass -p "${PASS}" ssh -p ${SSH_PORT})
    SCPDEST="${USER}@${HOST}:~/"
  fi
fi

echo "Copying tarball to ${HOST}..."
if [ -n "${PASS}" ] && command -v sshpass >/dev/null 2>&1; then
  sshpass -p "${PASS}" scp -P ${SSH_PORT} "${TARBALL}" "${SCPDEST}"
else
  scp -P ${SSH_PORT} "${TARBALL}" "${SCPDEST}"
fi

REMOTE_TARBALL="~/${TARBALL##*/}"
echo "Remote tarball path: ${REMOTE_TARBALL}"

echo "Deploying on ${HOST} -> ${REMOTE_DIR}"
if [ -n "${PASS}" ] && command -v sshpass >/dev/null 2>&1; then
  sshpass -p "${PASS}" ssh -p ${SSH_PORT} ${USER}@${HOST} "REMOTE_DIR='${REMOTE_DIR}' REMOTE_TARBALL='${TARBALL##*/}' bash -s" <<'EOF'
set -euo pipefail
mkdir -p ${REMOTE_DIR}
tar xzf ${REMOTE_TARBALL} -C ${REMOTE_DIR}
rm -f ${REMOTE_TARBALL}
cd ${REMOTE_DIR}
# Try to install Docker & docker compose if missing (only sudo if available)
if ! command -v docker >/dev/null 2>&1; then
  echo 'Docker not found: please install docker on the remote host manually' >&2
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  echo 'docker compose not found; trying docker-compose binary...' >&2
  if ! command -v docker-compose >/dev/null 2>&1; then
    echo 'docker compose tooling not found; please install docker compose (or docker-compose)' >&2
    exit 1
  fi
fi
docker compose down || true
docker compose up -d --build
EOF
else
  ssh -p ${SSH_PORT} ${USER}@${HOST} "REMOTE_DIR='${REMOTE_DIR}' REMOTE_TARBALL='${TARBALL##*/}' bash -s" <<'EOF'
set -euo pipefail
mkdir -p ${REMOTE_DIR}
tar xzf ${REMOTE_TARBALL} -C ${REMOTE_DIR}
rm -f ${REMOTE_TARBALL}
cd ${REMOTE_DIR}
if ! command -v docker >/dev/null 2>&1; then
  echo 'Docker not found: please install docker on the remote host manually' >&2
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  echo 'docker compose not found; trying docker-compose binary...' >&2
  if ! command -v docker-compose >/dev/null 2>&1; then
    echo 'docker compose tooling not found; please install docker compose (or docker-compose)' >&2
    exit 1
  fi
fi
docker compose down || true
docker compose up -d --build
EOF
fi

echo "Deployment finished. Monitoring containers on ${HOST}"
# Print container status; fall back to plain docker ps if --format isn't supported
SHOW_CONTAINERS_CMD='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" || docker ps'
if [ -n "${PASS}" ] && command -v sshpass >/dev/null 2>&1; then
  sshpass -p "${PASS}" ssh -p ${SSH_PORT} ${USER}@${HOST} "bash -lc '${SHOW_CONTAINERS_CMD}'" || true
else
  ssh -p ${SSH_PORT} ${USER}@${HOST} "bash -lc '${SHOW_CONTAINERS_CMD}'" || true
fi

echo "Try a quick health check: http://${HOST}:8443/health" 

# Test health endpoint from local machine
if command -v curl >/dev/null 2>&1; then
  echo "Checking http://${HOST}:8443/health"
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://${HOST}:8443/health || true)
  if [ "$HTTP_CODE" = "200" ]; then
    echo "Health check OK: 200"
  else
    echo "Health check failed: HTTP code $HTTP_CODE" || true
  fi
else
  echo "curl not installed locally, skip health check"
fi
echo "Note: if the server uses a firewall, ensure TCP/8443 is allowed."
echo "Done."

exit 0
