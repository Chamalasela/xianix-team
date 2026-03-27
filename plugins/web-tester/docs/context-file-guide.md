# Context File Guide

Context files are the primary way to tell the `web-tester` agent what a feature area is supposed to do. The richer the context file, the more precise and trustworthy the generated test scenarios will be.

---

## Where Context Files Live

```
.xianix/
└── web-test/
    ├── config.md                  ← Base URL and global settings
    ├── _shared.md                 ← Auth states, common test data, nav structure
    └── contexts/
        ├── login.md
        ├── user-profile.md
        ├── checkout.md
        └── dashboard.md
```

The filename (without `.md`) is the area name used with `--area`:
```
/test-webapp --area="user-profile"   →   reads .xianix/web-test/contexts/user-profile.md
```

---

## `config.md` — Global Config

```markdown
---
type: web-test-config
---

## Base URL
https://example.com

## Environments
| Name    | URL                         |
|---------|-----------------------------|
| staging | https://staging.example.com |
| prod    | https://example.com         |

## Default Scope
full

## Auth
credentials_env: WEBAPP_USERNAME / WEBAPP_PASSWORD
login_path: /login
post_login_redirect: /dashboard
```

---

## `_shared.md` — Shared Context

Shared context is merged into every area's context. Put things here that apply to multiple areas — auth patterns, common test data, error display conventions.

```markdown
---
type: web-test-shared
---

## Authentication States
- **Logged out**: No session cookie; protected routes redirect to /login
- **Logged in (standard user)**: Access to /profile, /dashboard, /settings
- **Logged in (admin)**: Additional access to /admin

## Common Test Data
- Standard user credentials: WEBAPP_USERNAME / WEBAPP_PASSWORD env vars
- Invalid email format: not-an-email
- Max-length string (255 chars): aaaa...a (255 a's)
- Empty string: (empty)

## Navigation Structure
- Top nav: Home, Dashboard, Profile, Settings, Logout
- Nav visible when logged in; only Home visible when logged out

## Error Display Patterns
- Validation errors: inline below the field, red border on input
- Server errors: toast notification top-right, "Something went wrong"
- 404: /not-found page with "Page not found" heading
```

---

## Area Context File Format

Every file under `contexts/` must follow this structure:

```markdown
---
area: <area-slug>
url-paths: [/path1, /path2]
related-areas: [other-area-1, other-area-2]
---

## What This Area Does
One paragraph describing the feature and its purpose.

## Key User Flows
1. Flow name — description of what the user does and why
2. Flow name — description
...

## Business Rules
- Rule 1
- Rule 2
...

## Expected Outcomes (per flow)
| Flow | Success Condition |
|------|-------------------|
| Flow 1 | What "passing" looks like — observable, specific |
| Flow 2 | ... |

## Out of Scope
- Feature X (covered in `other-area.md`)
- Feature Y

## Test Data Notes
- Specific data requirements
- Test account details
- File paths for uploads, etc.
```

---

## What Makes a Good Context File

**Good — specific and observable:**
```markdown
## Expected Outcomes
| Flow | Success Condition |
|------|-------------------|
| Edit profile | Success toast "Profile updated" appears, changes persist on page reload |
| Upload avatar | New image visible within 3 seconds, old image replaced |
```

**Poor — vague:**
```markdown
## Expected Outcomes
| Flow | Success Condition |
|------|-------------------|
| Edit profile | It works |
| Upload avatar | User sees their avatar |
```

---

## Tips

- **`url-paths`** scopes the site crawl — the agent won't crawl the entire app, only the listed paths. Keep this focused.
- **`related-areas`** is informational — it tells the agent where to look if it encounters something out of scope, preventing duplicate scenarios.
- **`Out of Scope`** is important — it prevents the scenario generator from creating scenarios for things covered by another area's context file.
- **`Test Data Notes`** matters for functional testing — if your flows require a seeded test account or specific file, document it here.
