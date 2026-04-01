param(
  [string]$Root = ".",
  [int]$BacklogTopN = 60,
  [int]$BoostTopN = 30,
  [switch]$RunSeoEngine,
  [int]$SeoNewArticleCount = 1,
  [int]$SeoRefreshCount = 5,
  [switch]$PublishNew,
  [string]$ReportFile = "ops/monetization/weekly-revenue-ops-report.md"
)

$ErrorActionPreference = "Stop"
Set-Location $Root

$steps = @()

$adsenseOut = & "$PSScriptRoot/adsense-readiness-audit.ps1" -Root $Root
$steps += [pscustomobject]@{ step = "adsense-readiness"; output = ($adsenseOut -join " | ") }

$growthOut = & "$PSScriptRoot/growth-automation.ps1" -Root $Root -TopN $BacklogTopN
$steps += [pscustomobject]@{ step = "growth-backlog"; output = ($growthOut -join " | ") }

if ($RunSeoEngine) {
  $seoOut = & "$PSScriptRoot/weekly-seo-engine.ps1" -Root $Root -BacklogCsv "ops/monetization/growth-backlog.csv" -NewArticleCount $SeoNewArticleCount -RefreshCount $SeoRefreshCount -PublishNew:$PublishNew
  $steps += [pscustomobject]@{ step = "weekly-seo-engine"; output = ($seoOut -join " | ") }
}

$boostOut = & "$PSScriptRoot/hot-page-boost.ps1" -Root $Root -BacklogCsv "ops/monetization/growth-backlog.csv" -TopN $BoostTopN
$steps += [pscustomobject]@{ step = "hot-page-boost"; output = ($boostOut -join " | ") }

$kpiOut = & "$PSScriptRoot/weekly-kpi-report.ps1" -Root $Root
$steps += [pscustomobject]@{ step = "weekly-kpi-report"; output = ($kpiOut -join " | ") }

$report = @()
$report += "# Weekly Revenue Ops Report"
$report += ""
$report += "- Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$report += "- Backlog TopN: $BacklogTopN"
$report += "- Boost TopN: $BoostTopN"
$report += "- SEO Engine Executed: $RunSeoEngine"
$report += ""
$report += "## Step Outputs"
foreach ($s in $steps) {
  $report += "- $($s.step): $($s.output)"
}

$reportDir = Split-Path -Parent $ReportFile
if ($reportDir -and !(Test-Path $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }
$report -join "`r`n" | Set-Content -Path $ReportFile -Encoding UTF8

Write-Output "WEEKLY_REVENUE_OPS_REPORT=$ReportFile"
Write-Output "WEEKLY_REVENUE_OPS_DONE=1"
