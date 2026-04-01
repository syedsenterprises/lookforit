param(
  [string]$Root = ".",
  [string]$SiteUrl = "https://lookforit.xyz/",
  [int]$MaxUrls = 150,
  [switch]$GenerateSitemap = $false,
  [string]$OutputCsv = "ops/seo/search-console-inspection.csv",
  [string]$OutputReport = "ops/seo/search-console-inspection-report.md"
)

$ErrorActionPreference = "Stop"
Set-Location $Root

function Get-LocValues {
  param([string]$XmlText)
  $locHits = [regex]::Matches($XmlText, '<loc>([^<]+)</loc>')
  $vals = @()
  foreach ($m in $locHits) {
    $vals += $m.Groups[1].Value.Trim()
  }
  return $vals
}

function Convert-LocToLocalFile {
  param(
    [string]$Loc,
    [string]$RootPath
  )

  try {
    $uri = [uri]$Loc
    $relative = $uri.AbsolutePath.TrimStart('/')
    if (-not $relative) {
      return Join-Path $RootPath "sitemap.xml"
    }
    return Join-Path $RootPath $relative
  }
  catch {
    return $null
  }
}

function Get-SitemapUrls {
  param(
    [string]$StartFile,
    [string]$RootPath
  )

  $queue = New-Object System.Collections.Generic.Queue[string]
  $queue.Enqueue($StartFile)

  $visited = New-Object System.Collections.Generic.HashSet[string]
  $urls = New-Object System.Collections.Generic.List[string]

  while ($queue.Count -gt 0) {
    $file = $queue.Dequeue()
    if (-not $file) { continue }
    if ($visited.Contains($file)) { continue }
    $visited.Add($file) | Out-Null

    if (!(Test-Path $file)) { continue }

    $xmlText = Get-Content -Raw $file
    if ($xmlText -match '<sitemapindex') {
      $childLocs = Get-LocValues -XmlText $xmlText
      foreach ($loc in $childLocs) {
        $childFile = Convert-LocToLocalFile -Loc $loc -RootPath $RootPath
        if ($childFile) { $queue.Enqueue($childFile) }
      }
      continue
    }

    if ($xmlText -match '<urlset') {
      $pageLocs = Get-LocValues -XmlText $xmlText
      foreach ($u in $pageLocs) {
        $urls.Add($u)
      }
    }
  }

  return $urls | Select-Object -Unique
}

if ($GenerateSitemap) {
  & ./generate-sitemap.ps1
}

$allUrls = Get-SitemapUrls -StartFile (Join-Path $PWD "sitemap.xml") -RootPath $PWD
$targetUrls = $allUrls | Select-Object -First $MaxUrls

$token = $env:GSC_OAUTH_TOKEN
$rows = @()
$inspected = 0
$tokenMode = [string]::IsNullOrWhiteSpace($token) -eq $false

if ($tokenMode) {
  foreach ($url in $targetUrls) {
    try {
      $body = @{
        inspectionUrl = $url
        siteUrl = $SiteUrl
        languageCode = "en-US"
      } | ConvertTo-Json

      $resp = Invoke-RestMethod -Uri "https://searchconsole.googleapis.com/v1/urlInspection/index:inspect" -Method Post -Headers @{ Authorization = "Bearer $token" } -ContentType "application/json" -Body $body -TimeoutSec 40
      $result = $resp.inspectionResult.indexStatusResult

      $rows += [pscustomobject]@{
        url = $url
        verdict = $result.verdict
        coverageState = $result.coverageState
        indexingState = $result.indexingState
        pageFetchState = $result.pageFetchState
        robotsTxtState = $result.robotsTxtState
        lastCrawlTime = $result.lastCrawlTime
        googleCanonical = $result.googleCanonical
        userCanonical = $result.userCanonical
        status = "ok"
      }

      $inspected++
      Start-Sleep -Milliseconds 150
    }
    catch {
      $rows += [pscustomobject]@{
        url = $url
        verdict = ""
        coverageState = ""
        indexingState = ""
        pageFetchState = ""
        robotsTxtState = ""
        lastCrawlTime = ""
        googleCanonical = ""
        userCanonical = ""
        status = "error: $($_.Exception.Message)"
      }
    }
  }
} else {
  foreach ($url in $targetUrls) {
    $rows += [pscustomobject]@{
      url = $url
      verdict = "token_required"
      coverageState = ""
      indexingState = ""
      pageFetchState = ""
      robotsTxtState = ""
      lastCrawlTime = ""
      googleCanonical = ""
      userCanonical = ""
      status = "Set GSC_OAUTH_TOKEN env var to run URL Inspection API"
    }
  }
}

$csvDir = Split-Path -Parent $OutputCsv
if ($csvDir -and !(Test-Path $csvDir)) { New-Item -ItemType Directory -Path $csvDir -Force | Out-Null }
$rows | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8

$okCount = ($rows | Where-Object { $_.status -eq "ok" }).Count
$errorCount = ($rows | Where-Object { $_.status -like "error:*" }).Count

$report = @()
$report += "# Search Console Inspection Export Report"
$report += ""
$report += "- Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$report += "- Site URL: $SiteUrl"
$report += "- URLs discovered from sitemap: $($allUrls.Count)"
$report += "- URLs processed: $($targetUrls.Count)"
$report += "- Token mode enabled: $tokenMode"
$report += "- Successful inspections: $okCount"
$report += "- Errors: $errorCount"
$report += "- CSV output: $OutputCsv"
$report += ""
$report += "## Setup"
$report += "- For automatic URL inspection export, set env var GSC_OAUTH_TOKEN with a valid Search Console OAuth access token."
$report += "- Example PowerShell: `$env:GSC_OAUTH_TOKEN = 'ya29....'"

$reportDir = Split-Path -Parent $OutputReport
if ($reportDir -and !(Test-Path $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }
$report -join "`r`n" | Set-Content -Path $OutputReport -Encoding UTF8

Write-Output "GSC_EXPORT_URLS_TOTAL=$($allUrls.Count)"
Write-Output "GSC_EXPORT_URLS_PROCESSED=$($targetUrls.Count)"
Write-Output "GSC_EXPORT_TOKEN_MODE=$tokenMode"
Write-Output "GSC_EXPORT_INSPECTED_OK=$okCount"
Write-Output "GSC_EXPORT_REPORT=$OutputReport"
Write-Output "GSC_EXPORT_CSV=$OutputCsv"
