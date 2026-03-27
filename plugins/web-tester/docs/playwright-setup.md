# Playwright Setup Guide

The `web-tester` plugin requires Playwright and axe-core to be installed in the environment where Claude Code runs.

---

## Install Dependencies

```bash
npm install -D playwright @axe-core/playwright
npx playwright install chromium
```

This installs:
- **Playwright** — browser automation (Chromium, Firefox, WebKit)
- **@axe-core/playwright** — axe accessibility engine integrated with Playwright
- **Chromium** — the browser binary used for headless testing

### Verify Installation

```bash
npx playwright --version
node -e "require('@axe-core/playwright'); console.log('axe-core ready')"
```

Both commands should succeed without errors.

---

## Environment Variables

Set these before running tests that require authentication:

| Variable | Description |
|----------|-------------|
| `WEBAPP_USERNAME` | Test account email / username |
| `WEBAPP_PASSWORD` | Test account password |

```bash
export WEBAPP_USERNAME="test@example.com"
export WEBAPP_PASSWORD="your-test-password"
```

These are only required for scenarios that have `Preconditions: User is logged in`. Public-facing flows run without them.

---

## Troubleshooting

### "browserType.launch: Executable doesn't exist"

Chromium was not installed. Run:
```bash
npx playwright install chromium
```

### "Cannot find module '@axe-core/playwright'"

axe-core was not installed. Run:
```bash
npm install -D @axe-core/playwright
```

### Tests time out on a slow machine

The default timeout is 30 seconds per page load. If your application is slow, you can increase it by editing the `timeout` values in Playwright scripts. This is not configurable via flags at this time.

### Tests fail on a self-signed certificate (staging environment)

Set the `NODE_TLS_REJECT_UNAUTHORIZED` env var for local staging:
```bash
export NODE_TLS_REJECT_UNAUTHORIZED=0
```
Do not use this in production.

---

## Supported Node.js Versions

Playwright requires Node.js 18 or later.

```bash
node --version   # should be v18.0.0 or higher
```
