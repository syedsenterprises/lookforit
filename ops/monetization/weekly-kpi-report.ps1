param(
  [string]$Root = ".",
  [string]$BacklogCsv = "ops/monetization/growth-backlog.csv",
  [string]$AdsenseReport = "ops/monetization/adsense-readiness-report.md",
  [string]$WeeklySeoReport = "ops/monetization/weekly-seo-engine-report.md",
  [string]$SearchConsoleCsv = "ops/seo/search-console-inspection.csv",
  [string]$OutputMarkdown = "ops/monetization/weekly-kpi-report.md",
  [string]$OutputCsv = "ops/monetization/weekly-kpi-report.csv"
)

$ErrorActionPreference = "Stop"
Set-Location $Root

function Read-TextFile {
  param([string]$Path)
  if (!(Test-Path $Path)) { return "" }
  return Get-Content -Raw $Path
}

function Get-MetricValue {
  param(
    [string]$Text,
    [string]$Pattern,
    [string]$Default = "0"
  )
  if ([string]::IsNullOrWhiteSpace($Text)) { return $Default }
  $m = [regex]::Match($Text, $Pattern)
  if ($m.Success) { return $m.Groups[1].Value.Trim() }
  return $Default
}

$adsenseText = Read-TextFile -Path $AdsenseReport
$weeklyText = Read-TextFile -Path $WeeklySeoReport

$adsenseScore = Get-MetricValue -Text $adsenseText -Pattern 'Readiness Score:\s*([0-9]+)'
$adsenseGrade = Get-MetricValue -Text $adsenseText -Pattern 'Grade:\s*([A-F])' -Default "N/A"

$weeklyDrafts = Get-MetricValue -Text $weeklyText -Pattern 'New article drafts prepared:\s*([0-9]+)'
$weeklyPublished = Get-MetricValue -Text $weeklyText -Pattern 'New articles published this run:\s*([0-9]+)'
$weeklyRefreshed = Get-MetricValue -Text $weeklyText -Pattern 'Existing articles refreshed:\s*([0-9]+)'

$backlogRows = @()
if (Test-Path $BacklogCsv) {
  $backlogRows = Import-Csv -Path $BacklogCsv
}

$moneyRows = $backlogRows | Where-Object { $_.type -eq "money-page-optimization" }
$articleRows = $backlogRows | Where-Object { $_.type -eq "article-refresh" }
$newMoneyRows = $backlogRows | Where-Object { $_.type -eq "new-money-article" }

$topMoneyRows = $moneyRows | Sort-Object { [int]$_.priority } -Descending | Select-Object -First 10

$priorityAverage = 0
if ($moneyRows.Count -gt 0) {
  $priorityAverage = [Math]::Round((($moneyRows | Measure-Object -Property priority -Average).Average), 2)
}

$gscRows = @()
if (Test-Path $SearchConsoleCsv) {
  $gscRows = Import-Csv -Path $SearchConsoleCsv
}

$gscInspected = $gscRows.Count
$gscIndexed = ($gscRows | Where-Object {
  $status = ""
  if ($_.indexStatusResultCoverageState) { $status = $_.indexStatusResultCoverageState }
  elseif ($_.coverageState) { $status = $_.coverageState }
  $status -match '(?i)indexed'
}).Count

$gscIndexedRate = 0
if ($gscInspected -gt 0) {
  $gscIndexedRate = [Math]::Round(($gscIndexed / $gscInspected) * 100, 2)
}

$kpiRows = @(
  [pscustomobject]@{ metric = "adsense_readiness_score"; value = $adsenseScore },
  [pscustomobject]@{ metric = "adsense_readiness_grade"; value = $adsenseGrade },
  [pscustomobject]@{ metric = "backlog_total_rows"; value = $backlogRows.Count },
  [pscustomobject]@{ metric = "money_page_rows"; value = $moneyRows.Count },
  [pscustomobject]@{ metric = "article_refresh_rows"; value = $articleRows.Count },
  [pscustomobject]@{ metric = "new_money_article_rows"; value = $newMoneyRows.Count },
  [pscustomobject]@{ metric = "money_page_avg_priority"; value = $priorityAverage },
  [pscustomobject]@{ metric = "weekly_drafts"; value = $weeklyDrafts },
  [pscustomobject]@{ metric = "weekly_published"; value = $weeklyPublished },
  [pscustomobject]@{ metric = "weekly_refreshed"; value = $weeklyRefreshed },
  [pscustomobject]@{ metric = "gsc_urls_processed"; value = $gscInspected },
  [pscustomobject]@{ metric = "gsc_indexed_urls"; value = $gscIndexed },
  [pscustomobject]@{ metric = "gsc_indexed_rate_percent"; value = $gscIndexedRate }
)

$md = @()
$md += "# Weekly KPI Report"
$md += ""
$md += "- Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$md += "- Source Backlog: $BacklogCsv"
$md += "- Source AdSense Report: $AdsenseReport"
$md += "- Source Weekly SEO Report: $WeeklySeoReport"
$md += "- Source Search Console CSV: $SearchConsoleCsv"
$md += ""
$md += "## KPI Snapshot"
$md += ""
$md += "| Metric | Value |"
$md += "|---|---|"
foreach ($row in $kpiRows) {
  $md += "| $($row.metric) | $($row.value) |"
}

$md += ""
$md += "## Top 10 Money Pages To Push"
$md += ""
if ($topMoneyRows.Count -eq 0) {
  $md += "No money-page-optimization rows found in backlog."
} else {
  $rank = 1
  foreach ($r in $topMoneyRows) {
    $md += "$rank. $($r.slug) | priority=$($r.priority) | $($r.url)"
    $rank++
  }
}

$md += ""
$md += "## Recommended Weekly Actions"
$md += "1. Run hot-page boost for top 20-30 money pages."
$md += "2. Publish at least 1 new money article and refresh 5-10 existing ones."
$md += "3. Review Search Console low-index pages and strengthen internal links."

$mdDir = Split-Path -Parent $OutputMarkdown
if ($mdDir -and !(Test-Path $mdDir)) { New-Item -ItemType Directory -Path $mdDir -Force | Out-Null }
$md -join "`r`n" | Set-Content -Path $OutputMarkdown -Encoding UTF8

$csvDir = Split-Path -Parent $OutputCsv
if ($csvDir -and !(Test-Path $csvDir)) { New-Item -ItemType Directory -Path $csvDir -Force | Out-Null }
$kpiRows | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8

Write-Output "WEEKLY_KPI_REPORT=$OutputMarkdown"
Write-Output "WEEKLY_KPI_CSV=$OutputCsv"
Write-Output "WEEKLY_KPI_MONEY_TOP10=$($topMoneyRows.Count)"
