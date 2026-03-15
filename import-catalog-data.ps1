param(
  [string]$InputFile = "tools/catalog/catalog-data.sample.csv",
  [ValidateSet('csv','json')][string]$Format = "csv"
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (-not (Test-Path $InputFile)) {
  throw "Input file not found: $InputFile"
}

$catalogDir = Join-Path $PSScriptRoot 'tools/catalog'
if (-not (Test-Path $catalogDir)) {
  New-Item -ItemType Directory -Path $catalogDir | Out-Null
}

$categoryMap = @{
  'AI Writing'      = '/ai-writing/'
  'AI Image'        = '/ai-image/'
  'AI Video'        = '/ai-video/'
  'AI Code'         = '/ai-code/'
  'AI Voice'        = '/ai-voice/'
  'AI Productivity' = '/tools/category/productivity.html'
  'AI Assistant'    = '/tools/category/ai-assistant.html'
  'AI Automation'   = '/tools/category/automation.html'
}

function Slugify([string]$text) {
  $slug = $text.ToLower() -replace '[^a-z0-9]+', '-'
  return $slug.Trim('-')
}

function Test-HttpUrl([string]$Value) {
  if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
  return $Value -match '^https?://'
}

function Get-NormalizedStatus([string]$Value) {
  if ([string]::IsNullOrWhiteSpace($Value)) { return 'verified' }
  $v = $Value.Trim().ToLower()
  switch ($v) {
    'verified' { return 'verified' }
    'verified-existing' { return 'verified-existing' }
    'curated-trending' { return 'curated-trending' }
    'curated-expansion' { return 'curated-expansion' }
    'generated-profile' { return 'generated-profile' }
    default { return 'verified' }
  }
}

function Get-NormalizedDate([string]$Value) {
  if ([string]::IsNullOrWhiteSpace($Value)) { return (Get-Date).ToString('yyyy-MM-dd') }
  [datetime]$parsed = [datetime]::MinValue
  if ([DateTime]::TryParse($Value, [ref]$parsed)) {
    return $parsed.ToString('yyyy-MM-dd')
  }
  return (Get-Date).ToString('yyyy-MM-dd')
}

$rows = if ($Format -eq 'csv') {
  Import-Csv $InputFile
} else {
  Get-Content $InputFile -Raw | ConvertFrom-Json
}

$written = 0
foreach ($r in $rows) {
  if (-not $r.name) { continue }
  $name = [string]$r.name
  $slug = Slugify $name
  $category = if ($r.category) { [string]$r.category } else { 'AI Assistant' }
  $description = if ($r.description) { [string]$r.description } else { "$name profile and practical usage guide on Lookforit.xyz." }
  $websiteRaw = if ($r.website) { [string]$r.website } else { '' }
  $website = if (Test-HttpUrl $websiteRaw) { $websiteRaw } else { "https://lookforit.xyz/tools/$($slug).html" }
  $status = Get-NormalizedStatus ([string]$r.status)
  $updatedAt = Get-NormalizedDate ([string]$r.updatedAt)
  $catLink = if ($categoryMap.ContainsKey($category)) { $categoryMap[$category] } else { '/tools/' }
  $canon = "https://lookforit.xyz/tools/catalog/$slug.html"
  $safeDesc = $description.Replace('"','&quot;')

  $page = @"
<!DOCTYPE HTML>
<html lang="en">
<head>
<title>$name - $category Tool Profile - Lookforit.xyz</title>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
<meta name="robots" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
<meta name="googlebot" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
<meta name="theme-color" content="#0f172a" />
<meta name="description" content="$safeDesc" />
<link rel="canonical" href="$canon" />
<meta property="og:title" content="$name - $category Tool Profile - Lookforit.xyz" />
<meta property="og:description" content="$safeDesc" />
<meta property="og:type" content="article" />
<meta property="og:url" content="$canon" />
<meta property="og:image" content="https://lookforit.xyz/Images/ai-tools-2026.jpg" />
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="$name - $category Tool Profile - Lookforit.xyz" />
<meta name="twitter:description" content="$safeDesc" />
<meta name="twitter:image" content="https://lookforit.xyz/Images/ai-tools-2026.jpg" />
<link rel="stylesheet" href="../../assets/css/main.css?v=20260315-structure2" />
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "$name",
  "applicationCategory": "$category",
  "description": "$safeDesc",
  "url": "$canon",
  "dateModified": "$updatedAt"
}
</script>
</head>
<body class="is-preload">
<div id="wrapper"><div id="main"><div class="inner">
<header id="header"><a href="/" class="logo"><strong>Lookforit</strong> Verified Catalog</a></header>
<section>
<header class="major"><h1>$name</h1></header>
<p class="tool-hero-intro"><strong>Category:</strong> $category</p>
<p><strong>Status:</strong> $status | <strong>Last reviewed:</strong> $updatedAt</p>
<p>$description</p>
<p><strong>Official website:</strong> <a href="$website" target="_blank" rel="noopener noreferrer">$website</a></p>
<ul class="actions">
<li><a href="$catLink" class="button">Explore $category</a></li>
<li><a href="../index.html" class="button">Main Tools Directory</a></li>
<li><a href="/tools/catalog/" class="button">Catalog Hub</a></li>
</ul>
</section>
</div></div>
<div id="sidebar"><div class="inner"><section id="search" class="alt"><form method="get" action="/tools/"><input type="text" name="query" id="query" placeholder="Search AI tools..." /></form></section><nav id="menu"><header class="major"><h2>Menu</h2></header><ul><li><a href="/">Homepage</a></li><li><a href="/tools/">AI Tools</a></li><li><a href="/articles/">Articles</a></li><li><a href="/listing-requests/">Submit Your Tool</a></li></ul></nav><footer id="footer"><p>Lookforit.xyz is an AI tools directory listing hundreds of artificial intelligence tools for productivity, design, coding, marketing, and business.</p><div class="footer-policy-links"><a href="../../privacy-policy.html">Privacy Policy</a><a href="../../terms.html">Terms</a><a href="../../refund.html">Refund Policy</a><a href="../../disclaimer.html">Disclaimer</a><a href="../../faq.html">FAQ</a><a href="../../contact.html">Contact</a></div><p class="copyright">&copy; 2026 <a href="/">Lookforit.xyz</a>. All rights reserved.</p></footer></div></div></div>
<script src="../../assets/js/jquery.min.js"></script><script src="../../assets/js/browser.min.js"></script><script src="../../assets/js/breakpoints.min.js"></script><script src="../../assets/js/util.js"></script><script src="../../assets/js/main.js"></script>
<script src="/assets/js/tools-data.js"></script><script src="/assets/js/sidebar-search.js"></script>
</body>
</html>
"@

  Set-Content -Path (Join-Path $catalogDir ($slug + '.html')) -Value $page -Encoding UTF8 -NoNewline
  $written++
}

Write-Output "CATALOG_IMPORTED=$written"
