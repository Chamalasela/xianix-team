---
name: post-test-report
description: Posts the web test report to a linked issue or ticket after testing completes. Reads web-test-report.md from the working directory and posts it as a comment using the available platform MCP or CLI.
---

Post the web test report from `web-test-report.md` to the linked issue or ticket: $ARGUMENTS

1. Read `web-test-report.md` from the working directory. If it does not exist, output:
   ```
   ERROR: web-test-report.md not found. Run /test-webapp first to generate the report.
   ```
   And stop.

2. Detect the platform from the git remote URL:
   ```bash
   git remote get-url origin
   ```
   - `github.com` → **GitHub**: use `mcp__github__add_issue_comment` or `gh issue comment`
   - `dev.azure.com` / `visualstudio.com` → **Azure DevOps**: use `curl` with `AZURE_TOKEN`
   - Anything else → **Generic**: output the report path and stop

3. Parse `$ARGUMENTS` for an issue/ticket number. If none provided, output the report to stdout and stop.

4. Post the full `web-test-report.md` content as a comment on the specified issue/ticket.

5. Output a single confirmation line:
   ```
   Report posted to issue #<number> on <platform> — <URL>
   ```
