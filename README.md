# LOOKFORIT
A directory to discover the best AI tools, useful websites, and online resources.

## Publish New Articles Without Writing HTML

You can now write article content in plain text and generate full HTML automatically.

### 1. Write your article draft

Use this file as your starter format:

- article-draft-template.txt

Format rules:

- Use "## " for H2 headings
- Use "### " for H3 headings
- Use "- " for bullet points
- Keep normal lines as paragraph text
- You can use links like: [Label](../tools/chatgpt.html)

### 2. Run the generator

From the project root, run this PowerShell command:

powershell -ExecutionPolicy Bypass -File .\create-article.ps1 -Title "Your Article Title" -Slug "your-article-slug-2026" -Description "Short SEO description" -BodyFile ".\article-draft-template.txt" -ImagePath "../Images/pic07.svg" -ImageAlt "Cover image alt text" -PublishedText "Published March 2026"

### 3. Output location

Your new article file will be created at:

- articles/your-article-slug-2026.html

The generator automatically includes:

- Full article HTML template
- Header and sidebar
- Breadcrumb schema
- Article schema
- Author box
- Footer and scripts

The generator also automatically adds your new article card to:

- articles/index.html

If you want to skip index update in a specific run, add:

-UpdateIndex $false

### 4. Publish

After the script runs, your article file and listing card are both ready.

## Future-Ready Content Dashboard

An internal dashboard is available for fast draft generation and script integration:

- admin/dashboard.html

What it gives you:

- Structured form to build article draft text
- One-click draft text generation
- Script payload JSON output for automation
- Download and copy actions for draft text
- Publish bridge contract via `Publish Now (Bridge)`
- Automatic snapshot history before export/publish actions
- Modular integration API for future scripts

### Script integration API

The dashboard exposes a global object:

- window.LookforitDashboard

Available methods:

- registerScriptAdapter(name, handler)
- invokeScriptAdapter(name, payload)
- readDashboardState()
- buildDraftText(state)
- buildScriptPayload(state, draftText)

It also emits events you can listen to:

- lookforit:draft-generated
- lookforit:payload-generated
- lookforit:draft-downloaded
- lookforit:draft-copied
- lookforit:draft-copy-failed

## Admin Access

Admin routes are now under:

- admin/login.html
- admin/dashboard.html

Legacy paths redirect to admin routes:

- admin-login.html -> /admin/login.html
- dashboard.html -> /admin/dashboard.html

Client-side session gate is in:

- assets/js/admin-access.js

Security and hosting hardening guide:

- ADMIN_SECURITY.md

## CI Quality Gate

Site quality checks are automated with:

- qa-site.ps1
- .github/workflows/site-quality.yml

## One-Command Full Audit

Run a complete local validation sweep with:

powershell -ExecutionPolicy Bypass -File .\full-audit.ps1

Optional flags:

- Rebuild catalog index before checks:

powershell -ExecutionPolicy Bypass -File .\full-audit.ps1 -RebuildCatalogIndex

- Build curated batch before checks:

powershell -ExecutionPolicy Bypass -File .\full-audit.ps1 -BuildCuratedBatch

- Build curated batch with custom size/output:

powershell -ExecutionPolicy Bypass -File .\full-audit.ps1 -BuildCuratedBatch -CuratedTargetCount 300 -CuratedOutputFile "tools/catalog/catalog-data.curated-300.csv"

The script runs:

- generate-sitemap.ps1
- qa-site.ps1
- _final_hardening_audit.ps1

## Monetization Automation

The site now includes automation to help with AdSense readiness, revenue tracking, and growth execution.

### 1. Monetization Runtime

Runtime files:

- assets/js/monetization-config.js
- assets/js/monetization-automation.js

The runtime is loaded automatically from:

- assets/js/main.js

What it does:

- Tracks outbound clicks, CTA clicks, and affiliate-like clicks to GA4 events.
- Supports optional AdSense script and ad slot injection on key page types.
- Supports optional auto-marking affiliate links with sponsored/nofollow rel values.

### 2. AdSense Readiness Audit

Run:

