# Cloudflare Full Hardening Guide — lookforit.xyz

This document covers every Cloudflare layer you should configure for:
- Admin page server-side protection (Zero Trust Access)
- Visitor human verification (Turnstile)
- Security response headers
- WAF custom rules
- Bot Fight Mode + DDoS
- Rate limiting
- Page Rules / Redirect Rules

---

## 1. Cloudflare Zero Trust Access — Admin Protection

This is the ONLY way to truly protect `/admin/` on a static site. The JS gate in
`admin-access.js` is a UX layer — Cloudflare Access is the real enforcement.

### Steps
1. Go to **Cloudflare Dashboard → Zero Trust → Access → Applications**
2. Click **"Add an application" → Self-hosted**
3. Fill in:
   - Application name: `Lookforit Admin`
   - Session duration: `12 hours`
   - Application domain: `lookforit.xyz` Path: `/admin/*`
4. Add a second rule for redirect wrappers (optional):
   - Application domain: `lookforit.xyz` Path: `/dashboard.html`
   - Application domain: `lookforit.xyz` Path: `/admin-login.html`
5. Policy → **Allow**:
   - Rule: Emails → `syedsinterprises@gmail.com`
6. Policy → **Block Everyone Else** (add a Catch-all Deny block policy)
7. Under **Settings → Cookie settings**: enable `HttpOnly`, `SameSite=Lax`
8. Save and test from an incognito window — you should be redirected to Cloudflare's
   login challenge before seeing any admin HTML.

---

## 2. Cloudflare Turnstile — Human Verification on Forms

### Get your Site Key
1. Go to **Cloudflare Dashboard → Turnstile → Add Site**
2. Site name: `lookforit.xyz contact & listing forms`
3. Domain: `lookforit.xyz`
4. Widget type: **Managed** (recommended — invisible to real users, challenges bots)
5. Copy the **Site Key** and **Secret Key**

### Plug in the Site Key (client-side)
In `contact.html` and `listing-requests/index.html` replace the placeholder:
```html
<div class="cf-turnstile" data-sitekey="REPLACE_WITH_TURNSTILE_SITE_KEY" data-theme="dark"></div>
```
with:
```html
<div class="cf-turnstile" data-sitekey="YOUR_REAL_SITE_KEY" data-theme="dark"></div>
```

### Server-side validation (Formspree / Webhook)
If using Formspree, Turnstile is purely cosmetic unless Formspree validates it.
For real validation connect a Cloudflare Worker:
```js
// verify-turnstile.js (Cloudflare Worker)
export default {
  async fetch(request) {
    const body = await request.formData();
    const token = body.get('cf-turnstile-response');
    const secret = 'YOUR_TURNSTILE_SECRET_KEY'; // set as Worker secret
    const res = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ secret, response: token })
    });
    const data = await res.json();
    if (!data.success) return new Response('Forbidden', { status: 403 });
    // Forward to Formspree or handle submission here
  }
};
```

---

## 3. Security Response Headers

Add via **Cloudflare Dashboard → Rules → Transform Rules → Modify Response Headers**
Create one rule: **"All requests" (always)** with the following headers:

| Header | Value |
|---|---|
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains; preload` |
| `X-Content-Type-Options` | `nosniff` |
| `X-Frame-Options` | `SAMEORIGIN` |
| `Referrer-Policy` | `strict-origin-when-cross-origin` |
| `Permissions-Policy` | `camera=(), microphone=(), geolocation=(), payment=()` |
| `X-XSS-Protection` | `1; mode=block` |

### Content Security Policy (separate rule for HTML only)
Match: `http.response.content_type contains "text/html"`
```
Content-Security-Policy:
  default-src 'self';
  script-src 'self' 'unsafe-inline' https://challenges.cloudflare.com;
  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
  font-src 'self' https://fonts.gstatic.com;
  img-src 'self' data: https://www.google.com https://via.placeholder.com;
  connect-src 'self' https://formspree.io;
  frame-src https://challenges.cloudflare.com;
  frame-ancestors 'self';
  base-uri 'self';
  form-action 'self' https://formspree.io;
  upgrade-insecure-requests;
