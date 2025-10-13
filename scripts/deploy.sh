#!/usr/bin/env bash
set -euo pipefail
export TAG="${1:-latest}"
# Si GHCR privé: docker login ghcr.io -u "$GITHUB_USER" -p "$GITHUB_PAT"
docker compose -f /opt/folio/docker-compose.prod.yml pull
docker compose -f /opt/folio/docker-compose.prod.yml up -d
docker image prune -f