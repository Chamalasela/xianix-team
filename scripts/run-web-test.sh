#!/usr/bin/env bash
# run-web-test.sh
#
# Bootstrap script for autonomous web application functional testing.
# Tests a live web application by URL — no project clone required.
# Outputs web-test-scenarios.md and web-test-report.md into OUTPUT_DIR.
#
# Usage:
#   ./scripts/run-web-test.sh [--scope=smoke|full]
#
# Required environment variables:
#
#   WEBAPP_AREA         Feature area to test — must match a context file name
#                       under <CONTEXT_DIR>/.xianix/web-test/contexts/<area>.md
#   WEBAPP_URL          Base URL of the web application to test
#
# Optional environment variables:
#
#   WEBAPP_SCOPE        Test scope: smoke (critical paths only) | full (default)
#   WEBAPP_USERNAME     Test account username (for authenticated flow scenarios)
#   WEBAPP_PASSWORD     Test account password (for authenticated flow scenarios)
#
#   CONTEXT_DIR         Directory containing .xianix/web-test/ config and context files.
#                       (default: not set — agent runs with LOW confidence / UI inference)
#                       Set this to any folder on disk; it does not need to be a git repo.
#
#   OUTPUT_DIR          Where to write web-test-scenarios.md and web-test-report.md
#                       (default: current working directory)
#
#   XIANIX_REPO         Xianix plugin marketplace repo
#                       (default: https://github.com/99x/xianix-team.git)
#   XIANIX_CACHE_DIR    Local path for the cloned xianix-team repo
#                       (default: /tmp/web-test-cache/xianix-team)
#   XIANIX_USE_LOCAL    Set to "1" to use XIANIX_CACHE_DIR as-is — for local dev testing

set -euo pipefail

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

readonly SCRIPT_NAME="run-web-test"

# Timestamps for each log line
log()  { echo "[$(date '+%H:%M:%S')] [${SCRIPT_NAME}] $*"; }
warn() { echo "[$(date '+%H:%M:%S')] [${SCRIPT_NAME}] WARN: $*" >&2; }

LAST_ERROR_MESSAGE=""

fail() {
    echo "[$(date '+%H:%M:%S')] [${SCRIPT_NAME}] ERROR: $*" >&2
    LAST_ERROR_MESSAGE="$*"
    exit 1
}

# Print a clearly visible section header
phase() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $*"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

RUN_START=$(date +%s)

cleanup_on_exit() {
    local _rc=$?
    local _elapsed=$(( $(date +%s) - RUN_START ))
    echo ""
    if [ "$_rc" -eq 0 ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log "✓ Done in ${_elapsed}s"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    else
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        warn "✗ Run failed after ${_elapsed}s (exit code ${_rc})"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    fi
}
trap cleanup_on_exit EXIT

# ---------------------------------------------------------------------------
# Parse flags
# ---------------------------------------------------------------------------

SCOPE_OVERRIDE=""
for arg in "$@"; do
    case "$arg" in
        --scope=*) SCOPE_OVERRIDE="${arg#--scope=}" ;;
        *)         fail "Unknown argument: $arg" ;;
    esac
done

# ---------------------------------------------------------------------------
# Phase 1: Validate configuration
# ---------------------------------------------------------------------------

phase "Phase 1/5 · Validating configuration"

: "${WEBAPP_AREA:?WEBAPP_AREA is required — must match a context file name under .xianix/web-test/contexts/<area>.md}"
: "${WEBAPP_URL:?WEBAPP_URL is required — set it to the base URL of the web application to test}"

EFFECTIVE_SCOPE="${SCOPE_OVERRIDE:-${WEBAPP_SCOPE:-full}}"

log "Area   : ${WEBAPP_AREA}"
log "URL    : ${WEBAPP_URL}"
log "Scope  : ${EFFECTIVE_SCOPE}"

# Resolve context directory
if [ -n "${CONTEXT_DIR:-}" ]; then
    [ -d "${CONTEXT_DIR}" ] || fail "CONTEXT_DIR does not exist: ${CONTEXT_DIR}"
    CONTEXT_FILE="${CONTEXT_DIR}/.xianix/web-test/contexts/${WEBAPP_AREA}.md"
    if [ ! -f "$CONTEXT_FILE" ]; then
        warn "No context file at ${CONTEXT_FILE} — scenario-generator will fall back to UI inference (LOW confidence)"
    else
        log "Context: ${CONTEXT_FILE} ✓"
    fi
else
    warn "CONTEXT_DIR is not set — scenario-generator will use UI inference (LOW confidence)"
fi

# Resolve output directory
OUTPUT_DIR="${OUTPUT_DIR:-$(pwd)}"
mkdir -p "$OUTPUT_DIR"
log "Output : ${OUTPUT_DIR}"

# ---------------------------------------------------------------------------
# Phase 2: Check prerequisites
# ---------------------------------------------------------------------------

phase "Phase 2/5 · Checking prerequisites"

log "Checking Node.js..."
command -v node > /dev/null 2>&1 || fail "Node.js is not installed (required for Playwright)"
log "  Node.js $(node --version) ✓"

log "Checking claude CLI..."
command -v claude > /dev/null 2>&1 || fail "claude CLI is not installed (https://docs.anthropic.com/claude-code)"
log "  claude $(claude --version 2>/dev/null | head -1) ✓"

