---
name: build-context
description: Create a context file for a web app feature area. Acts as a guided BA-style exploration — navigates the app, maps user flows, interviews you about business rules, then writes a context file ready for /test-webapp. Usage: /build-context --area="<area-name>"
argument-hint: --area="<area-name>" [--url=<url>] [--context-dir=<path>]
---

Create a context file for the **$ARGUMENTS** area of the web application.

## What This Does

This command invokes the **context-builder** agent, which acts as a senior business analyst to help you document a feature area for testing.

Unlike `/test-webapp` which runs autonomously, this command is **interactive** — the agent will pause and ask you questions. You are part of the process.

The agent works in three phases:

| Phase | What happens |
|-------|-------------|
| **Discovery** | Navigates the app, maps pages, forms, flows, and connected features |
| **Interview** | Presents findings and asks you up to 8 targeted questions about business rules and expected outcomes it cannot infer from the UI |
| **Composition** | Builds the context file, shows you a preview, and writes it only after your confirmation |

The resulting context file gives `/test-webapp` a `HIGH` confidence rating, producing precise and trustworthy test scenarios.

## How to Use

Type the command directly in the **Claude Code chat prompt** (not in a shell terminal).

**Run from your repo root when context files are in the repo:**
```
/build-context --area="login" --url=https://your-app.com
```

**Run with a custom context directory outside the repo:**
```
/build-context --area="login" --url=https://your-app.com --context-dir=C:\CONTEXT_DIR
```

**Override the URL for a specific environment:**
```
/build-context --area="checkout" --url=https://staging.example.com
```

| Flag | Required | Description |
|------|----------|-------------|
| `--area` | Yes | Feature area name — becomes the context filename |
| `--url` | No | Base URL of the app to crawl. Read from `config.md` if omitted — you will be asked if neither is available. |
| `--context-dir` | No | Path to the folder that contains `.xianix/web-test/`. Can be inside or outside the repo. Defaults to the current working directory. Pass the same value you use with `/test-webapp`. |

## Output

Writes one file on your confirmation:

| File | Contents |
|------|----------|
| `<context-dir>/.xianix/web-test/contexts/<area>.md` | Context file ready for `/test-webapp` |

> The `<context-dir>` folder must already exist and contain a `config.md` at `<context-dir>/.xianix/web-test/config.md`. See the [README Context Files section](../README.md#context-files) for setup instructions.

## What Happens Next

Once the context file is written, run:

```
/test-webapp --area="<area>" --context-dir="<context-dir>"
```

The test agent will load the context file and generate HIGH confidence test scenarios.

---

Starting context file creation now...
