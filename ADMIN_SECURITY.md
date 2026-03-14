# Admin Security Hardening

This project now includes client-side admin gating for:

- /admin/login.html
- /admin/dashboard.html

## Important

Client-side checks improve privacy and workflow control, but true access control must be enforced at hosting/server level.

## Hosting-Level Options

### Cloudflare Access (recommended)

1. Add your site to Cloudflare Zero Trust.
2. Protect path `/admin/*` with an Access application.
3. Allow only your verified identity provider users.
4. Keep `/admin/` blocked in `robots.txt` (already configured).

### Apache (example)

Use an `.htaccess` rule for `/admin/` with Basic Auth or SSO module.

### IIS (example)

Use URL Authorization rules in `web.config` for `/admin/*` and require authenticated users.

## Admin Session Behavior

Managed in `assets/js/admin-access.js`:

- password-hash login validation
- session expiration (12h)
- role-ready permission map (`admin`, `editor`, `viewer`)
- local analytics event tracking for login/block/logout

## Dashboard Publish Bridge

`assets/js/content-dashboard.js` supports one-click publish contract:

- UI button: `Publish Now (Bridge)`
- If `window.LookforitPublishBridge.submit(request)` exists, it sends a structured publish request.
- Fallback: downloads `*-publish-request.json`.

### Request Payload Shape

```json
{
  "requestedAt": "ISO timestamp",
  "slug": "article-slug",
  "title": "Article title",
  "roleRequired": "admin",
  "source": "dashboard",
  "command": "powershell ...",
  "payload": { "...": "..." },
  "draftText": "..."
}
```

## CI Quality Checks

A GitHub Actions workflow now runs `qa-site.ps1` on push and PR to catch:

- broken internal links/assets
- missing canonical/description/og/twitter tags
- encoding artifact patterns
