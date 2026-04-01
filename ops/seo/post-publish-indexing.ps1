param(
  [string]$Root = ".",
  [string]$SiteUrl = "https://lookforit.xyz/",
  [int]$InspectMaxUrls = 150
)

$ErrorActionPreference = "Stop"
Set-Location $Root

& ./ops/seo/submit-sitemaps.ps1 -Root $Root -SiteUrl $SiteUrl -GenerateSitemap -SubmitToBing
& ./ops/seo/search-console-export.ps1 -Root $Root -SiteUrl $SiteUrl -MaxUrls $InspectMaxUrls -GenerateSitemap:$false

Write-Output "POST_PUBLISH_INDEXING_DONE=1"
Write-Output "POST_PUBLISH_REPORT_1=ops/seo/sitemap-submit-report.md"
Write-Output "POST_PUBLISH_REPORT_2=ops/seo/search-console-inspection-report.md"
Write-Output "POST_PUBLISH_CSV=ops/seo/search-console-inspection.csv"
