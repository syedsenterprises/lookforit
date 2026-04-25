param(
  [switch]$RebuildIndexOnly
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$catalogDir = Join-Path $PSScriptRoot 'tools/catalog'
$logoDir = Join-Path $catalogDir 'logos'
if (-not (Test-Path $logoDir)) {
  New-Item -ItemType Directory -Path $logoDir | Out-Null
}

$categoryMap = @{
  'AI Writing'      = '/ai-writing/'
  'AI Image'        = '/ai-image/'
  'AI Video'        = '/ai-video/'
  'AI Code'         = '/ai-code/'
  'AI Voice'        = '/ai-voice/'
  'AI Productivity' = '/tools/category/productivity.html'
  'AI Assistant'    = '/tools/category/ai-assistant.html'
  'AI Automation'   = '/tools/category/automation.html'
}

$categoryFeatureMap = @{
  'AI Writing' = @('Draft long-form and short-form copy quickly', 'Rewrite content for tone, clarity, and audience intent', 'Generate outlines, briefs, and SEO-first structure')
  'AI Image' = @('Create visual concepts from short prompts', 'Edit and upscale assets for marketing and product pages', 'Speed up design iteration with style variations')
  'AI Video' = @('Turn scripts into publish-ready clips', 'Automate captions, cuts, and repurposing workflows', 'Scale social and campaign video production')
  'AI Code' = @('Accelerate coding with context-aware completion', 'Reduce review cycles with refactor and debugging support', 'Improve developer velocity across common tasks')
  'AI Voice' = @('Generate natural voice output for media and product flows', 'Transcribe speech and meetings into searchable text', 'Support dubbing and multilingual audio delivery')
  'AI Productivity' = @('Summarize meetings, docs, and planning artifacts', 'Automate repetitive updates and team workflows', 'Keep projects aligned with AI-assisted task orchestration')
  'AI Assistant' = @('Handle research and synthesis tasks faster', 'Support writing, planning, and business operations', 'Provide practical answers grounded in workflow context')
  'AI Automation' = @('Connect apps and trigger multi-step workflows', 'Reduce manual work with repeatable process automation', 'Improve operational consistency with rule-driven flows')
}

$categoryUseCaseMap = @{
  'AI Writing' = @('Blog and landing page production', 'Email and ad copy creation', 'Editorial refresh and optimization')
  'AI Image' = @('Ad and social creative generation', 'Product visual mockups', 'Thumbnail and banner iteration')
  'AI Video' = @('Short-form social video pipeline', 'Product explainers and demos', 'Training and internal comms')
  'AI Code' = @('Feature scaffolding and implementation', 'Legacy code refactoring', 'Test and documentation assistance')
  'AI Voice' = @('Voiceovers and narration', 'Call and meeting transcription', 'Localization and dubbing')
  'AI Productivity' = @('Planning and sprint coordination', 'Knowledge base summarization', 'Cross-team update automation')
  'AI Assistant' = @('Research and decision support', 'Drafting and editing workflows', 'Daily productivity and operations help')
  'AI Automation' = @('Lead and CRM routing', 'Support and operations workflows', 'Internal approval and notification flows')
}

function ConvertFrom-HtmlText([string]$Value) {
  if ([string]::IsNullOrWhiteSpace($Value)) { return '' }
  return [System.Net.WebUtility]::HtmlDecode($Value)
}

function ConvertTo-HtmlText([string]$Value) {
  if ([string]::IsNullOrWhiteSpace($Value)) { return '' }
  return [System.Net.WebUtility]::HtmlEncode($Value)
}

function New-CatalogLongFormContentHtml(
  [string]$Name,
  [string]$Category,
  [string]$Description,
  [string[]]$Features,
  [string[]]$UseCases
) {
  $safeName = ConvertTo-HtmlText $Name
  $safeCategory = ConvertTo-HtmlText $Category
  $safeDesc = ConvertTo-HtmlText $Description
  $safeFeatures = @($Features | ForEach-Object { ConvertTo-HtmlText $_ })
  $safeUseCases = @($UseCases | ForEach-Object { ConvertTo-HtmlText $_ })

  return @"
<h2>Overview</h2>
<p>$safeName is a cataloged option in the $safeCategory category for teams that want faster execution, more predictable output quality, and fewer manual handoff points in everyday AI workflows. At a practical level, the important question is not whether a tool can produce an impressive demo, but whether it can hold up during repeated use with real deadlines, real stakeholders, and real quality standards. $safeDesc</p>
<p>For most buyers or operators, the value of $safeName should be judged by workflow fit rather than hype. A strong tool in this category should reduce rework, make onboarding easier for teammates, and improve consistency across repeated tasks. That means testing it with your actual prompts, source files, collaboration patterns, and review process. A short trial with production-like inputs usually tells you more than a long list of marketing claims.</p>

<h2>Key Features and Workflow Strengths</h2>
<ul>
<li>$($safeFeatures[0])</li>
<li>$($safeFeatures[1])</li>
<li>$($safeFeatures[2])</li>
</ul>

<h2>Who Should Consider $safeName</h2>
<p>$safeName is generally a better fit for people who already have a defined workflow and want to improve speed or consistency without lowering standards. Teams with clear templates, review checkpoints, and ownership rules tend to get more value from AI tooling than teams that are still improvising the process itself. It can also be a useful option for solo operators who need leverage across production, planning, and delivery but still want enough control to maintain quality.</p>

<h2>Best Fit Use Cases</h2>
<ul>
<li>$($safeUseCases[0])</li>
<li>$($safeUseCases[1])</li>
<li>$($safeUseCases[2])</li>
</ul>

<h2>Evaluation Checklist</h2>
<ul>
<li>Output quality under real project constraints</li>
<li>Speed and reliability across repeated runs</li>
<li>Integration effort with your current stack</li>
<li>Team usability and onboarding friction</li>
<li>Total cost and scaling predictability</li>
</ul>
<p>A useful buying rule is to score $safeName against one narrow workflow before rolling it out broadly. Use the same inputs across two or three competing tools, compare the number of edits needed, and note whether the output format is already close to publishable or deployable. That method keeps the evaluation grounded and makes it easier to defend the final choice internally.</p>

<h2>Implementation Advice</h2>
<p>If you decide to move forward with $safeName, start small. Pick one workflow, define a review rubric, and document the inputs that consistently produce acceptable output. Once that baseline is stable, you can expand usage to adjacent tasks and assign ownership for prompts, templates, and quality control. This approach reduces confusion, makes results easier to compare over time, and turns the tool into part of a system instead of a one-off experiment.</p>
"@
}

function SlugToTitle([string]$Slug) {
  return ($Slug -split '-') | ForEach-Object {
    if ($_.Length -eq 0) { return $_ }
    if ($_.Length -eq 1) { return $_.ToUpper() }
    return $_.Substring(0,1).ToUpper() + $_.Substring(1)
  } -join ' '
}

function Get-Initials([string]$Name) {
  $parts = @($Name -split '[^A-Za-z0-9]+' | Where-Object { $_ -and $_.Length -gt 0 })
  if ($parts.Count -ge 2) {
    return (([string]$parts[0]).Substring(0,1) + ([string]$parts[1]).Substring(0,1)).ToUpper()
  }
  if ($parts.Count -eq 1) {
    $part = [string]$parts[0]
    if ($part.Length -ge 2) { return $part.Substring(0,2).ToUpper() }
    return $part.ToUpper()
  }
  return 'AI'
}

function New-LogoSvg([string]$Name, [string]$Category, [string]$Initials) {
  $palette = @{
    'AI Writing' = @{ A = '#f97316'; B = '#fb923c' }
    'AI Image' = @{ A = '#2563eb'; B = '#38bdf8' }
    'AI Video' = @{ A = '#dc2626'; B = '#f97316' }
    'AI Code' = @{ A = '#0f766e'; B = '#14b8a6' }
    'AI Voice' = @{ A = '#7c3aed'; B = '#a78bfa' }
    'AI Productivity' = @{ A = '#0f766e'; B = '#22c55e' }
    'AI Assistant' = @{ A = '#1d4ed8'; B = '#22d3ee' }
    'AI Automation' = @{ A = '#be185d'; B = '#f43f5e' }
  }
  $p = if ($palette.ContainsKey($Category)) { $palette[$Category] } else { @{ A = '#334155'; B = '#64748b' } }
  $safeName = ConvertTo-HtmlText $Name
  $safeCat = ConvertTo-HtmlText $Category
  return @"
<svg xmlns="http://www.w3.org/2000/svg" width="240" height="240" viewBox="0 0 240 240" role="img" aria-labelledby="title desc">
  <title id="title">$safeName logo</title>
  <desc id="desc">Logo badge for $safeName in $safeCat category</desc>
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="$($p.A)"/>
      <stop offset="100%" stop-color="$($p.B)"/>
    </linearGradient>
  </defs>
  <rect width="240" height="240" rx="36" fill="url(#g)"/>
  <circle cx="185" cy="55" r="26" fill="rgba(255,255,255,0.22)"/>
  <circle cx="55" cy="190" r="22" fill="rgba(255,255,255,0.18)"/>
  <text x="120" y="136" text-anchor="middle" font-family="Segoe UI, Arial, sans-serif" font-size="74" font-weight="700" fill="#ffffff">$Initials</text>
</svg>
"@
}

function ConvertFrom-ToolHtml([string]$Raw, [string]$Slug) {
  $name = ''
  $category = 'AI Assistant'
  $status = 'catalog-profile'
  $updated = (Get-Date).ToString('yyyy-MM-dd')
  $description = ''
  $website = ''

  $h1 = [regex]::Match($Raw, '<h1>([^<]+)</h1>', 'IgnoreCase')
  if ($h1.Success) { $name = ConvertFrom-HtmlText $h1.Groups[1].Value.Trim() }
  if (-not $name) { $name = SlugToTitle $Slug }

  $cat = [regex]::Match($Raw, '<strong>Category:</strong>\s*([^<]+)</p>', 'IgnoreCase')
  if ($cat.Success) { $category = ConvertFrom-HtmlText $cat.Groups[1].Value.Trim() }

  $statusMatch = [regex]::Match($Raw, '<strong>Status:</strong>\s*([^|<]+)\s*\|\s*<strong>Last reviewed:</strong>\s*([^<]+)</p>', 'IgnoreCase')
  if ($statusMatch.Success) {
    $status = ConvertFrom-HtmlText $statusMatch.Groups[1].Value.Trim()
    $updated = ConvertFrom-HtmlText $statusMatch.Groups[2].Value.Trim()
  }

  $meta = [regex]::Match($Raw, '<meta\s+name="description"\s+content="([^"]*)"', 'IgnoreCase')
  if ($meta.Success) { $description = ConvertFrom-HtmlText $meta.Groups[1].Value.Trim() }

  $web = [regex]::Match($Raw, '<strong>Official website:</strong>\s*<a[^>]*href="([^"]+)"', 'IgnoreCase')
  if ($web.Success) { $website = ConvertFrom-HtmlText $web.Groups[1].Value.Trim() }

  if (-not $description) {
    $description = "$name helps teams execute practical $($category.ToLower()) workflows with better speed, consistency, and decision quality."
  }

  if (-not $website) {
    $website = "https://lookforit.xyz/tools/$Slug.html"
  }

  return [pscustomobject]@{
    Name = $name
    Category = $category
    Status = $status
    UpdatedAt = $updated
    Description = $description
    Website = $website
    Slug = $Slug
  }
}

$toolRecords = New-Object System.Collections.Generic.List[object]
$files = Get-ChildItem -Path $catalogDir -File -Filter '*.html' | Where-Object { $_.Name -ne 'index.html' }

foreach ($file in $files) {
  $slug = [IO.Path]::GetFileNameWithoutExtension($file.Name)
  $raw = Get-Content -LiteralPath $file.FullName -Raw
  $record = ConvertFrom-ToolHtml -Raw $raw -Slug $slug
  $toolRecords.Add($record)

  if ($RebuildIndexOnly) { continue }

  $catPage = if ($categoryMap.ContainsKey($record.Category)) { $categoryMap[$record.Category] } else { '/tools/' }
  $features = if ($categoryFeatureMap.ContainsKey($record.Category)) { $categoryFeatureMap[$record.Category] } else { @('Practical workflow support', 'Faster execution for repeatable tasks', 'Better output consistency') }
  $useCases = if ($categoryUseCaseMap.ContainsKey($record.Category)) { $categoryUseCaseMap[$record.Category] } else { @('Research and planning', 'Content and production support', 'Operations and collaboration') }

  $initials = Get-Initials $record.Name
  $logoSvg = New-LogoSvg -Name $record.Name -Category $record.Category -Initials $initials
  Set-Content -LiteralPath (Join-Path $logoDir ($record.Slug + '.svg')) -Value $logoSvg -Encoding UTF8 -NoNewline

  $safeName = ConvertTo-HtmlText $record.Name
  $safeCategory = ConvertTo-HtmlText $record.Category
  $safeStatus = ConvertTo-HtmlText $record.Status
  $safeUpdated = ConvertTo-HtmlText $record.UpdatedAt
  $safeDesc = ConvertTo-HtmlText $record.Description
  $safeWebsite = ConvertTo-HtmlText $record.Website
  $safeCatPage = ConvertTo-HtmlText $catPage
  $canon = "https://lookforit.xyz/tools/catalog/$($record.Slug).html"
  $longFormContent = New-CatalogLongFormContentHtml -Name $record.Name -Category $record.Category -Description $record.Description -Features $features -UseCases $useCases

  $toolPage = @"
<!DOCTYPE HTML>
<html lang="en">
<head>
<title>$safeName - $safeCategory Tool Profile - Lookforit.xyz</title>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<meta name="robots" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
<meta name="googlebot" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
<meta name="theme-color" content="#0f172a" />
<meta name="description" content="$safeDesc" />
<link rel="canonical" href="$canon" />
<meta property="og:title" content="$safeName - $safeCategory Tool Profile - Lookforit.xyz" />
<meta property="og:description" content="$safeDesc" />
<meta property="og:type" content="article" />
<meta property="og:url" content="$canon" />
<meta property="og:image" content="https://lookforit.xyz/tools/catalog/logos/$($record.Slug).svg" />
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="$safeName - $safeCategory Tool Profile - Lookforit.xyz" />
<meta name="twitter:description" content="$safeDesc" />
<meta name="twitter:image" content="https://lookforit.xyz/tools/catalog/logos/$($record.Slug).svg" />
<link rel="stylesheet" href="../../assets/css/main.css?v=20260315-structure2" />
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "$safeName",
  "applicationCategory": "$safeCategory",
  "description": "$safeDesc",
  "url": "$canon",
  "dateModified": "$safeUpdated"
}
</script>
</head>
<body class="is-preload">
<div id="wrapper"><div id="main"><div class="inner">
<header id="header"><a href="/" class="logo"><strong>Lookforit</strong> Tool Catalog</a></header>
<section>
<div class="catalog-tool-hero">
  <img src="logos/$($record.Slug).svg" alt="$safeName logo" class="catalog-tool-logo" loading="lazy" decoding="async" />
  <div>
    <header class="major"><h1>$safeName</h1></header>
    <p class="tool-hero-intro"><strong>Category:</strong> $safeCategory</p>
    <p><strong>Status:</strong> $safeStatus | <strong>Last reviewed:</strong> $safeUpdated</p>
    <p class="catalog-tool-summary">$safeDesc</p>
    <p><strong>Official website:</strong> <a href="$safeWebsite" target="_blank" rel="noopener noreferrer nofollow">$safeWebsite</a></p>
  </div>
</div>

$longFormContent

<ul class="actions">
<li><a href="$safeCatPage" class="button">Explore $safeCategory</a></li>
<li><a href="../index.html" class="button">Main Tools Directory</a></li>
<li><a href="/tools/catalog/" class="button">Catalog Hub</a></li>
<li><a href="/articles/" class="button">Read Related Guides</a></li>
</ul>
</section>
</div></div>
<div id="sidebar"><div class="inner"><section id="search" class="alt"><form method="get" action="/tools/"><input type="text" name="query" id="query" placeholder="Search AI tools..." /></form></section><nav id="menu"><header class="major"><h2>Menu</h2></header><ul><li><a href="/">Homepage</a></li><li><a href="/tools/">AI Tools</a></li><li><a href="/articles/">Articles</a></li><li><a href="/listing-requests/">Submit Your Tool</a></li></ul></nav><footer id="footer"><p>Lookforit.xyz is an AI tools directory listing hundreds of artificial intelligence tools for productivity, design, coding, marketing, and business.</p><div class="footer-policy-links"><a href="../../privacy-policy.html">Privacy Policy</a><a href="../../terms.html">Terms</a><a href="../../refund.html">Refund Policy</a><a href="../../disclaimer.html">Disclaimer</a><a href="../../faq.html">FAQ</a><a href="../../contact.html">Contact</a></div><p class="copyright">&copy; 2026 <a href="/">Lookforit.xyz</a>. All rights reserved.</p></footer></div></div></div>
<script src="../../assets/js/jquery.min.js"></script><script src="../../assets/js/browser.min.js"></script><script src="../../assets/js/breakpoints.min.js"></script><script src="../../assets/js/util.js"></script><script src="../../assets/js/main.js"></script>
<script src="/assets/js/tools-data.js"></script><script src="/assets/js/sidebar-search.js"></script>
</body>
</html>
"@

  Set-Content -LiteralPath $file.FullName -Value $toolPage -Encoding UTF8 -NoNewline
}

