param(
  [string]$Root = ".",
  [string]$BacklogCsv = "ops/monetization/growth-backlog.csv",
  [int]$TopN = 50
)

$ErrorActionPreference = "Stop"
Set-Location $Root

if (!(Test-Path $BacklogCsv)) {
  throw "Backlog CSV not found: $BacklogCsv"
}

$rows = Import-Csv -Path $BacklogCsv | Where-Object { $_.type -eq "money-page-optimization" } | Select-Object -First $TopN
$updated = 0
$skipped = 0

foreach ($row in $rows) {
  $slug = $row.slug
  $path = "tools/$slug.html"
  if (!(Test-Path $path)) { $skipped++; continue }

  $raw = Get-Content -Raw $path
  $keyword = ($slug -replace "-", " ").Trim()

  $newTitle = "${keyword} Review 2026: Free vs Paid, Pricing, and Best Use Cases"
  $newDescription = "See the ${keyword} 2026 breakdown with free vs paid pricing, key features, practical use cases, and alternatives before you choose."

  $raw = [regex]::Replace($raw, "<title>.*?</title>", "<title>$newTitle - Lookforit.xyz</title>", "Singleline")

  if ($raw -match '<meta name="description"') {
    $raw = [regex]::Replace($raw, '<meta name="description" content="[^"]*"\s*/?>', ('<meta name="description" content="{0}" />' -f $newDescription))
  }

  if ($raw -match '<meta property="og:title"') {
    $raw = [regex]::Replace($raw, '<meta property="og:title" content="[^"]*"\s*/?>', ('<meta property="og:title" content="{0}" />' -f $newTitle))
  }

  if ($raw -match '<meta property="og:description"') {
    $raw = [regex]::Replace($raw, '<meta property="og:description" content="[^"]*"\s*/?>', ('<meta property="og:description" content="{0}" />' -f $newDescription))
  }

  if ($raw -match '<meta name="twitter:title"') {
    $raw = [regex]::Replace($raw, '<meta name="twitter:title" content="[^"]*"\s*/?>', ('<meta name="twitter:title" content="{0}" />' -f $newTitle))
  }

  if ($raw -match '<meta name="twitter:description"') {
    $raw = [regex]::Replace($raw, '<meta name="twitter:description" content="[^"]*"\s*/?>', ('<meta name="twitter:description" content="{0}" />' -f $newDescription))
  }

  Set-Content -Path $path -Value $raw -Encoding UTF8
  $updated++
}

Write-Output "CTR_REWRITE_UPDATED=$updated"
Write-Output "CTR_REWRITE_SKIPPED=$skipped"
Write-Output "CTR_REWRITE_TARGET=$TopN"
