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

& "$PSScriptRoot/ops/monetization/weekly-revenue-ops.ps1" -Root $Root -BacklogTopN $BacklogTopN -BoostTopN $BoostTopN -RunSeoEngine:$RunSeoEngine -SeoNewArticleCount $SeoNewArticleCount -SeoRefreshCount $SeoRefreshCount -PublishNew:$PublishNew -ReportFile $ReportFile
