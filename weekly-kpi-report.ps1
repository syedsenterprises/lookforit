param(
  [string]$Root = ".",
  [string]$BacklogCsv = "ops/monetization/growth-backlog.csv",
  [string]$AdsenseReport = "ops/monetization/adsense-readiness-report.md",
  [string]$WeeklySeoReport = "ops/monetization/weekly-seo-engine-report.md",
  [string]$SearchConsoleCsv = "ops/seo/search-console-inspection.csv",
  [string]$OutputMarkdown = "ops/monetization/weekly-kpi-report.md",
  [string]$OutputCsv = "ops/monetization/weekly-kpi-report.csv"
)

& "$PSScriptRoot/ops/monetization/weekly-kpi-report.ps1" -Root $Root -BacklogCsv $BacklogCsv -AdsenseReport $AdsenseReport -WeeklySeoReport $WeeklySeoReport -SearchConsoleCsv $SearchConsoleCsv -OutputMarkdown $OutputMarkdown -OutputCsv $OutputCsv
