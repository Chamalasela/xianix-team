---
name: build-context
description: Create a web test context file for a feature area through guided BA-style exploration. Pauses to ask the user questions about business rules before writing the file. Usage: /build-context --area="<area-name>" [--url=<url>] [--context-dir=<path>]
argument-hint: --area="<area-name>" [--url=<url>] [--context-dir=<path>]
---

Create a context file for the web application area: $ARGUMENTS

Use the **context-builder** agent to:

1. Parse `--area=` (required), `--url=` (optional), `--context-dir=` (optional) from `$ARGUMENTS`
2. Resolve the base URL from `--url`, or from `<context-dir>/.xianix/web-test/config.md` if not provided
3. Crawl the target area — map pages, forms, inputs, navigation, and connected features
4. Present a structured discovery summary to the user
5. Ask the user up to 8 targeted questions about business rules, expected outcomes, and edge cases that cannot be inferred from the UI
6. Wait for the user's answers before proceeding
7. Compose the context file from the discovery data and user answers
8. Show a preview of the complete context file and ask the user to confirm before writing
9. Write the file to `<context-dir>/.xianix/web-test/contexts/<area>.md` only on explicit user confirmation

If `$ARGUMENTS` is empty or `--area` is missing, output:
```
ERROR: --area is required. Usage: /build-context --area="<area-name>"
```
And stop.
