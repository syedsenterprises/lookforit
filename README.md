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
