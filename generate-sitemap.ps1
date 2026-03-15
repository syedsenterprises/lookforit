# generate-sitemap.ps1
# Generates sectioned sitemaps for pages, articles, tools, and catalog entries.
# Writes sitemap index files under /sitemaps/index and a master sitemap.xml at the repo root.

param(
    [string]$BaseUrl = "https://lookforit.xyz",
    [string]$OutputFile = "sitemap.xml",
    [int]$CatalogChunkSize = 500
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$sitemapsDir = Join-Path $PSScriptRoot 'sitemaps'
$indexDir = Join-Path $sitemapsDir 'index'

$excludePatterns = @(
    '^admin[/\\]',
    '^dashboard\.html$',
    '^admin-login\.html$',
    '^example-ai-tool\.html$',
    '404\.html$',
    '^assets[/\\]',
    '^Images[/\\]',
    '^comments[/\\]',
    '^contact-responses[/\\]',
    '^listing-requests[/\\]README',
    '^ops[/\\]'
)

$rules = @(
    @{ Pattern = '^index\.html$'; Priority = '1.0'; Freq = 'weekly' },
    @{ Pattern = '^articles[/\\]index\.html$'; Priority = '0.9'; Freq = 'weekly' },
    @{ Pattern = '^tools[/\\]index\.html$'; Priority = '0.9'; Freq = 'weekly' },
    @{ Pattern = '^tools[/\\]catalog[/\\]index\.html$'; Priority = '0.8'; Freq = 'weekly' },
    @{ Pattern = '^articles[/\\]'; Priority = '0.8'; Freq = 'monthly' },
    @{ Pattern = '^tools[/\\]catalog[/\\]'; Priority = '0.7'; Freq = 'monthly' },
    @{ Pattern = '^tools[/\\]'; Priority = '0.7'; Freq = 'monthly' },
    @{ Pattern = '^(ai-writing|ai-image|ai-video|ai-code|ai-voice)[/\\]index\.html$'; Priority = '0.8'; Freq = 'monthly' },
    @{ Pattern = '^listing-requests[/\\]index\.html$'; Priority = '0.7'; Freq = 'monthly' },
    @{ Pattern = '^(about|founder|faq|contact|resources|earn-online|websites)\.html$'; Priority = '0.8'; Freq = 'monthly' },
    @{ Pattern = '.'; Priority = '0.5'; Freq = 'monthly' }
)

function Get-Rule($rel) {
    foreach ($r in $rules) {
        if ($rel -match $r.Pattern) {
            return $r
        }
    }
    return @{ Priority = '0.5'; Freq = 'monthly' }
}

function Get-SitemapGroup($rel) {
    if ($rel -match '^tools[/\\]catalog[/\\]' -and $rel -notmatch '^tools[/\\]catalog[/\\]index\.html$') {
        return 'catalog'
    }

    if ($rel -match '^articles[/\\]') {
        return 'articles'
    }

    if (
        $rel -match '^tools[/\\]' -or
        $rel -match '^(ai-writing|ai-image|ai-video|ai-code|ai-voice)[/\\]index\.html$' -or
        $rel -match '^listing-requests[/\\]index\.html$'
    ) {
        return 'tools'
    }

    return 'pages'
}

function Write-UrlsetFile {
    param(
        [string]$Path,
        [object[]]$Entries
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('<?xml version="1.0" encoding="UTF-8"?>')
    $lines.Add('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"')
    $lines.Add('        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"')
    $lines.Add('        xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9')
    $lines.Add('          http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">')

    foreach ($e in $Entries) {
        $lines.Add('  <url>')
        $lines.Add("    <loc>$($e.Loc)</loc>")
        $lines.Add("    <lastmod>$($e.Lastmod)</lastmod>")
        $lines.Add("    <changefreq>$($e.Freq)</changefreq>")
        $lines.Add("    <priority>$($e.Priority)</priority>")
        $lines.Add('  </url>')
    }

    $lines.Add('</urlset>')
    $lines -join "`n" | Set-Content $Path -Encoding UTF8 -NoNewline
}

function Write-SitemapIndexFile {
    param(
        [string]$Path,
        [string[]]$RelativeFiles,
        [string]$BaseUrl
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('<?xml version="1.0" encoding="UTF-8"?>')
    $lines.Add('<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
    $today = (Get-Date).ToString('yyyy-MM-dd')

    foreach ($file in $RelativeFiles) {
        $url = "$BaseUrl/$($file.Replace('\\', '/'))"
        $lines.Add('  <sitemap>')
        $lines.Add("    <loc>$url</loc>")
        $lines.Add("    <lastmod>$today</lastmod>")
        $lines.Add('  </sitemap>')
    }

    $lines.Add('</sitemapindex>')
    $lines -join "`n" | Set-Content $Path -Encoding UTF8 -NoNewline
}

New-Item -ItemType Directory -Path $sitemapsDir -Force | Out-Null
New-Item -ItemType Directory -Path $indexDir -Force | Out-Null
Get-ChildItem -Path $sitemapsDir -Filter *.xml -File -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force
Get-ChildItem -Path $PSScriptRoot -Filter 'sitemap-tools-catalog*.xml' -File -ErrorAction SilentlyContinue | Remove-Item -Force

$htmlFiles = Get-ChildItem -Recurse -Filter '*.html' | Where-Object { $_.FullName -notmatch '\\.git\\' }
$groupedEntries = @{
    pages = [System.Collections.Generic.List[object]]::new()
    articles = [System.Collections.Generic.List[object]]::new()
    tools = [System.Collections.Generic.List[object]]::new()
    catalog = [System.Collections.Generic.List[object]]::new()
}

foreach ($f in $htmlFiles) {
    $rel = $f.FullName.Replace($PSScriptRoot + '\', '').Replace('\', '/')

    $skip = $false
    foreach ($pat in $excludePatterns) {
        if ($rel -match $pat) {
            $skip = $true
            break
        }
    }
    if ($skip) {
        continue
    }

    $content = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -match 'content\s*=\s*"[^"]*noindex[^"]*"') {
        continue
    }

    $urlPath = $rel
    if ($urlPath -eq 'index.html') {
        $urlPath = ''
    }
    elseif ($urlPath -match '^(.+[/])index\.html$') {
        $urlPath = $Matches[1]
    }

    $url = if ($urlPath) { "$BaseUrl/$urlPath" } else { "$BaseUrl/" }
    $rule = Get-Rule $rel
    $entry = [PSCustomObject]@{
        Rel = $rel
        Loc = $url
        Lastmod = $f.LastWriteTime.ToString('yyyy-MM-dd')
        Freq = $rule.Freq
        Priority = $rule.Priority
    }

    $group = Get-SitemapGroup $rel
    $groupedEntries[$group].Add($entry)
}

$pagesEntries = $groupedEntries.pages | Sort-Object { -[double]$_.Priority }, Loc
$articlesEntries = $groupedEntries.articles | Sort-Object { -[double]$_.Priority }, Loc
$toolsEntries = $groupedEntries.tools | Sort-Object { -[double]$_.Priority }, Loc
$catalogEntries = $groupedEntries.catalog | Sort-Object Loc

$contentFiles = [System.Collections.Generic.List[string]]::new()

if ($pagesEntries.Count -gt 0) {
    Write-UrlsetFile -Path (Join-Path $sitemapsDir 'pages.xml') -Entries $pagesEntries
    $contentFiles.Add('sitemaps/pages.xml')
}

if ($articlesEntries.Count -gt 0) {
    Write-UrlsetFile -Path (Join-Path $sitemapsDir 'articles.xml') -Entries $articlesEntries
    $contentFiles.Add('sitemaps/articles.xml')
}

if ($toolsEntries.Count -gt 0) {
    Write-UrlsetFile -Path (Join-Path $sitemapsDir 'tools.xml') -Entries $toolsEntries
    $contentFiles.Add('sitemaps/tools.xml')
}

$catalogFiles = [System.Collections.Generic.List[string]]::new()
if ($catalogEntries.Count -gt 0) {
    $chunks = [Math]::Ceiling($catalogEntries.Count / [double]$CatalogChunkSize)
    for ($i = 0; $i -lt $chunks; $i++) {
        $chunkEntries = $catalogEntries | Select-Object -Skip ($i * $CatalogChunkSize) -First $CatalogChunkSize
        $relativeFile = 'sitemaps/catalog-{0}.xml' -f ($i + 1)
        $targetPath = Join-Path $PSScriptRoot $relativeFile
        Write-UrlsetFile -Path $targetPath -Entries $chunkEntries
        $catalogFiles.Add($relativeFile)
    }
}

$masterIndexFiles = [System.Collections.Generic.List[string]]::new()
if ($contentFiles.Count -gt 0) {
    Write-SitemapIndexFile -Path (Join-Path $indexDir 'content.xml') -RelativeFiles $contentFiles -BaseUrl $BaseUrl
    $masterIndexFiles.Add('sitemaps/index/content.xml')
}

if ($catalogFiles.Count -gt 0) {
    Write-SitemapIndexFile -Path (Join-Path $indexDir 'catalog.xml') -RelativeFiles $catalogFiles -BaseUrl $BaseUrl
    $masterIndexFiles.Add('sitemaps/index/catalog.xml')
}

Write-SitemapIndexFile -Path (Join-Path $PSScriptRoot $OutputFile) -RelativeFiles $masterIndexFiles -BaseUrl $BaseUrl

Write-Host "SITEMAP_GENERATED_PAGES: $($pagesEntries.Count) URLs -> sitemaps/pages.xml"
Write-Host "SITEMAP_GENERATED_ARTICLES: $($articlesEntries.Count) URLs -> sitemaps/articles.xml"
Write-Host "SITEMAP_GENERATED_TOOLS: $($toolsEntries.Count) URLs -> sitemaps/tools.xml"
Write-Host "SITEMAP_GENERATED_CATALOG: $($catalogEntries.Count) URLs -> $($catalogFiles.Count) files"
Write-Host "SITEMAP_INDEX_CONTENT: sitemaps/index/content.xml"
if ($catalogFiles.Count -gt 0) {
    Write-Host "SITEMAP_INDEX_CATALOG: sitemaps/index/catalog.xml"
}
Write-Host "SITEMAP_INDEX_MASTER: $OutputFile"
