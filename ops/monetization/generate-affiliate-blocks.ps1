param(
  [string]$Root = ".",
  [string]$BacklogCsv = "ops/monetization/growth-backlog.csv",
  [int]$TopN = 30
)

$ErrorActionPreference = "Stop"
Set-Location $Root

if (!(Test-Path $BacklogCsv)) {
  throw "Backlog CSV not found: $BacklogCsv"
}

$rows = Import-Csv -Path $BacklogCsv | Where-Object { $_.type -eq "money-page-optimization" } | Select-Object -First $TopN
$inserted = 0
$already = 0

foreach ($row in $rows) {
  $slug = $row.slug
  $path = "tools/$slug.html"
  if (!(Test-Path $path)) {
    continue
  }

  $raw = Get-Content -Raw $path
  if ($raw -like '*data-affiliate-block*') {
    $already++
    continue
  }

  $label = ($slug -replace "-", " ").Trim()
  $block = @"
<section class="affiliate-money-block" data-affiliate-block="1">
<header class="major"><h2>$label Pricing, Pros, and Best Use Cases</h2></header>
<p><strong>Quick verdict:</strong> compare free vs paid plans and choose based on your workload, team size, and integration needs.</p>
<table>
<thead><tr><th>Plan Type</th><th>Best For</th><th>Typical Price</th></tr></thead>
<tbody>
<tr><td>Free</td><td>Testing, small tasks</td><td>$0</td></tr>
<tr><td>Starter</td><td>Freelancers and creators</td><td>$15-$39/mo</td></tr>
<tr><td>Team</td><td>Workflow and collaboration</td><td>$49+/mo</td></tr>
</tbody>
</table>
<h3>Pros</h3>
<ul>
<li>Fast onboarding for first-time users</li>
<li>Strong workflow value for targeted use cases</li>
<li>Clear upgrade path from free to paid</li>
</ul>
<h3>Cons</h3>
<ul>
<li>Free plans can be limited for production usage</li>
<li>Advanced automation usually needs paid tiers</li>
</ul>
<ul class="actions">
<li><a href="#" class="button primary" data-monetization="affiliate-cta">Check Official Pricing</a></li>
<li><a href="/listing-requests/" class="button">Submit Your Tool</a></li>
</ul>
</section>
"@

  $marker = '<div id="sidebar">'
  $idx = $raw.IndexOf($marker)
  if ($idx -gt 0) {
    $updated = $raw.Insert($idx, $block + "`r`n")
    Set-Content -Path $path -Value $updated -Encoding UTF8
    $inserted++
  }
}

Write-Output "AFFILIATE_BLOCKS_INSERTED=$inserted"
Write-Output "AFFILIATE_BLOCKS_ALREADY_PRESENT=$already"
Write-Output "AFFILIATE_BLOCKS_TARGET=$TopN"
