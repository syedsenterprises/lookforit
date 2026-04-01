param(
  [string]$Root = ".",
  [string]$SiteUrl = "https://lookforit.xyz/",
  [switch]$GenerateSitemap = $true,
  [switch]$SubmitToBing = $true,
  [string]$OutputReport = "ops/seo/sitemap-submit-report.md"
)

& "$PSScriptRoot/ops/seo/submit-sitemaps.ps1" -Root $Root -SiteUrl $SiteUrl -GenerateSitemap:$GenerateSitemap -SubmitToBing:$SubmitToBing -OutputReport $OutputReport
