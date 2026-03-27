---
name: run-web-test
description: Entrypoint skill for running a web functional test. Invokes the web-tester orchestrator for a given area. Use this skill when triggering web tests programmatically or from a CI/CD hook.
---

Run a functional test on the configured web application for the area: $ARGUMENTS

Use the **web-tester** agent to:

1. Load `.xianix/web-test/config.md` for the base URL and default settings
2. Load `.xianix/web-test/contexts/<area>.md` for the feature area context
3. Load `.xianix/web-test/_shared.md` for shared context (auth states, test data, common patterns)
4. Run preflight checks (Playwright availability, URL reachability)
5. Discover pages scoped to the area's `url-paths`
6. Generate test scenarios via `scenario-generator` (sequential — must complete first)
7. Execute `ui-tester`, `functional-tester`, `accessibility-tester`, `performance-tester` in parallel
8. Compile and write `web-test-report.md` and `web-test-scenarios.md`

Parse `$ARGUMENTS` for:
- `--area=` (required)
- `--url=` (optional override)
- `--scope=` (optional override)

If `$ARGUMENTS` is empty or `--area` is missing, output:
```
ERROR: --area is required. Usage: /test-webapp --area="<area-name>"
Available areas: check .xianix/web-test/contexts/ for context files.
```
And stop.
