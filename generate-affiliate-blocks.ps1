param(
  [string]$Root = ".",
  [string]$BacklogCsv = "ops/monetization/growth-backlog.csv",
  [int]$TopN = 30
)

& "$PSScriptRoot/ops/monetization/generate-affiliate-blocks.ps1" -Root $Root -BacklogCsv $BacklogCsv -TopN $TopN