```

---

## 4. WAF Custom Rules

Go to **Cloudflare Dashboard → Security → WAF → Custom Rules**

### Rule 1 — Block admin paths from non-authenticated requests
Only needed if NOT using Cloudflare Access.
```
Field: URI Path
Operator: starts with
Value: /admin/
Action: Block
```

### Rule 2 — Block common exploit scanners
```
Expression:
(http.request.uri contains "wp-admin") or
(http.request.uri contains "wp-login") or
(http.request.uri contains "xmlrpc") or
(http.request.uri contains ".env") or
(http.request.uri contains "/.git/") or
(http.request.uri contains "/etc/passwd")

Action: Block
```

### Rule 3 — Block suspicious User-Agents
```
Expression:
(http.user_agent contains "sqlmap") or
(http.user_agent contains "nikto") or
(http.user_agent contains "masscan") or
(http.user_agent contains "zgrab") or
(lower(http.user_agent) contains "python-requests" and
  not http.request.uri.path starts with "/api/")

Action: Block
```

### Rule 4 — Rate limit form submissions
Go to **Security → WAF → Rate Limiting Rules**
```
Match: URI Path equals /contact.html OR /listing-requests/
       AND Method equals POST
Rate:  5 requests per 60 seconds per IP
Action: Block for 600 seconds
```

---

## 5. Bot Fight Mode

1. Go to **Security → Bots**
2. Enable **Bot Fight Mode** (free tier) — blocks known bad bots
3. If on Pro plan: enable **Super Bot Fight Mode** with:
   - Definitely automated → Block
   - Likely automated → Managed Challenge
   - Verified bots → Allow

---

## 6. DDoS Protection

1. Go to **Security → DDoS**
2. Set HTTP DDoS Attack Protection to **High Sensitivity**
3. Enable **Advanced DDoS Protection** if on Pro/Business

---

## 7. Page Rules / Redirect Rules

Go to **Rules → Redirect Rules** and set:

| From | To | Type |
|---|---|---|
| `lookforit.xyz/admin-login.html` | `lookforit.xyz/admin/login.html` | 301 |
| `lookforit.xyz/dashboard.html` | `lookforit.xyz/admin/dashboard.html` | 301 |
| `http://lookforit.xyz/*` | `https://lookforit.xyz/$1` | 301 |
| `http://www.lookforit.xyz/*` | `https://lookforit.xyz/$1` | 301 |

---

## 8. SSL / TLS Settings

1. **SSL/TLS → Overview**: Set mode to **Full (strict)**
2. **Edge Certificates → Always Use HTTPS**: ON
3. **Edge Certificates → HSTS**: Enable, max-age 1 year, includeSubDomains, Preload
4. **Edge Certificates → Minimum TLS Version**: TLS 1.2
5. **Edge Certificates → Opportunistic Encryption**: ON
6. **Edge Certificates → TLS 1.3**: ON

---

## 9. Caching (Performance)

1. **Caching → Configuration → Browser Cache TTL**: 4 hours
2. **Rules → Cache Rules**: Cache everything for:
   - `*.html` → TTL 1 hour, Edge TTL 4 hours
   - `assets/*` → TTL 30 days, Edge TTL 30 days
3. **Speed → Optimization → Auto Minify**: CSS + JS + HTML
4. **Speed → Optimization → Brotli**: ON

---

## 10. Post-Setup Verification Checklist

- [ ] Visit `https://lookforit.xyz/admin/dashboard.html` in incognito → Zero Trust challenge appears
- [ ] Visit `https://lookforit.xyz/contact.html` → Turnstile widget renders
- [ ] Run `curl -I https://lookforit.xyz` → confirm HSTS, X-Frame-Options headers present
- [ ] Run site through `https://securityheaders.com` → target A or A+ grade
- [ ] Test WAF rule: `curl https://lookforit.xyz/?id=1' OR 1=1--` → should get 403
- [ ] Verify sitemap: `https://lookforit.xyz/sitemap.xml` → no admin URLs, all real pages
- [ ] Verify robots.txt disallows /admin/ correctly
