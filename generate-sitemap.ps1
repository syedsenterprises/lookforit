# generate-sitemap.ps1
# Regenerates sitemap.xml from all indexable HTML files in the workspace.
# Run from the repo root: ./generate-sitemap.ps1
# Adds a <changefreq> and <priority> based on file path tier.

param(
    [string]$BaseUrl   = "https://lookforit.xyz",
    [string]$OutputFile = "sitemap.xml"
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# ---------------------------------------------------------------------------
# Config: paths to EXCLUDE from the sitemap
# ---------------------------------------------------------------------------
$excludePatterns = @(
    "^admin[/\\]",          # /admin/ protected pages
    "^dashboard\.html$",    # legacy redirect wrapper
    "^admin-login\.html$",  # legacy redirect wrapper
    "^example-ai-tool\.html$",   # template page
    "404\.html$",
    "^assets[/\\]",
    "^Images[/\\]",
    "^comments[/\\]",
    "^contact-responses[/\\]",
    "^listing-requests[/\\]README",
    "^ops[/\\]"
)

# ---------------------------------------------------------------------------
# Priority + changefreq rules (first match wins)
# ---------------------------------------------------------------------------
$rules = @(
    @{ Pattern = '^index\.html$';            Priority = "1.0"; Freq = "weekly" },
    @{ Pattern = '^(about|founder)\.html$';  Priority = "0.8"; Freq = "monthly" },
    @{ Pattern = '^articles[/\\]index\.html$'; Priority = "0.9"; Freq = "weekly" },
    @{ Pattern = '^articles[/\\]';           Priority = "0.8"; Freq = "monthly" },
    @{ Pattern = '^tools[/\\]index\.html$';  Priority = "0.9"; Freq = "weekly" },
    @{ Pattern = '^tools[/\\]';              Priority = "0.7"; Freq = "monthly" },
    @{ Pattern = '^listing-requests[/\\]';   Priority = "0.7"; Freq = "monthly" },
    @{ Pattern = '.';                        Priority = "0.5"; Freq = "monthly" }
)

function Get-Rule($rel) {
    foreach ($r in $rules) {
        if ($rel -match $r.Pattern) { return $r }
    }
    return @{ Priority = "0.5"; Freq = "monthly" }
}

# ---------------------------------------------------------------------------
# Collect files
# ---------------------------------------------------------------------------
$htmlFiles = Get-ChildItem -Recurse -Filter "*.html" |
    Where-Object { $_.FullName -notmatch '\\\.git\\' }

$entries = [System.Collections.Generic.List[object]]::new()

foreach ($f in $htmlFiles) {
    $rel = $f.FullName.Replace($PSScriptRoot + "\", "").Replace("\", "/")

    # Skip excluded patterns
    $skip = $false
    foreach ($pat in $excludePatterns) {
        if ($rel -match $pat) { $skip = $true; break }
    }
    if ($skip) { continue }

    # Check for noindex meta tag — skip if present
    $content = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -match 'content\s*=\s*"[^"]*noindex[^"]*"') { continue }

    # Build URL — directory index.html becomes trailing-slash URL
    $urlPath = $rel
    if ($urlPath -eq "index.html") {
        $urlPath = ""
    } elseif ($urlPath -match "^(.+[/])index\.html$") {
        $urlPath = $Matches[1]
    }

    $url = if ($urlPath) { "$BaseUrl/$urlPath" } else { "$BaseUrl/" }

    $rule = Get-Rule $rel
    $lastmod = $f.LastWriteTime.ToString("yyyy-MM-dd")

    $entries.Add([PSCustomObject]@{
        Loc      = $url
        Lastmod  = $lastmod
        Freq     = $rule.Freq
        Priority = $rule.Priority
    })
}

# Sort: priority desc, then alpha
$entries = $entries | Sort-Object { -[double]$_.Priority }, Loc

# ---------------------------------------------------------------------------
# Write XML
# ---------------------------------------------------------------------------
$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('<?xml version="1.0" encoding="UTF-8"?>')
$lines.Add('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"')
$lines.Add('        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"')
$lines.Add('        xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9')
$lines.Add('          http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">')

foreach ($e in $entries) {
    $lines.Add("  <url>")
    $lines.Add("    <loc>$($e.Loc)</loc>")
    $lines.Add("    <lastmod>$($e.Lastmod)</lastmod>")
    $lines.Add("    <changefreq>$($e.Freq)</changefreq>")
    $lines.Add("    <priority>$($e.Priority)</priority>")
    $lines.Add("  </url>")
}
$lines.Add('</urlset>')

$lines -join "`n" | Set-Content $OutputFile -Encoding UTF8 -NoNewline

Write-Host "SITEMAP_GENERATED: $($entries.Count) URLs -> $OutputFile"
