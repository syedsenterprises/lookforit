param(
  [string]$Root = ".",
  [string]$OutputFile = "ops/monetization/adsense-readiness-report.md"
)

$ErrorActionPreference = "Stop"
Set-Location $Root

function Test-FileContains {
  param(
    [string]$Path,
    [string]$Pattern
  )
  if (!(Test-Path $Path)) { return $false }
  return [bool](Select-String -Path $Path -Pattern $Pattern -SimpleMatch -Quiet)
}

$requiredPages = @(
  "index.html",
  "about.html",
  "contact.html",
  "privacy-policy.html",
  "terms.html",
  "disclaimer.html"
)

$missingPages = @()
foreach ($page in $requiredPages) {
  if (!(Test-Path $page)) { $missingPages += $page }
}

$hasAdsTxt = Test-Path "ads.txt"
$adsTxtLine = if ($hasAdsTxt) { (Get-Content "ads.txt" -First 1) } else { "" }

$htmlFiles = Get-ChildItem -Recurse -Filter *.html | Where-Object { $_.FullName -notmatch "\\admin\\|admin-login.html|dashboard.html" }

$viewportBlockers = 0
$missingCanonical = 0
$missingDescription = 0
$thinContent = 0
$adSenseScriptPresent = 0

foreach ($file in $htmlFiles) {
  $raw = Get-Content -Raw $file.FullName

  if ($raw -match "user-scalable=no") { $viewportBlockers++ }
  if ($raw -notmatch '<link rel="canonical"') { $missingCanonical++ }
  if ($raw -notmatch '<meta name="description"') { $missingDescription++ }
  if (($raw -replace "<[^>]+>", " " -replace "\s+", " ").Length -lt 900) { $thinContent++ }
  if ($raw -match "googlesyndication.com/pagead/js/adsbygoogle.js") { $adSenseScriptPresent++ }
}

$hasMonetizationConfig = Test-Path "assets/js/monetization-config.js"
$hasMonetizationAutomation = Test-Path "assets/js/monetization-automation.js"
$hasGA4 = Test-FileContains -Path "assets/js/main.js" -Pattern "googletagmanager.com/gtag/js?id="

$score = 100
if ($missingPages.Count -gt 0) { $score -= 20 }
if (-not $hasAdsTxt) { $score -= 20 }
if ($viewportBlockers -gt 0) { $score -= 15 }
if ($missingCanonical -gt 0) { $score -= 10 }
if ($missingDescription -gt 0) { $score -= 10 }
if ($thinContent -gt 150) { $score -= 10 }
if (-not $hasGA4) { $score -= 5 }
if (-not $hasMonetizationAutomation) { $score -= 10 }
if ($score -lt 0) { $score = 0 }

$grade = if ($score -ge 90) { "A" } elseif ($score -ge 80) { "B" } elseif ($score -ge 70) { "C" } elseif ($score -ge 60) { "D" } else { "F" }

$lines = @()
$lines += "# AdSense Readiness Report"
$lines += ""
$lines += "- Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$lines += "- Readiness Score: $score/100"
$lines += "- Grade: $grade"
$lines += ""
$lines += "## Compliance Checklist"
$lines += "- Required legal/content pages missing: $($missingPages.Count)"
if ($missingPages.Count -gt 0) {
  foreach ($m in $missingPages) { $lines += "  - MISSING: $m" }
}
$lines += "- ads.txt present: $hasAdsTxt"
if ($hasAdsTxt) { $lines += "- ads.txt first line: $adsTxtLine" }
$lines += "- GA4 tracking detected in assets/js/main.js: $hasGA4"
$lines += "- Monetization config script present: $hasMonetizationConfig"
$lines += "- Monetization automation script present: $hasMonetizationAutomation"
$lines += ""
$lines += "## SEO + UX Risks"
$lines += "- HTML files checked (public): $($htmlFiles.Count)"
$lines += "- Files with user-scalable=no: $viewportBlockers"
$lines += "- Files missing canonical tag: $missingCanonical"
$lines += "- Files missing meta description: $missingDescription"
$lines += "- Thin content pages (< about 900 chars text): $thinContent"
$lines += "- Pages already loading AdSense script: $adSenseScriptPresent"
$lines += ""
$lines += "## Recommended Next Actions"
$lines += "1. Remove user-scalable=no from all templates and generated pages."
$lines += "2. Enable AdSense in assets/js/monetization-config.js after creating ad slots."
$lines += "3. Keep policy pages and affiliate disclosures updated monthly."
$lines += "4. Increase informational depth on thin pages before heavy ad placement."
$lines += ""

$dir = Split-Path -Parent $OutputFile
if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
$lines -join "`r`n" | Set-Content -Path $OutputFile -Encoding UTF8

Write-Output "ADSENSE_READINESS_SCORE=$score"
Write-Output "ADSENSE_READINESS_GRADE=$grade"
Write-Output "ADSENSE_REPORT=$OutputFile"
