# web-tester

A Claude Code plugin for functional testing of web applications. Given a feature area name, the agent generates test scenarios from context files and runs UI, functional, accessibility, and performance tests in parallel.

The plugin ships with two commands:

| Command | What it does |
|---------|-------------|
| `/build-context` | Guided BA-style exploration — navigates the app, interviews you about business rules, writes the context file |
| `/test-webapp` | Runs the full test suite against the app using the context file |

Run `/build-context` first to create the context file, then `/test-webapp` to test against it.

---

## Quick Start

### 1. Install Playwright

```bash
npm install -D playwright @axe-core/playwright
npx playwright install chromium
```

### 2. Set up the context directory

The plugin reads config and context files from a `.xianix/web-test/` folder. You need to create this folder and add a config file before running any commands.

**Where to create it:**

The folder can live **inside your repo** (most common) or **at any path on disk** — see [Context Files](#context-files) for guidance.

**How to set it up:**

Copy the starter templates shipped with the plugin:

```bash
# From your repo root (or whichever directory you want as your context-dir)
mkdir -p .xianix/web-test/contexts
cp plugins/web-tester/docs/templates/config.md .xianix/web-test/config.md
cp plugins/web-tester/docs/templates/_shared.md .xianix/web-test/_shared.md
```

Then open `.xianix/web-test/config.md` and set your app's base URL:

```markdown
---
type: web-test-config
---

## Base URL
https://your-app.com

## Default Scope
full
```

> If your context directory is **not** your repo root, pass `--context-dir=<path>` to every command so the agent knows where to look.

### 3. Create a context file for the area you want to test

**Option A — let the agent do it (recommended):**

Open Claude Code in your terminal from your **repo root** (or whichever directory contains `.xianix/web-test/`), then run:

```
/build-context --area="login" --url=https://your-app.com
```

If your context directory is not the repo root, add `--context-dir`:

```
/build-context --area="login" --url=https://your-app.com --context-dir=C:\CONTEXT_DIR
```

The agent navigates the app, asks you up to 8 questions about business rules, shows you a preview, and only writes the file after you confirm.

> `/build-context` is a Claude Code slash command. You type it directly in the Claude Code chat prompt — not in a shell terminal.

**Option B — write it manually:**
```
<context-dir>/.xianix/web-test/contexts/login.md
```
See `docs/context-file-guide.md` for the required format.

### 4. Run the tests

Open Claude Code from the same directory and run:

```
/test-webapp --area="login"
```

Or, if your context directory is not the repo root:

```
/test-webapp --area="login" --context-dir=C:\CONTEXT_DIR
```

---

## How It Works

### build-context

```
/build-context --area="login"
        │
        ▼
  context-builder (BA agent)
  ├── Resolve config.md + check for existing context file
  ├── Crawl area — map pages, forms, nav, connected features
  │
  ├── ⏸ Pause: present discovery summary + ask user up to 8 questions
  │       (business rules, expected outcomes, edge cases)
  │
  ├── Compose context file from discovery + user answers
  │
  ├── ⏸ Pause: show full preview → "yes / edit / no"
  │
  └── Write .xianix/web-test/contexts/login.md
```

### test-webapp

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

The plugin has two distinct groups of agents: one for **building context files** and one for **running tests**.

---

### Group 1 — Context Builder

> Invoked by `/build-context`. Runs interactively. Does not execute tests.

#### `context-builder`

Acts as a senior business analyst. Combines what it observes from the live application UI with business knowledge it gathers from you through a short interview, then produces a structured context file.

**How it runs:** Conversational — pauses twice for user input before writing anything.

| Phase | What happens |
|-------|-------------|
| Discovery | Crawls the target URL; maps pages, forms, inputs, nav, connected features, auth indicators, and tech stack |
| Interview | Presents findings and asks up to 8 targeted questions about business rules, expected outcomes, and edge cases that cannot be inferred from the UI |
| Composition | Builds the context file, shows a full preview, and waits for `yes / edit / no` before writing |

**Input:** `--area`, `--url`, `--context-dir`
**Output:** `.xianix/web-test/contexts/<area>.md`
**Confidence produced:** `HIGH` (when the user provides business rule answers)

---

### Group 2 — Test Suite

> Invoked by `/test-webapp`. Runs autonomously without user input after launch.

#### `web-tester` (orchestrator)

Coordinates the entire test run. Loads config and context files, runs preflight checks, fires `scenario-generator` sequentially, then launches the four testing agents in parallel. Compiles all results into the final report.

**Receives:** `--area`, `--url`, `--scope`, `--context-dir`
**Outputs:** `web-test-scenarios.md`, `web-test-report.md`

---

#### `scenario-generator`

Converts context file content and site structure into a precise, typed scenario manifest. Every downstream testing agent consumes this manifest — it is the single source of truth for what gets tested.

**Runs:** Sequentially, before any testing agent starts.
**Receives:** `base_url`, `area_context`, `shared_context`, `context_confidence`, `site_manifest`, `scope`
**Outputs:** Scenario manifest (written to `web-test-scenarios.md` by the orchestrator)

Each scenario is tagged by type and priority:

| Type | What it covers |
|------|---------------|
| `functional` | User flows — happy path, sad path, edge cases |
| `ui` | Rendering at mobile (375px), tablet (768px), desktop (1440px) |
| `accessibility` | WCAG 2.1 AA compliance per flow target page |
| `performance` | LCP, load time, TTFB, page weight thresholds |

Scenarios inferred without a context file are marked `[INFERRED]` and carry `LOW` confidence.

---

#### `functional-tester`

Executes every `type: functional` scenario using Playwright. Writes a temporary script per scenario, runs it, captures `PASS` or `FAIL: <reason>`, then deletes the scripts.

**Receives:** `base_url`, `site_manifest`, `scenario_manifest`, `auth_config`
**Checks auth:** Skips auth-required scenarios when `WEBAPP_USERNAME` / `WEBAPP_PASSWORD` env vars are absent
**Reports:** Pass/fail table + structured failure details with expected vs actual behaviour

---

#### `ui-tester`

Executes every `type: ui` scenario across three viewports (mobile, tablet, desktop) using Playwright. Also runs a baseline visual pass on all discovered pages regardless of scenarios, catching broken images, missing resources, and console errors.

**Receives:** `base_url`, `site_manifest`, `scenario_manifest`
**Checks per page:** HTTP status, broken images (`naturalWidth === 0`), JavaScript console errors
**Reports:** Scenario results per viewport + baseline page results table

---

#### `accessibility-tester`

Runs axe-core (`@axe-core/playwright`) on every `type: accessibility` scenario target and performs a full axe sweep across all discovered pages. Also checks keyboard navigation reachability by simulating Tab keypresses.

**Receives:** `base_url`, `site_manifest`, `scenario_manifest`
**Requires:** `@axe-core/playwright` (falls back to `pa11y` if missing)
**Severity mapping:**

| axe impact | Reported as |
|-----------|-------------|
| `critical` / `serious` | CRITICAL |
| `moderate` | WARNING |
| `minor` | INFO |

**Reports:** Violations per page with WCAG rule references, element selectors, and fix guidance

---

#### `performance-tester`

Measures Playwright browser metrics on every `type: performance` scenario and runs a baseline pass on all discovered pages. Uses the Navigation Timing API and LCP observer to collect real browser metrics.

**Receives:** `base_url`, `site_manifest`, `scenario_manifest`
**Thresholds:**

| Metric | PASS | WARNING | FAIL |
|--------|------|---------|------|
| LCP | < 2.5s | 2.5–4s | > 4s |
| Fully loaded | < 3s | 3–6s | > 6s |
| TTFB | < 600ms | 600ms–1.5s | > 1.5s |
| Page weight | < 1MB | 1–3MB | > 3MB |
| Network requests | < 50 | 50–100 | > 100 |

**Reports:** Per-scenario and per-page metrics table + specific optimisation recommendations for failures

---

## Commands

### /build-context

Creates a context file for a feature area through guided BA-style exploration. **Interactive** — pauses to ask you questions before writing.

```
/build-context --area="login"
/build-context --area="checkout" --url=https://staging.example.com
/build-context --area="dashboard" --context-dir=/path/to/project
```

| Flag | Required | Description |
|------|----------|-------------|
| `--area` | Yes | Feature area name — becomes the context filename |
| `--url` | No | Override base URL from `config.md` |
| `--context-dir` | No | Directory containing `.xianix/web-test/` |

Output: `<context-dir>/.xianix/web-test/contexts/<area>.md`

---

### /test-webapp

```
/test-webapp --area="<area>"                                        # Use base URL from config.md
/test-webapp --area="<area>" --scope=smoke                          # Critical paths only
/test-webapp --area="<area>" --url=https://staging.example.com      # Override URL
```

---

## Context Files

The plugin reads config and context files from a `.xianix/web-test/` folder. The location of that folder is controlled by `--context-dir`.

### Folder structure

```
<context-dir>/
└── .xianix/
    └── web-test/
        ├── config.md          ← Base URL, environments, auth settings
        ├── _shared.md         ← Auth states, common test data, error patterns
        └── contexts/
            ├── login.md
            ├── user-profile.md
            └── checkout.md
```

### Where should `<context-dir>` live?

`--context-dir` accepts **any directory path** — inside or outside the repository under test. Choose based on your situation:

| Situation | Recommended location | Example flag |
|-----------|---------------------|--------------|
| Config belongs to this project | Repo root (the default) | *(omit the flag)* |
| Testing an external app you don't own | A folder inside your working repo | `--context-dir=./test-contexts/my-app` |
| Context shared across multiple projects | A standalone folder or shared drive | `--context-dir=C:\Shared\web-test-contexts` |
| Credentials or auth config must stay off-disk | A secrets-managed path outside the repo | `--context-dir=/mnt/secrets/web-test` |

**Default behaviour:** When `--context-dir` is omitted, the agent resolves all paths relative to the **current working directory** (the repo root where Claude Code is running).

### File path resolution

| `--context-dir` | Config file resolved to |
|----------------|------------------------|
| `--context-dir=/path/to/dir` | `/path/to/dir/.xianix/web-test/config.md` |
| *(omitted)* | `./.xianix/web-test/config.md` |

The same rule applies to context files: `<context-dir>/.xianix/web-test/contexts/<area>.md`.

Use `/build-context` to generate context files automatically, or write them manually following `docs/context-file-guide.md`.

Without context files the agent falls back to UI inference — scenarios are generated from page structure alone and confidence will be `LOW`.

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