log "Checking Playwright..."
if command -v playwright > /dev/null 2>&1; then
    PLAYWRIGHT_VERSION=$(playwright --version 2>/dev/null)
elif [ -f "./node_modules/.bin/playwright" ]; then
    PLAYWRIGHT_VERSION=$(./node_modules/.bin/playwright --version 2>/dev/null)
else
    fail "Playwright is not installed. Run: npm install -D playwright @axe-core/playwright && npx playwright install chromium"
fi
log "  ${PLAYWRIGHT_VERSION} ✓"

# ---------------------------------------------------------------------------
# Phase 3: Prepare plugin
# ---------------------------------------------------------------------------

phase "Phase 3/5 · Preparing web-tester plugin"

XIANIX_REPO="${XIANIX_REPO:-https://github.com/99x/xianix-team.git}"
XIANIX_CACHE_DIR="${XIANIX_CACHE_DIR:-/tmp/web-test-cache/xianix-team}"
PLUGIN_DIR="${XIANIX_CACHE_DIR}/plugins/web-tester"

if [ "${XIANIX_USE_LOCAL:-0}" = "1" ]; then
    log "Using local plugin at ${XIANIX_CACHE_DIR} (XIANIX_USE_LOCAL=1)"
elif [ -d "${XIANIX_CACHE_DIR}" ] && git -C "${XIANIX_CACHE_DIR}" rev-parse --git-dir >/dev/null 2>&1; then
    log "Updating plugin repo..."
    git -C "${XIANIX_CACHE_DIR}" pull --ff-only --quiet
    log "Plugin repo up to date ✓"
else
    if [ -d "${XIANIX_CACHE_DIR}" ]; then
        log "Removing stale plugin cache and recloning..."
        rm -rf "${XIANIX_CACHE_DIR}"
    else
        log "Cloning plugin repo..."
    fi
    mkdir -p "$(dirname "${XIANIX_CACHE_DIR}")"
    git clone --depth=1 --quiet "${XIANIX_REPO}" "${XIANIX_CACHE_DIR}"
    log "Plugin repo cloned ✓"
fi

[ -d "${PLUGIN_DIR}" ] || fail "Plugin directory not found at ${PLUGIN_DIR} — check XIANIX_REPO"
log "Plugin ready ✓"

# ---------------------------------------------------------------------------
# Phase 4: Run the web test (streaming output in real time)
# ---------------------------------------------------------------------------

phase "Phase 4/5 · Running web test"

PROMPT="/test-webapp --area=\"${WEBAPP_AREA}\" --url=\"${WEBAPP_URL}\" --scope=${EFFECTIVE_SCOPE}"
[ -n "${CONTEXT_DIR:-}" ] && PROMPT="${PROMPT} --context-dir=\"${CONTEXT_DIR}\""

log "Agent pipeline:"
log "  1 · scenario-generator  — reads context, derives test cases"
log "  2 · functional-tester   — executes user flows via Playwright"
log "  3 · ui-tester           — checks rendering at 3 viewports"
log "  4 · accessibility-tester— runs axe-core WCAG sweep"
log "  5 · performance-tester  — measures LCP, load time, page weight"
log "Steps 2-5 run in parallel after step 1 completes."
log "Depending on scope and page count this typically takes 3-10 minutes."
echo ""

# Background heartbeat — prints a still-running line every 30s so the
# terminal doesn't look frozen during long agent runs.
heartbeat() {
    local elapsed=0
    while true; do
        sleep 30
        elapsed=$((elapsed + 30))
        echo "[$(date '+%H:%M:%S')] [run-web-test] ... still running (${elapsed}s elapsed)"
    done
}
heartbeat &
HEARTBEAT_PID=$!

CLAUDE_LOG=$(mktemp)

cd "$OUTPUT_DIR"

set +e
claude \
    --dangerously-skip-permissions \
    --verbose \
    --plugin-dir "${PLUGIN_DIR}" \
    -p "${PROMPT}" 2>&1 | tee "$CLAUDE_LOG"
CLAUDE_EXIT=${PIPESTATUS[0]}
set -e

kill "$HEARTBEAT_PID" 2>/dev/null || true
wait "$HEARTBEAT_PID" 2>/dev/null || true

if [ "$CLAUDE_EXIT" -ne 0 ]; then
    if grep -qi "credit balance is too low\|insufficient.*credit\|billing\|payment" "$CLAUDE_LOG"; then
        LAST_ERROR_MESSAGE="Claude API credit balance is too low — top up at https://console.anthropic.com/settings/billing"
    else
        LAST_ERROR_MESSAGE="claude exited with code ${CLAUDE_EXIT}"
    fi
    rm -f "$CLAUDE_LOG"
    exit "$CLAUDE_EXIT"
fi

rm -f "$CLAUDE_LOG"

# ---------------------------------------------------------------------------
# Phase 5: Report output locations
# ---------------------------------------------------------------------------

phase "Phase 5/5 · Results"

if [ -f "${OUTPUT_DIR}/web-test-scenarios.md" ]; then
    log "Scenarios  → ${OUTPUT_DIR}/web-test-scenarios.md"
else
    warn "web-test-scenarios.md was not written — check agent output above"
fi

if [ -f "${OUTPUT_DIR}/web-test-report.md" ]; then
    log "Report     → ${OUTPUT_DIR}/web-test-report.md"
else
    warn "web-test-report.md was not written — check agent output above"
fi
