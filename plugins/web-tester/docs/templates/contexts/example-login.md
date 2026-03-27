---
area: login
url-paths: [/login, /register, /forgot-password]
related-areas: [user-profile, settings]
---

## What This Area Does
The login area allows users to authenticate into the application and manage their session. It includes the sign-in form, registration for new users, and password recovery.

## Key User Flows
1. Sign in with valid credentials — user enters email and password, clicks Sign In, is redirected to the dashboard
2. Sign in with invalid credentials — user enters wrong password; an error message is displayed, user stays on login page
3. Sign in with empty fields — user submits blank form; inline validation errors appear on required fields
4. Register new account — user fills in name, email, password, confirms password, submits form, is redirected to dashboard or confirmation page
5. Forgot password — user enters email, submits form, receives confirmation that a reset email was sent

## Business Rules
- Email must be a valid format
- Password minimum length: 8 characters
- Registration passwords must match the confirmation field
- After 5 failed login attempts, the account is temporarily locked
- Session persists for 30 days with "Remember me" checked, 24 hours without

## Expected Outcomes (per flow)
| Flow | Success Condition |
|------|-------------------|
| Sign in valid | Redirected to /dashboard; user's name shown in header nav |
| Sign in invalid | Error message "Invalid email or password" shown below form; user stays on /login |
| Sign in empty | Inline error "Required" shown under each empty field; form not submitted |
| Register new account | Redirected to /dashboard or /verify-email; welcome message visible |
| Forgot password | Confirmation "Check your email for a reset link" displayed |

## Out of Scope
- Password change after login (covered in `settings.md`)
- Social login / OAuth flows
- Two-factor authentication (if applicable, create a separate context file)

## Test Data Notes
- A seeded test account is available via WEBAPP_USERNAME / WEBAPP_PASSWORD env vars
- To test registration, generate a unique email per run (e.g. test+<timestamp>@example.com) — duplicate email registration should fail
