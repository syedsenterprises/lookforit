param(
  [string]$Root = ".",
  [string]$BacklogCsv = "ops/monetization/growth-backlog.csv",
  [int]$NewArticleCount = 3,
  [int]$RefreshCount = 10,
  [switch]$PublishNew
)

$ErrorActionPreference = "Stop"
Set-Location $Root

if (!(Test-Path $BacklogCsv)) {
  throw "Backlog CSV not found: $BacklogCsv"
}

function New-DraftBody {
  param(
    [string]$PrimaryKeyword,
    [string[]]$ToolLinks
  )

  $titleKeyword = ($PrimaryKeyword -replace "-", " ")
  $toolLines = @()
  foreach ($link in $ToolLinks) {
    $parts = $link.Split("|", 2)
    if ($parts.Count -eq 2) {
      $toolLines += "- [$($parts[0])]($($parts[1]))"
    }
  }

  return @"
## Why this category matters in 2026
The keyword \"$titleKeyword\" is becoming a strong commercial-intent search. Teams compare tools by pricing, speed, integrations, and reliability before buying.

## Free vs paid options
Free tools can help with testing and early workflows, while paid tools usually unlock better output quality, API access, and team collaboration features.

## Comparison table snapshot
- Compare setup time
- Compare free tier limits
- Compare team collaboration features
- Compare API and automation support

## Practical picks by use case
- Starter pick for beginners
- Best value pick for freelancers
- Team pick for operations
- Scale pick for agencies and enterprises

## Tool links for deeper research
$($toolLines -join "`r`n")

## How to choose without wasting budget
Use a 7-day test plan: shortlist 3 tools, run the same task flow, track quality and speed, and choose based on output consistency and total cost.

## FAQ
### Which tool is best for beginners?
Start with a free tier tool that has strong tutorials and templates.

### Are paid tools worth it?
Paid tools are worth it when they save enough time or revenue to exceed the monthly cost.

### What should I compare first?
Compare output quality, pricing limits, integrations, and reliability.
"@
}

$rows = Import-Csv -Path $BacklogCsv
$newRows = $rows | Where-Object { $_.type -eq "new-money-article" -and $_.status -eq "todo" } | Select-Object -First $NewArticleCount
$refreshRows = $rows | Where-Object { $_.type -eq "article-refresh" -and $_.status -eq "todo" } | Select-Object -First $RefreshCount

$topTools = $rows | Where-Object { $_.type -eq "money-page-optimization" } | Select-Object -First 5
$toolLinks = @()
foreach ($t in $topTools) {
  $label = ($t.slug -replace "-", " ").Trim()
  $toolLinks += "${label}|../tools/$($t.slug).html"
}

$published = @()
foreach ($row in $newRows) {
  $slug = $row.slug
  $title = (($slug -replace "-", " ").Trim() + " 2026: Free vs Paid Tools for Real Work")
  $description = "Commercial comparison of $($slug -replace '-', ' ') in 2026, including free vs paid options, practical use cases, and tool recommendations."
  $bodyPath = "ops/monetization/drafts/$slug.txt"

  $body = New-DraftBody -PrimaryKeyword $slug -ToolLinks $toolLinks
  $dir = Split-Path -Parent $bodyPath
  if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  $body | Set-Content -Path $bodyPath -Encoding UTF8

  if ($PublishNew) {
    & ./create-article.ps1 -Title $title -Slug $slug -Description $description -BodyFile $bodyPath -ImagePath "../Images/pic07.svg" -ImageAlt $title -PublishedText "Published April 2026" -UpdateIndex $true
    $published += $slug
  }
}

$refreshed = @()
foreach ($row in $refreshRows) {
  $slug = $row.slug
  $articlePath = "articles/$slug.html"
  if (!(Test-Path $articlePath)) { continue }

  $raw = Get-Content -Raw $articlePath
  if ($raw -match 'data-weekly-refresh="1"') {
    $refreshed += $slug
    continue
  }

  $internalLinksHtml = @(
    '<li><a href="../tools/chatgpt.html">ChatGPT</a></li>',
    '<li><a href="../tools/claude.html">Claude</a></li>',
    '<li><a href="../tools/google-gemini.html">Google Gemini</a></li>',
    '<li><a href="../tools/midjourney.html">Midjourney</a></li>',
    '<li><a href="../tools/cursor.html">Cursor</a></li>'
  )

  $refreshBlock = @"
<section class="weekly-refresh-block" data-weekly-refresh="1">
<h2>Updated for April 2026</h2>
<p><strong>New screenshots checklist:</strong> verify homepage, pricing page, and product workflow screens.</p>
<h3>Pricing Snapshot (Free vs Paid)</h3>
<table>
<thead><tr><th>Tier</th><th>Typical Price</th><th>Best For</th></tr></thead>
<tbody>
<tr><td>Free</td><td>$0</td><td>Testing and small workloads</td></tr>
<tr><td>Starter Paid</td><td>$15-$39/mo</td><td>Freelancers and solo creators</td></tr>
<tr><td>Team</td><td>$49+/mo</td><td>Collaboration and workflow automation</td></tr>
</tbody>
</table>
<h3>Internal Tool Links</h3>
<ul>
$($internalLinksHtml -join "`r`n")
</ul>
</section>
"@

  $marker = '<div id="sidebar">'
  $idx = $raw.IndexOf($marker)
  if ($idx -gt 0) {
    $updated = $raw.Insert($idx, $refreshBlock + "`r`n")
    Set-Content -Path $articlePath -Value $updated -Encoding UTF8
    $refreshed += $slug
  }
}

$reportPath = "ops/monetization/weekly-seo-engine-report.md"
$report = @()
$report += "# Weekly SEO Engine Report"
$report += ""
$report += "- Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$report += "- New article drafts prepared: $($newRows.Count)"
$report += "- New articles published this run: $($published.Count)"
$report += "- Existing articles refreshed: $($refreshed.Count)"
$report += ""
$report += "## New Article Slugs"
foreach ($r in $newRows) { $report += "- $($r.slug)" }
$report += ""
$report += "## Refreshed Article Slugs"
foreach ($r in $refreshed) { $report += "- $r" }
$report -join "`r`n" | Set-Content -Path $reportPath -Encoding UTF8

Write-Output "SEO_ENGINE_DRAFTS=$($newRows.Count)"
Write-Output "SEO_ENGINE_PUBLISHED=$($published.Count)"
Write-Output "SEO_ENGINE_REFRESHED=$($refreshed.Count)"
Write-Output "SEO_ENGINE_REPORT=$reportPath"
