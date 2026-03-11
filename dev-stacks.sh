#!/usr/bin/env bash
#
# Start or stop all local dev Docker Compose stacks (postgres, redis, minio, mailpit, mysql).
# Usage:
#   ./dev-stacks.sh up      # start all (default)
#   ./dev-stacks.sh down    # stop all
#   ./dev-stacks.sh status  # docker compose ps per stack
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

SERVICES=(postgres redis minio mailpit mysql)

usage() {
  echo "Usage: $(basename "$0") [up|down|status]"
  echo "  up      Start all stacks (creates .env from .env.example if missing)"
  echo "  down    Stop and remove containers for all stacks"
  echo "  status  Show compose ps for each stack"
}

ensure_env() {
  local dir="$1"
  if [[ ! -f "$dir/.env" ]]; then
    if [[ -f "$dir/.env.example" ]]; then
      cp "$dir/.env.example" "$dir/.env"
      echo "  → created $dir/.env from .env.example"
    else
      echo "  → warning: $dir has no .env.example, docker compose may warn"
    fi
  fi
}

cmd_up() {
  echo "Starting all dev stacks from $SCRIPT_DIR"
  for d in "${SERVICES[@]}"; do
    if [[ ! -d "$d" ]] || [[ ! -f "$d/docker-compose.yml" ]]; then
      echo "  skip $d (missing dir or docker-compose.yml)"
      continue
    fi
    echo ""
    echo "[$d]"
    ensure_env "$d"
    (cd "$d" && docker compose up -d)
  done
  echo ""
  echo "Done. Check Docker Desktop or: $0 status"
}

cmd_down() {
  echo "Stopping all dev stacks from $SCRIPT_DIR"
  for d in "${SERVICES[@]}"; do
    if [[ ! -f "$d/docker-compose.yml" ]]; then
      continue
    fi
    echo ""
    echo "[$d] docker compose down"
    (cd "$d" && docker compose down) || true
  done
  echo ""
  echo "All stacks stopped."
}

cmd_status() {
  for d in "${SERVICES[@]}"; do
    if [[ ! -f "$d/docker-compose.yml" ]]; then
      continue
    fi
    echo "======== $d ========"
    (cd "$d" && docker compose ps -a) || true
    echo ""
  done
}

case "${1:-up}" in
  up|start)
    cmd_up
    ;;
  down|stop)
    cmd_down
    ;;
  status|ps)
    cmd_status
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    echo "Unknown command: $1"
    usage
    exit 1
    ;;
esac
