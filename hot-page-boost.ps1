param(
  [string]$Root = ".",
  [string]$BacklogCsv = "ops/monetization/growth-backlog.csv",
  [int]$TopN = 30,
  [string]$CtaVariantsCsv = "ops/monetization/hot-page-cta-variants.csv",
  [string]$ReportFile = "ops/monetization/hot-page-boost-report.md",
  [switch]$SkipCtrRewrite,
  [switch]$SkipAffiliateBlocks
)

& "$PSScriptRoot/ops/monetization/hot-page-boost.ps1" -Root $Root -BacklogCsv $BacklogCsv -TopN $TopN -CtaVariantsCsv $CtaVariantsCsv -ReportFile $ReportFile -SkipCtrRewrite:$SkipCtrRewrite -SkipAffiliateBlocks:$SkipAffiliateBlocks
