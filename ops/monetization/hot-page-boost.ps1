param(
  [string]$Root = ".",
  [string]$BacklogCsv = "ops/monetization/growth-backlog.csv",
  [int]$TopN = 30,
  [string]$CtaVariantsCsv = "ops/monetization/hot-page-cta-variants.csv",
  [string]$ReportFile = "ops/monetization/hot-page-boost-report.md",
  [switch]$SkipCtrRewrite,
  [switch]$SkipAffiliateBlocks
)

$ErrorActionPreference = "Stop"
Set-Location $Root

if (!(Test-Path $BacklogCsv)) {
  throw "Backlog CSV not found: $BacklogCsv"
}

$rows = Import-Csv -Path $BacklogCsv
$moneyRows = $rows | Where-Object { $_.type -eq "money-page-optimization" } | Sort-Object { [int]$_.priority } -Descending
$targets = $moneyRows | Select-Object -First $TopN

if ($targets.Count -eq 0) {
  throw "No money-page-optimization rows found in backlog."
}

foreach ($r in $rows) {
  if ($null -eq $r.PSObject.Properties["affiliate_priority"]) {
    Add-Member -InputObject $r -NotePropertyName "affiliate_priority" -NotePropertyValue "normal"
  }
  if ($null -eq $r.PSObject.Properties["cta_test_status"]) {
    Add-Member -InputObject $r -NotePropertyName "cta_test_status" -NotePropertyValue "backlog"
  }
  if ($null -eq $r.PSObject.Properties["hot_boost_week"]) {
    Add-Member -InputObject $r -NotePropertyName "hot_boost_week" -NotePropertyValue ""
  }
}

$targetMap = @{}
foreach ($t in $targets) {
  $targetMap[$t.slug] = $true
}

$currentWeek = (Get-Date).ToString("yyyy-'W'ww")
foreach ($r in $rows) {
  if ($targetMap.ContainsKey($r.slug)) {
    $r.affiliate_priority = "high"
    $r.cta_test_status = "ready"
    $r.hot_boost_week = $currentWeek

    $basePriority = 0
    try { $basePriority = [int]$r.priority } catch { $basePriority = 0 }
    $newPriority = [Math]::Min(100, $basePriority + 4)
    $r.priority = "$newPriority"
  }
}

$rows | Export-Csv -Path $BacklogCsv -NoTypeInformation -Encoding UTF8

$ctaRows = @()
foreach ($t in $targets) {
  $keyword = ($t.slug -replace "-", " ").Trim()
  $ctaRows += [pscustomobject]@{
    slug = $t.slug
    url = $t.url
    priority = $t.priority
    variant_a = "See $keyword pricing and free plan"
    variant_b = "Compare $keyword tools in 2 minutes"
    variant_c = "Claim best $keyword deal this week"
    placement = "stickybar+inline+pricing_table"
    status = "ready"
  }
}

$ctaDir = Split-Path -Parent $CtaVariantsCsv
if ($ctaDir -and !(Test-Path $ctaDir)) { New-Item -ItemType Directory -Path $ctaDir -Force | Out-Null }
$ctaRows | Export-Csv -Path $CtaVariantsCsv -NoTypeInformation -Encoding UTF8

$ctrOutput = @("CTR_REWRITE_SKIPPED=True")
if (-not $SkipCtrRewrite) {
  $ctrOutput = & "$PSScriptRoot/seo-ctr-rewrite.ps1" -Root $Root -BacklogCsv $BacklogCsv -TopN $TopN
}

$affiliateOutput = @("AFFILIATE_BLOCKS_SKIPPED=True")
if (-not $SkipAffiliateBlocks) {
  $affiliateOutput = & "$PSScriptRoot/generate-affiliate-blocks.ps1" -Root $Root -BacklogCsv $BacklogCsv -TopN $TopN
}

$report = @()
$report += "# Hot Page Boost Report"
$report += ""
$report += "- Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$report += "- Backlog CSV: $BacklogCsv"
$report += "- Target count: $($targets.Count)"
$report += "- CTA variants CSV: $CtaVariantsCsv"
$report += ""
$report += "## Top Pages Boosted"
$rank = 1
foreach ($t in $targets) {
  $report += "$rank. $($t.slug) | $($t.url)"
  $rank++
}

$report += ""
$report += "## CTR Rewrite Output"
foreach ($line in $ctrOutput) {
  $report += "- $line"
}

$report += ""
$report += "## Affiliate Block Output"
foreach ($line in $affiliateOutput) {
  $report += "- $line"
}

$reportDir = Split-Path -Parent $ReportFile
if ($reportDir -and !(Test-Path $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }
$report -join "`r`n" | Set-Content -Path $ReportFile -Encoding UTF8

Write-Output "HOT_PAGE_BOOST_TARGETS=$($targets.Count)"
Write-Output "HOT_PAGE_BOOST_CTA_CSV=$CtaVariantsCsv"
Write-Output "HOT_PAGE_BOOST_REPORT=$ReportFile"
