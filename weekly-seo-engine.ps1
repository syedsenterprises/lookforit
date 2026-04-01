param(
  [string]$Root = ".",
  [string]$BacklogCsv = "ops/monetization/growth-backlog.csv",
  [int]$NewArticleCount = 3,
  [int]$RefreshCount = 10,
  [switch]$PublishNew
)

& "$PSScriptRoot/ops/monetization/weekly-seo-engine.ps1" -Root $Root -BacklogCsv $BacklogCsv -NewArticleCount $NewArticleCount -RefreshCount $RefreshCount -PublishNew:$PublishNew
