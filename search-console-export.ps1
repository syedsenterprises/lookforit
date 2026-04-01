param(
  [string]$Root = ".",
  [string]$SiteUrl = "https://lookforit.xyz/",
  [int]$MaxUrls = 150,
  [switch]$GenerateSitemap = $false,
  [string]$OutputCsv = "ops/seo/search-console-inspection.csv",
  [string]$OutputReport = "ops/seo/search-console-inspection-report.md"
)

& "$PSScriptRoot/ops/seo/search-console-export.ps1" -Root $Root -SiteUrl $SiteUrl -MaxUrls $MaxUrls -GenerateSitemap:$GenerateSitemap -OutputCsv $OutputCsv -OutputReport $OutputReport
