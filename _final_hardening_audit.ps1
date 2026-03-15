$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$htmlFiles = Get-ChildItem -Recurse -Filter *.html
$toolFiles = Get-ChildItem tools\*.html
$articleFiles = Get-ChildItem articles\*.html | Where-Object { $_.Name -ne 'index.html' }

$formsWorker = Select-String -Path contact.html, listing-requests\index.html -Pattern 'data-worker-action="/form-proxy"' | Measure-Object | Select-Object -ExpandProperty Count
$turnstileCount = Select-String -Path contact.html, listing-requests\index.html -Pattern 'class="cf-turnstile"' | Measure-Object | Select-Object -ExpandProperty Count

$adminExist = (Test-Path admin\login.html) -and (Test-Path admin\dashboard.html) -and (Test-Path dashboard.html)
$adminDashHasGuard = Select-String -Path admin\dashboard.html -Pattern 'admin-access\.js' -Quiet
$adminLoginHasGuard = Select-String -Path admin\login.html -Pattern 'admin-access\.js' -Quiet
$dashboardRedirects = Select-String -Path dashboard.html -Pattern '/admin/dashboard\.html' -Quiet

$sitemapFiles = @('sitemap.xml')
if (Test-Path sitemaps) {
  $sitemapFiles += Get-ChildItem sitemaps -Recurse -Filter *.xml | ForEach-Object { $_.FullName }
}
$sitemap = ($sitemapFiles | Where-Object { Test-Path $_ } | ForEach-Object { Get-Content $_ -Raw }) -join "`n"
$toolMissing = @()
foreach ($f in $toolFiles) {
  if ($f.Name -eq 'example-ai-tool.html' -or $f.Name -eq 'index.html') { continue }
  $u = "https://lookforit.xyz/tools/$($f.Name)"
  if ($sitemap -notmatch [regex]::Escape($u)) { $toolMissing += $f.Name }
}
$articleMissing = @()
foreach ($f in $articleFiles) {
  $u = "https://lookforit.xyz/articles/$($f.Name)"
  if ($sitemap -notmatch [regex]::Escape($u)) { $articleMissing += $f.Name }
}

$articlesMissingJsonLd = @()
foreach ($f in $articleFiles) {
  if (-not (Select-String -Path $f.FullName -Pattern 'application/ld\+json' -Quiet)) { $articlesMissingJsonLd += $f.Name }
}

$toolsMissingSoftware = @()
foreach ($f in $toolFiles) {
  if ($f.Name -eq 'index.html') { continue }
  if (-not (Select-String -Path $f.FullName -Pattern '"@type"\s*:\s*"SoftwareApplication"' -Quiet)) { $toolsMissingSoftware += $f.Name }
}

$pagesWithQuery = 0
$pagesMissingSidebarScripts = @()
foreach ($f in $htmlFiles) {
  $raw = Get-Content $f.FullName -Raw
  if ($raw -match 'id="query"') {
    $pagesWithQuery++
    if ($raw -notmatch 'sidebar-search\.js' -or $raw -notmatch 'tools-data\.js') { $pagesMissingSidebarScripts += $f.FullName }
  }
}

$missingCanonical = @()
foreach ($f in $htmlFiles) {
  if (-not (Select-String -Path $f.FullName -Pattern '<link\s+rel="canonical"' -Quiet)) { $missingCanonical += $f.FullName }
}

$noindexFiles = @()
$repoRoot = (Get-Location).Path
$repoRootPrefix = ($repoRoot -replace '[\\/]+$', '') + '\'
$repoRootPrefixRegex = [regex]::Escape($repoRootPrefix)
foreach ($f in $htmlFiles) {
  if (Select-String -Path $f.FullName -Pattern 'content="[^"]*noindex[^"]*"' -Quiet) {
    $rel = ($f.FullName -replace "(?i)^$repoRootPrefixRegex", '').Replace('\', '/')
    $noindexFiles += $rel
  }
}
$allowedNoindex = @('admin/login.html','admin/dashboard.html','dashboard.html','admin-login.html')
$unexpectedNoindex = $noindexFiles | Where-Object { $allowedNoindex -notcontains $_ }

"FORMS_WORKER_ACTION_COUNT=$formsWorker"
"TURNSTILE_WIDGET_COUNT=$turnstileCount"
"ADMIN_FILES_OK=$adminExist"
"ADMIN_DASH_GUARD_OK=$adminDashHasGuard"
"ADMIN_LOGIN_GUARD_OK=$adminLoginHasGuard"
"DASHBOARD_REDIRECT_OK=$dashboardRedirects"
"SITEMAP_MISSING_TOOLS=$($toolMissing.Count)"
if ($toolMissing.Count -gt 0) { "SITEMAP_MISSING_TOOLS_LIST=$($toolMissing -join ',')" }
"SITEMAP_MISSING_ARTICLES=$($articleMissing.Count)"
if ($articleMissing.Count -gt 0) { "SITEMAP_MISSING_ARTICLES_LIST=$($articleMissing -join ',')" }
"ARTICLES_MISSING_JSONLD=$($articlesMissingJsonLd.Count)"
if ($articlesMissingJsonLd.Count -gt 0) { "ARTICLES_MISSING_JSONLD_LIST=$($articlesMissingJsonLd -join ',')" }
"TOOLS_MISSING_SOFTWARE_SCHEMA=$($toolsMissingSoftware.Count)"
if ($toolsMissingSoftware.Count -gt 0) { "TOOLS_MISSING_SCHEMA_LIST=$($toolsMissingSoftware -join ',')" }
"PAGES_WITH_SIDEBAR_QUERY=$pagesWithQuery"
"PAGES_MISSING_SIDEBAR_SCRIPTS=$($pagesMissingSidebarScripts.Count)"
"MISSING_CANONICAL_COUNT=$($missingCanonical.Count)"
"UNEXPECTED_NOINDEX_COUNT=$($unexpectedNoindex.Count)"
if ($unexpectedNoindex.Count -gt 0) { "UNEXPECTED_NOINDEX_LIST=$($unexpectedNoindex -join ',')" }
"NOINDEX_FILES=$($noindexFiles -join ',')"
