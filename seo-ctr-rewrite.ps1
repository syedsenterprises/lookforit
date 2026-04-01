param(
  [string]$Root = ".",
  [string]$BacklogCsv = "ops/monetization/growth-backlog.csv",
  [int]$TopN = 50
)

& "$PSScriptRoot/ops/monetization/seo-ctr-rewrite.ps1" -Root $Root -BacklogCsv $BacklogCsv -TopN $TopN
