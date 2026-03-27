#!/usr/bin/env bash
# run-web-test-test.sh
# Quick smoke-test driver for the web-tester plugin. Loads credentials and
# config from .env, then delegates to run-web-test.sh.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
XIANIX_ROOT="${SCRIPT_DIR}/.."
ENV_FILE="${XIANIX_ROOT}/AgentTeam.Console/.env"

if [ -f "${ENV_FILE}" ]; then
    set -a
    # shellcheck source=/dev/null
    source "${ENV_FILE}"
    set +a
else
    echo "[test] WARNING: .env not found at ${ENV_FILE} — relying on exported environment" >&2
fi

: "${WEBAPP_AREA:?WEBAPP_AREA must be set in .env or environment}"
: "${WEBAPP_URL:?WEBAPP_URL must be set in .env or environment}"

# CONTEXT_DIR is optional. If set, the agent reads context files from:
#   <CONTEXT_DIR>/.xianix/web-test/contexts/<WEBAPP_AREA>.md
# If not set, the agent falls back to UI inference (LOW confidence).
# export CONTEXT_DIR="/path/to/your-context-folder"

# Use local xianix-team when running from repo root (for local dev/testing)
if [ -d "${XIANIX_ROOT}/plugins/web-tester" ]; then
    export XIANIX_CACHE_DIR="${XIANIX_ROOT}"
    export XIANIX_USE_LOCAL=1
fi

exec "${XIANIX_ROOT}/scripts/run-web-test.sh" "$@"
