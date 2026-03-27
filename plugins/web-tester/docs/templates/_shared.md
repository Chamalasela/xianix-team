---
type: web-test-shared
---

## About This Application
SuperOffice App Store is a marketplace where SuperOffice CRM users discover, install, and manage third-party integrations. Key user types: end users browsing
apps, developers publishing apps, and admins managing tenant installations.
Tech stack: React SPA, REST API backend, OAuth 2.0 authentication via SuperOffice IDP.


## Authentication States
- **Logged out**: No session cookie; protected routes redirect to the login page
- **Logged in (standard user)**: Access to main application pages
- **Logged in (admin)**: Additional access to admin areas

## Common Test Data
- Standard user: WEBAPP_USERNAME / WEBAPP_PASSWORD env vars
- Invalid email format: not-an-email
- Max-length string: aaaa...a (255 characters)
- Empty/blank string: (empty)

## Navigation Structure
- Describe your app's main navigation here
- Example: Top nav contains Home, Dashboard, Profile, Settings, Logout

## Error Display Patterns
- Describe how validation errors appear in your app
- Example: Inline below the field with red border on the input
- Describe how server errors appear
- Example: Toast notification top-right, message "Something went wrong"
