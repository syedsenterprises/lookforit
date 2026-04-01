param(
  [string]$Root = ".",
  [string]$SiteUrl = "https://lookforit.xyz/",
  [switch]$GenerateSitemap = $true,
  [switch]$SubmitToBing = $true,
  [string]$OutputReport = "ops/seo/sitemap-submit-report.md"
)

$ErrorActionPreference = "Stop"
Set-Location $Root

function Get-LocValues {
  param([string]$XmlText)
  $matches = [regex]::Matches($XmlText, '<loc>([^<]+)</loc>')
  $vals = @()
  foreach ($m in $matches) {
    $vals += $m.Groups[1].Value.Trim()
  }
  return $vals
}

if ($GenerateSitemap) {
  & ./generate-sitemap.ps1
}

$site = $SiteUrl.TrimEnd('/')
$sitemapUrls = @(
  "$site/sitemap.xml",
  "$site/sitemaps/index/content.xml",
  "$site/sitemaps/index/catalog.xml"
)

$bingResults = @()
if ($SubmitToBing) {
  foreach ($sm in $sitemapUrls) {
    try {
      $ping = "https://www.bing.com/ping?sitemap=" + [uri]::EscapeDataString($sm)
      $resp = Invoke-WebRequest -Uri $ping -Method Get -UseBasicParsing -TimeoutSec 30
      $bingResults += [pscustomobject]@{
        sitemap = $sm
        status = $resp.StatusCode
        ok = $true
        note = "submitted"
      }
    }
    catch {
      $bingResults += [pscustomobject]@{
        sitemap = $sm
        status = 0
        ok = $false
        note = $_.Exception.Message
      }
    }
  }
}

$indexNowResult = [pscustomobject]@{
  attempted = $false
  ok = $false
  status = 0
  note = "indexnow-key not configured"
}

$keyPath = "ops/seo/indexnow-key.txt"
if (Test-Path $keyPath) {
  $key = (Get-Content $keyPath -Raw).Trim()
  if ($key) {
    $urlsetFile = "sitemaps/tools.xml"
    $urlList = @()
    if (Test-Path $urlsetFile) {
      $xmlText = Get-Content -Raw $urlsetFile
      $urlList = Get-LocValues -XmlText $xmlText | Select-Object -First 100
    }

    if ($urlList.Count -gt 0) {
      try {
        $payload = @{
          host = ([uri]$site).Host
          key = $key
          keyLocation = "$site/$key.txt"
          urlList = $urlList
        } | ConvertTo-Json -Depth 5

        $resp = Invoke-WebRequest -Uri "https://api.indexnow.org/indexnow" -Method Post -ContentType "application/json" -Body $payload -UseBasicParsing -TimeoutSec 40
        $indexNowResult = [pscustomobject]@{
          attempted = $true
          ok = $true
          status = $resp.StatusCode
          note = "Submitted $($urlList.Count) URLs"
        }
      }
      catch {
        $indexNowResult = [pscustomobject]@{
          attempted = $true
          ok = $false
          status = 0
          note = $_.Exception.Message
        }
      }
    }
  }
}

$report = @()
$report += "# Sitemap Submission Report"
$report += ""
$report += "- Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$report += "- Site URL: $site"
$report += "- Sitemap generation run: $GenerateSitemap"
$report += ""
$report += "## Bing Submission"
if ($bingResults.Count -eq 0) {
  $report += "- Skipped"
} else {
  foreach ($r in $bingResults) {
    $report += "- $($r.sitemap) | status=$($r.status) | ok=$($r.ok) | $($r.note)"
  }
}
$report += ""
$report += "## IndexNow"
$report += "- attempted=$($indexNowResult.attempted) | ok=$($indexNowResult.ok) | status=$($indexNowResult.status) | note=$($indexNowResult.note)"
$report += ""
$report += "## Notes"
$report += "- Google sitemap ping endpoint is deprecated. Use Search Console API for inspection and indexing diagnostics."

$dir = Split-Path -Parent $OutputReport
if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
$report -join "`r`n" | Set-Content -Path $OutputReport -Encoding UTF8

Write-Output "SITEMAP_SUBMIT_BING_COUNT=$($bingResults.Count)"
Write-Output "SITEMAP_SUBMIT_INDEXNOW_ATTEMPTED=$($indexNowResult.attempted)"
Write-Output "SITEMAP_SUBMIT_REPORT=$OutputReport"
