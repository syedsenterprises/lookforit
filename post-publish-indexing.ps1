param(
  [string]$Root = ".",
  [string]$SiteUrl = "https://lookforit.xyz/",
  [int]$InspectMaxUrls = 150
)

& "$PSScriptRoot/ops/seo/post-publish-indexing.ps1" -Root $Root -SiteUrl $SiteUrl -InspectMaxUrls $InspectMaxUrls
