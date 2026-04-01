param(
  [string]$Root = ".",
  [int]$TopN = 80,
  [string]$OutputCsv = "ops/monetization/growth-backlog.csv"
)

$ErrorActionPreference = "Stop"
Set-Location $Root

$script:items = @()

function Add-BacklogItem {
  param(
    [string]$Type,
    [string]$Slug,
    [string]$Url,
    [string]$Intent,
    [string]$Monetization,
    [int]$Priority
  )

  $script:items += [pscustomobject]@{
    type = $Type
    slug = $Slug
    url = $Url
    intent = $Intent
    monetization = $Monetization
    priority = $Priority
    status = "todo"
    owner = "editorial"
    due_week = (Get-Date).AddDays(7).ToString("yyyy-MM-dd")
  }
}

$toolFiles = Get-ChildItem -Path "tools" -Filter *.html -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "index.html" }
foreach ($f in $toolFiles) {
  $slug = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
  $url = "https://lookforit.xyz/tools/$($f.Name)"
  $intent = "commercial investigation"
  $priority = if ($slug -match "chatgpt|claude|gemini|midjourney|cursor|deepseek") { 95 } else { 70 }
  Add-BacklogItem -Type "money-page-optimization" -Slug $slug -Url $url -Intent $intent -Monetization "affiliate+ads+submit-tool-cta" -Priority $priority
}

$articleFiles = Get-ChildItem -Path "articles" -Filter *.html -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "index.html" }
foreach ($f in $articleFiles) {
  $slug = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
  $url = "https://lookforit.xyz/articles/$($f.Name)"
  $priority = if ($slug -match "best|top|comparison|business|free") { 92 } else { 75 }
  Add-BacklogItem -Type "article-refresh" -Slug $slug -Url $url -Intent "informational" -Monetization "internal-links-to-tools+ads" -Priority $priority
}

$categorySeeds = @(
  "ai tools for real estate",
  "ai tools for recruiters",
  "ai tools for customer support",
  "ai tools for ecommerce",
  "ai tools for lawyers",
  "free ai tools for students",
  "best ai meeting assistants",
  "best ai coding tools for teams",
  "best ai seo tools for agencies",
  "ai automation tools for small business"
)

foreach ($seed in $categorySeeds) {
  $slug = ($seed -replace "[^a-zA-Z0-9]+", "-").Trim("-").ToLowerInvariant()
  $url = "https://lookforit.xyz/articles/$slug-2026.html"
  Add-BacklogItem -Type "new-money-article" -Slug $slug -Url $url -Intent "commercial investigation" -Monetization "affiliate+ads+email-capture" -Priority 96
}

$final = $script:items | Sort-Object priority -Descending | Select-Object -First $TopN

$dir = Split-Path -Parent $OutputCsv
if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
$final | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8

$summaryPath = "ops/monetization/growth-backlog-summary.md"
$summary = @()
$summary += "# Growth Backlog Summary"
$summary += ""
$summary += "- Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$summary += "- Rows exported: $($final.Count)"
$summary += "- Output CSV: $OutputCsv"
$summary += ""
$summary += "## Top 15 Priorities"
$top = $final | Select-Object -First 15
$rank = 1
foreach ($row in $top) {
  $summary += "$rank. [$($row.type)] $($row.slug) | priority=$($row.priority) | monetization=$($row.monetization)"
  $rank++
}
$summary -join "`r`n" | Set-Content -Path $summaryPath -Encoding UTF8

Write-Output "GROWTH_BACKLOG_ROWS=$($final.Count)"
Write-Output "GROWTH_BACKLOG_CSV=$OutputCsv"
Write-Output "GROWTH_BACKLOG_SUMMARY=$summaryPath"