$sorted = $toolRecords | Sort-Object Name
$manifestData = $sorted | ForEach-Object {
  [pscustomobject]@{
    n = $_.Name
    s = $_.Slug
    c = $_.Category
    d = $_.Description
    st = $_.Status
    u = $_.UpdatedAt
    l = ('logos/' + $_.Slug + '.svg')
  }
}

$json = $manifestData | ConvertTo-Json -Depth 4
$manifestJs = "window.LookforitCatalogManifest = $json;"
Set-Content -LiteralPath (Join-Path $catalogDir 'catalog-manifest.js') -Value $manifestJs -Encoding UTF8 -NoNewline

$indexHtml = @"
<!DOCTYPE HTML>
<html lang="en">
<head>
<title>AI Tools Catalog (1000+) - Lookforit.xyz</title>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<meta name="robots" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
<meta name="googlebot" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
<meta name="theme-color" content="#0f172a" />
<meta name="description" content="Explore 1000+ AI tools with richer profiles, logos, categories, and practical use-case context." />
<link rel="canonical" href="https://lookforit.xyz/tools/catalog/" />
<meta property="og:title" content="AI Tools Catalog (1000+) - Lookforit.xyz" />
<meta property="og:description" content="Explore 1000+ AI tools with richer profiles, logos, categories, and practical use-case context." />
<meta property="og:type" content="website" />
<meta property="og:url" content="https://lookforit.xyz/tools/catalog/" />
<meta property="og:image" content="https://lookforit.xyz/Images/ai-tools-2026.jpg" />
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="AI Tools Catalog (1000+) - Lookforit.xyz" />
<meta name="twitter:description" content="Explore 1000+ AI tools with richer profiles, logos, categories, and practical use-case context." />
<meta name="twitter:image" content="https://lookforit.xyz/Images/ai-tools-2026.jpg" />
<link rel="stylesheet" href="../../assets/css/main.css?v=20260315-structure2" />
</head>
<body class="is-preload">
<div id="wrapper"><div id="main"><div class="inner">
<header id="header"><a href="/" class="logo"><strong>Lookforit</strong> AI Tool Catalog</a></header>
<section>
<header class="major"><h1>AI Tools Catalog (1000+)</h1></header>
<p>Browse and compare AI tools by category, status, and practical fit. Profiles include richer context, quick evaluation points, and logo-based recognition.</p>
<div class="catalog-controls box">
  <div class="row gtr-uniform">
    <div class="col-5 col-12-small"><input type="search" id="catalog-search" placeholder="Search by name, category, or description" /></div>
    <div class="col-3 col-12-small"><select id="catalog-category"><option value="">All Categories</option></select></div>
    <div class="col-2 col-12-small"><select id="catalog-status"><option value="">All Status</option><option value="verified-existing">Verified</option><option value="curated-trending">Trending</option><option value="curated-expansion">Expansion</option><option value="generated-profile">Generated</option></select></div>
    <div class="col-2 col-12-small"><select id="catalog-page-size"><option value="24">24 per page</option><option value="48">48 per page</option><option value="96">96 per page</option></select></div>
  </div>
  <p id="catalog-count" style="margin:0.8rem 0 0; font-size:0.9rem; color:#6b7280;">Loading catalog...</p>
