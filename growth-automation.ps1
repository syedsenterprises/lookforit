param(
  [string]$Root = ".",
  [int]$TopN = 60,
  [string]$OutputCsv = "ops/monetization/growth-backlog.csv"
)

& "$PSScriptRoot/ops/monetization/growth-automation.ps1" -Root $Root -TopN $TopN -OutputCsv $OutputCsv
