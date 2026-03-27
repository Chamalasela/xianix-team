---
type: web-test-config
---

## Base URL
https://your-app.com

## Environments
| Name    | URL                         |
|---------|-----------------------------|
| staging | https://staging.your-app.com |
| prod    | https://your-app.com         |

## Default Scope
full

## Auth
credentials_env: WEBAPP_USERNAME / WEBAPP_PASSWORD
login_path: /login
post_login_redirect: /dashboard