</div>
<div id="catalog-grid" class="catalog-cards-grid"></div>
<div id="catalog-pager" class="catalog-pager"></div>
</section>
</div></div>
<div id="sidebar"><div class="inner"><section id="search" class="alt"><form method="get" action="/tools/"><input type="text" name="query" id="query" placeholder="Search AI tools..." /></form></section><nav id="menu"><header class="major"><h2>Menu</h2></header><ul><li><a href="/">Homepage</a></li><li><a href="/tools/">AI Tools</a></li><li><a href="/articles/">Articles</a></li><li><a href="/listing-requests/">Submit Your Tool</a></li></ul></nav><footer id="footer"><p>Lookforit.xyz is an AI tools directory listing hundreds of artificial intelligence tools for productivity, design, coding, marketing, and business.</p><div class="footer-policy-links"><a href="../../privacy-policy.html">Privacy Policy</a><a href="../../terms.html">Terms</a><a href="../../refund.html">Refund Policy</a><a href="../../disclaimer.html">Disclaimer</a><a href="../../faq.html">FAQ</a><a href="../../contact.html">Contact</a></div><p class="copyright">&copy; 2026 <a href="/">Lookforit.xyz</a>. All rights reserved.</p></footer></div></div></div>
<script src="../../assets/js/jquery.min.js"></script><script src="../../assets/js/browser.min.js"></script><script src="../../assets/js/breakpoints.min.js"></script><script src="../../assets/js/util.js"></script><script src="../../assets/js/main.js"></script>
<script src="catalog-manifest.js"></script>
<script>
(function(){
  var all = (window.LookforitCatalogManifest || []).slice();
  var grid = document.getElementById('catalog-grid');
  var pager = document.getElementById('catalog-pager');
  var countEl = document.getElementById('catalog-count');
  var search = document.getElementById('catalog-search');
  var category = document.getElementById('catalog-category');
  var status = document.getElementById('catalog-status');
  var pageSizeSel = document.getElementById('catalog-page-size');
  var page = 1;

  function uniq(values){
    var out = [];
    var seen = {};
    values.forEach(function(v){ if(!v) return; if(seen[v]) return; seen[v] = 1; out.push(v); });
    return out.sort();
  }

  uniq(all.map(function(x){ return x.c; })).forEach(function(c){
    var o = document.createElement('option');
    o.value = c;
    o.textContent = c;
    category.appendChild(o);
  });

  function cardNode(item){
    var article = document.createElement('article');
    article.className = 'catalog-card';

    var img = document.createElement('img');
    img.className = 'catalog-card-logo';
    img.setAttribute('src', item.l);
    img.setAttribute('alt', item.n + ' logo');
    img.setAttribute('loading', 'lazy');
    img.setAttribute('decoding', 'async');
    article.appendChild(img);

    var body = document.createElement('div');
    body.className = 'catalog-card-body';

    var cat = document.createElement('div');
    cat.className = 'category';
    cat.textContent = item.c;
    body.appendChild(cat);

    var h2 = document.createElement('h2');
    var titleLink = document.createElement('a');
    titleLink.setAttribute('href', item.s + '.html');
    titleLink.textContent = item.n;
    h2.appendChild(titleLink);
    body.appendChild(h2);

    var meta = document.createElement('p');
    meta.innerHTML = '<strong>Status:</strong> ' + item.st + ' | <strong>Updated:</strong> ' + item.u;
    body.appendChild(meta);

    var desc = document.createElement('p');
    desc.textContent = item.d;
    body.appendChild(desc);

    var ctaWrap = document.createElement('div');
    ctaWrap.className = 'cta';
    var ctaLink = document.createElement('a');
    ctaLink.setAttribute('href', item.s + '.html');
    ctaLink.textContent = 'Open Profile ->';
    ctaWrap.appendChild(ctaLink);
    body.appendChild(ctaWrap);

    article.appendChild(body);
    return article;
  }

  function filtered(){
    var q = (search.value || '').toLowerCase().trim();
    var c = category.value || '';
    var st = status.value || '';
    return all.filter(function(item){
      var qOk = !q || item.n.toLowerCase().indexOf(q) !== -1 || item.c.toLowerCase().indexOf(q) !== -1 || item.d.toLowerCase().indexOf(q) !== -1;
      var cOk = !c || item.c === c;
      var sOk = !st || item.st === st;
      return qOk && cOk && sOk;
    });
  }

  function drawPager(totalPages){
    pager.innerHTML = '';
    if (totalPages <= 1) return;
    var start = Math.max(1, page - 2);
    var end = Math.min(totalPages, start + 4);
    if (end - start < 4) start = Math.max(1, end - 4);

    function btn(label, p, disabled){
      var b = document.createElement('button');
      b.type = 'button';
      b.textContent = label;
      b.disabled = !!disabled;
      if (p === page) b.className = 'is-current';
      b.addEventListener('click', function(){ page = p; render(); window.scrollTo({ top: 0, behavior: 'smooth' }); });
      pager.appendChild(b);
    }

    btn('Prev', Math.max(1, page - 1), page === 1);
    for (var p = start; p <= end; p++) btn(String(p), p, false);
    btn('Next', Math.min(totalPages, page + 1), page === totalPages);
  }

  function render(){
    var list = filtered();
    var pageSize = parseInt(pageSizeSel.value || '24', 10);
    var totalPages = Math.max(1, Math.ceil(list.length / pageSize));
    if (page > totalPages) page = totalPages;
    var start = (page - 1) * pageSize;
    var pageList = list.slice(start, start + pageSize);

    countEl.textContent = 'Showing ' + pageList.length + ' of ' + list.length + ' matching tools (' + all.length + ' total profiles).';
    grid.innerHTML = '';
    pageList.forEach(function(item){
      grid.appendChild(cardNode(item));
    });
    drawPager(totalPages);
  }

  [search, category, status, pageSizeSel].forEach(function(el){
    el.addEventListener('input', function(){ page = 1; render(); });
    el.addEventListener('change', function(){ page = 1; render(); });
  });

  render();
})();
</script>
<script src="/assets/js/tools-data.js"></script><script src="/assets/js/sidebar-search.js"></script>
</body>
</html>
"@

Set-Content -LiteralPath (Join-Path $catalogDir 'index.html') -Value $indexHtml -Encoding UTF8 -NoNewline

Write-Output "CATALOG_UPGRADED=$($toolRecords.Count)"
Write-Output "CATALOG_LOGOS_WRITTEN=$($toolRecords.Count)"
Write-Output "CATALOG_MANIFEST_WRITTEN=1"

