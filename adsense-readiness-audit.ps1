param(
  [string]$Root = ".",
  [string]$OutputFile = "ops/monetization/adsense-readiness-report.md"
)

& "$PSScriptRoot/ops/monetization/adsense-readiness-audit.ps1" -Root $Root -OutputFile $OutputFile
