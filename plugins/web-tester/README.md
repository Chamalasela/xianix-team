# web-tester

A Claude Code plugin for functional testing of web applications. Given a feature area name, the agent generates test scenarios from context files and runs UI, functional, accessibility, and performance tests in parallel.

---

## Quick Start

### 1. Install Playwright

```bash
npm install -D playwright @axe-core/playwright
npx playwright install chromium
```

### 2. Create the config file in your repo

```
.xianix/web-test/config.md
```

Minimum required content:
```markdown
---
type: web-test-config
---

## Base URL
https://your-app.com

## Default Scope
full
```

### 3. Create a context file for the area you want to test

```
.xianix/web-test/contexts/login.md
```

### 4. Run

```
/test-webapp --area="login"
```

---

## How It Works

```
/test-webapp --area="user-profile"
        │
        ▼
  web-tester (orchestrator)
  ├── Load config.md + contexts/user-profile.md + _shared.md
  ├── Preflight (Playwright available? URL reachable?)
  ├── Site discovery (scoped to url-paths in context file)
  │
  ├── scenario-generator ◄── sequential, blocking
  │       Reads context → generates scenario manifest
  │       Writes web-test-scenarios.md
  │
  └── Parallel launch:
      ├── functional-tester   (type: functional scenarios)
      ├── ui-tester           (type: ui scenarios + baseline pass)
      ├── accessibility-tester (type: accessibility scenarios + axe sweep)
      └── performance-tester  (type: performance scenarios + baseline pass)
              │
              ▼
        web-test-report.md
```

---

## Agents

| Agent | Role |
|-------|------|
| `web-tester` | Orchestrator — coordinates all phases |
| `scenario-generator` | Derives test cases from context files (runs first, sequentially) |
| `functional-tester` | Executes user flows via Playwright |
| `ui-tester` | Checks rendering at mobile/tablet/desktop viewports |
| `accessibility-tester` | WCAG 2.1 AA compliance via axe-core |
| `performance-tester` | LCP, load time, page weight, request counts |

---

## Command

```
/test-webapp --area="<area>"            # Use base URL from config.md
/test-webapp --area="<area>" --scope=smoke     # Critical paths only
/test-webapp --area="<area>" --url=https://staging.example.com  # Override URL
```

---

## Context Files

The plugin reads context from `.xianix/web-test/` in your repository:

```
.xianix/web-test/
├── config.md          ← Base URL, environments, auth settings
├── _shared.md         ← Auth states, common test data, error patterns
└── contexts/
    ├── login.md
    ├── user-profile.md
    └── checkout.md
```

Without context files the agent falls back to UI inference — scenarios are generated from page structure alone and confidence will be `LOW`. See `docs/context-file-guide.md` for how to write effective context files.

---

## Output

| File | Contents |
|------|----------|
| `web-test-scenarios.md` | Generated scenario manifest — auditable record of what was tested |
| `web-test-report.md` | Full test report — pass/fail/skip per scenario and area |

---

## Confidence Levels

| Level | Meaning |
|-------|---------|
| `HIGH` | Context file present with flows, business rules, and expected outcomes |
| `MEDIUM` | Context file present but incomplete |
| `LOW` | No context file — inferred from UI structure only |

---

## Prerequisites

- Node.js 18+
- Playwright + Chromium installed (see `docs/playwright-setup.md`)
- `.xianix/web-test/config.md` in your repository

---

## Docs

- [Playwright Setup](docs/playwright-setup.md)
- [Context File Guide](docs/context-file-guide.md)
