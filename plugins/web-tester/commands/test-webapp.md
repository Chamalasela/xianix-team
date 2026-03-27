---
name: test-webapp
description: Run functional tests on a web application for a specific feature area. Generates test scenarios from context files, then tests UI, functionality, accessibility, and performance in parallel. Usage: /test-webapp --area="<area-name>"
argument-hint: --area="<area-name>" [--url=<url>] [--scope=smoke|full]
---

Run a comprehensive functional test for the **$ARGUMENTS** area of the web application.

## What This Does

This command invokes the **web-tester** agent which:

1. Reads `.xianix/web-test/config.md` for the base URL and settings
2. Loads `.xianix/web-test/contexts/<area>.md` as the test context
3. Generates precise, traceable test scenarios via `scenario-generator`
4. Runs four specialist sub-agents in parallel:

| Sub-agent | Focus |
|-----------|-------|
| `functional-tester` | User flows, form validation, navigation, redirects |
| `ui-tester` | Rendering, responsiveness (mobile/tablet/desktop), broken assets |
| `accessibility-tester` | WCAG 2.1 AA, axe-core violations, keyboard navigation |
| `performance-tester` | LCP, load time, page weight, request count |

## How to Use

```
/test-webapp --area="login"
/test-webapp --area="user-profile" --scope=smoke
/test-webapp --area="checkout" --url=https://staging.example.com
```

| Flag | Required | Description |
|------|----------|-------------|
| `--area` | Yes | Feature area to test. Must match a context file: `.xianix/web-test/contexts/<area>.md` |
| `--url` | No | Override base URL from `config.md` (e.g. for staging runs) |
| `--scope` | No | `smoke` = critical paths only; `full` = all scenarios (default from `config.md`) |

## Prerequisites

**Playwright installed:**
```bash
npm install -D playwright @axe-core/playwright
npx playwright install chromium
```

**Config file exists:**
```
.xianix/web-test/config.md
```

**Context file exists for the area** (optional but recommended):
```
.xianix/web-test/contexts/<area>.md
```
Without a context file the agent falls back to UI inference — results will have `LOW` confidence.

## Output

Two files are written to the working directory:

| File | Contents |
|------|----------|
| `web-test-scenarios.md` | Generated scenario manifest — what was intended to be tested |
| `web-test-report.md` | Full test report — what actually passed, failed, or was skipped |

## Confidence Levels

The report header shows a confidence level based on the quality of the context file:

| Level | Meaning |
|-------|---------|
| `HIGH` | Context file present with flows, rules, and expected outcomes |
| `MEDIUM` | Context file present but missing expected outcomes or business rules |
| `LOW` | No context file — scenarios inferred from UI structure only |

## Setup Guide

See `docs/playwright-setup.md` for full setup instructions and `docs/context-file-guide.md` for how to write effective context files.

---

Starting web application test now...