powershell -ExecutionPolicy Bypass -File .\ops\monetization\adsense-readiness-audit.ps1

Output:

- ops/monetization/adsense-readiness-report.md

### 3. Growth Backlog Automation

Run:

powershell -ExecutionPolicy Bypass -File .\ops\monetization\growth-automation.ps1 -TopN 60

Outputs:

- ops/monetization/growth-backlog.csv
- ops/monetization/growth-backlog-summary.md

Use the CSV as your weekly execution board for:

- Money page optimization
- Article refreshes
- New commercial-intent articles

### 4. Weekly SEO Engine (3 New + 10 Refresh)

Run draft + refresh workflow:

powershell -ExecutionPolicy Bypass -File .\weekly-seo-engine.ps1 -NewArticleCount 3 -RefreshCount 10

Run and publish 3 new commercial-intent articles from backlog:

powershell -ExecutionPolicy Bypass -File .\weekly-seo-engine.ps1 -NewArticleCount 3 -RefreshCount 10 -PublishNew

Output:

- ops/monetization/weekly-seo-engine-report.md

### 5. CTR Rewriter (Top 50 Pages)

Run:

powershell -ExecutionPolicy Bypass -File .\seo-ctr-rewrite.ps1 -TopN 50

### 6. Affiliate Block Generator

Run:

powershell -ExecutionPolicy Bypass -File .\generate-affiliate-blocks.ps1 -TopN 30

### 7. Weekly Money-Machine Cadence

1) Refresh AdSense readiness score:

powershell -ExecutionPolicy Bypass -File .\adsense-readiness-audit.ps1

2) Refresh growth backlog:

powershell -ExecutionPolicy Bypass -File .\growth-automation.ps1 -TopN 60

3) Execute weekly content system:

powershell -ExecutionPolicy Bypass -File .\weekly-seo-engine.ps1 -NewArticleCount 3 -RefreshCount 10 -PublishNew

4) Improve SERP CTR on money pages:

powershell -ExecutionPolicy Bypass -File .\seo-ctr-rewrite.ps1 -TopN 50

5) Standardize monetization blocks:

powershell -ExecutionPolicy Bypass -File .\generate-affiliate-blocks.ps1 -TopN 30

### 8. Weekly KPI Export (Revenue Snapshot)

Run:

powershell -ExecutionPolicy Bypass -File .\weekly-kpi-report.ps1

Outputs:

- ops/monetization/weekly-kpi-report.md
- ops/monetization/weekly-kpi-report.csv

### 9. Hot Page Boost (CTR + Affiliate + CTA Variants)

Run:

powershell -ExecutionPolicy Bypass -File .\hot-page-boost.ps1 -TopN 30

Outputs:

- ops/monetization/hot-page-boost-report.md
- ops/monetization/hot-page-cta-variants.csv

### 10. One-Command Weekly Revenue Ops

Run full weekly revenue machine:

powershell -ExecutionPolicy Bypass -File .\weekly-revenue-ops.ps1 -BacklogTopN 60 -BoostTopN 30

Optional: include SEO engine in the same run:

powershell -ExecutionPolicy Bypass -File .\weekly-revenue-ops.ps1 -BacklogTopN 60 -BoostTopN 30 -RunSeoEngine -SeoNewArticleCount 1 -SeoRefreshCount 5

Output:

- ops/monetization/weekly-revenue-ops-report.md

## Indexing Automation

### 1. Submit sitemaps and generate indexing reports

Run:

powershell -ExecutionPolicy Bypass -File .\post-publish-indexing.ps1 -InspectMaxUrls 120

Outputs:

- ops/seo/sitemap-submit-report.md
- ops/seo/search-console-inspection-report.md
- ops/seo/search-console-inspection.csv

### 2. Run each indexing step separately

Sitemap submission workflow:

powershell -ExecutionPolicy Bypass -File .\submit-sitemaps.ps1

Search Console inspection export workflow:

powershell -ExecutionPolicy Bypass -File .\search-console-export.ps1 -MaxUrls 150

Optional: enable automatic URL Inspection API checks by setting a token:

$env:GSC_OAUTH_TOKEN = 'ya29....'
