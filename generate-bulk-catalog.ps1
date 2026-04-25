$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$catalogDir = Join-Path $PSScriptRoot 'tools\catalog'
if (-not (Test-Path $catalogDir)) {
    New-Item -ItemType Directory -Path $catalogDir | Out-Null
}

$categories = @(
    @{ Name = 'AI Writing';      Desc = 'content drafting, rewriting, summarization, and SEO copy workflows';         CatPage = '/ai-writing/' },
    @{ Name = 'AI Image';        Desc = 'image generation, style transfer, editing, and visual asset creation';        CatPage = '/ai-image/' },
    @{ Name = 'AI Video';        Desc = 'script-to-video, editing automation, captions, and short-form content';       CatPage = '/ai-video/' },
    @{ Name = 'AI Code';         Desc = 'code completion, debugging, refactoring, and developer workflow acceleration'; CatPage = '/ai-code/' },
    @{ Name = 'AI Voice';        Desc = 'voice generation, transcription, dubbing, and audio workflow automation';      CatPage = '/ai-voice/' },
    @{ Name = 'AI Productivity'; Desc = 'task automation, notes, summaries, planning, and execution workflows';        CatPage = '/tools/category/productivity.html' },
    @{ Name = 'AI Assistant';    Desc = 'general-purpose assistance for research, writing, and business operations';   CatPage = '/tools/category/ai-assistant.html' },
    @{ Name = 'AI Automation';   Desc = 'workflow orchestration, integrations, and process automation';               CatPage = '/tools/category/automation.html' }
)

$prefixes = @('Nova','Hyper','Quantum','Prompt','Vector','Signal','Neural','Atlas','Orbit','Pixel','Script','Logic','Fusion','Prism','Echo','Nimbus','Flux','Astra','Vertex','Lumen','Rapid','Core','Synth','Pilot','Cobalt','Sonic','Motion','Insight','Scale','Stack','Flow','Shift','Boost','Prime','Spark','Pulse','Sky','Omni','Ultra','Macro','Micro','Rocket','Stream','Bright','Deep','Meta','Auto','Smart','Vision','Forge')
$suffixes = @('AI','Studio','Labs','Engine','Flow','Cloud','Works','Suite','Pilot','Forge','Ops','Builder','Desk','Hub','One','Plus','Pro','Core','Bridge','Sync','Gen','Agent','Mind','Stack','Kit')

$allNames = New-Object System.Collections.Generic.List[string]
foreach ($p in $prefixes) {
    foreach ($s in $suffixes) {
        $allNames.Add("$p$s")
    }
}

$toolNames = $allNames | Select-Object -Unique | Select-Object -First 1000

function Slugify([string]$text) {
    $slug = $text.ToLower()
    $slug = $slug -replace '[^a-z0-9]+', '-'
    $slug = $slug.Trim('-')
    return $slug
}

function New-CatalogLongFormContentHtml([string]$Name, [string]$Category, [string]$Description) {
  return @"
<h2>Overview</h2>
<p>$Name is a generated catalog entry in the $Category category for visitors who want a practical starting point before deeper testing. The main question with any tool in this segment is whether it improves output quality, lowers turnaround time, and fits the workflows you already run. $Description</p>
<p>The most useful way to assess a profile like this is to compare it against one real use case, not a generic wish list. Teams usually get better results when they measure revision effort, reliability, and onboarding friction rather than assuming broad feature coverage automatically creates value.</p>

<h2>What To Check</h2>
<ul>
<li>Whether the tool is strong on a narrow, repeated workflow</li>
<li>How much editing or cleanup is still required after generation</li>
<li>Whether cost and implementation effort stay reasonable as usage grows</li>
</ul>
<p>Those checks make the profile more actionable because they connect product evaluation to actual team constraints. In many cases, a tool becomes valuable not because it does everything, but because it solves one expensive bottleneck reliably.</p>

<h2>Implementation Guidance</h2>
<p>Start by testing $Name on one workflow with defined acceptance criteria. Keep track of output quality, time saved, and the amount of human review still needed. If the result is stable across multiple runs, document the process and decide whether the category fit justifies broader rollout. That approach is much stronger than adopting tools on curiosity alone.</p>
"@
}

$cards = New-Object System.Collections.Generic.List[string]

for ($i = 0; $i -lt $toolNames.Count; $i++) {
    $name = $toolNames[$i]
    $cat = $categories[$i % $categories.Count]
    $slug = Slugify $name

    $title = "$name - $($cat.Name) Tool Profile"
    $desc = "$name is a $($cat.Name) platform for $($cat.Desc). Explore features, practical use cases, pricing direction, and alternatives on Lookforit.xyz."
    $canon = "https://lookforit.xyz/tools/catalog/$slug.html"
    $updatedAt = (Get-Date).ToString('yyyy-MM-dd')
    $status = 'generated-profile'
    $longFormContent = New-CatalogLongFormContentHtml -Name $name -Category $cat.Name -Description $desc

    $page = @"
<!DOCTYPE HTML>
<html lang="en">
<head>
<title>$title - Lookforit.xyz</title>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<meta name="robots" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
<meta name="googlebot" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
<meta name="theme-color" content="#0f172a" />
<meta name="description" content="$desc" />
<link rel="canonical" href="$canon" />
<meta property="og:title" content="$title - Lookforit.xyz" />
<meta property="og:description" content="$desc" />
<meta property="og:type" content="article" />
<meta property="og:url" content="$canon" />
<meta property="og:image" content="https://lookforit.xyz/Images/ai-tools-2026.jpg" />
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="$title - Lookforit.xyz" />
<meta name="twitter:description" content="$desc" />
<meta name="twitter:image" content="https://lookforit.xyz/Images/ai-tools-2026.jpg" />
<link rel="stylesheet" href="../../assets/css/main.css" />
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "$name",
  "applicationCategory": "$($cat.Name)",
  "description": "$desc",
  "url": "$canon",
  "dateModified": "$updatedAt"
}
</script>
</head>
<body class="is-preload">
<div id="wrapper"><div id="main"><div class="inner">
<header id="header"><a href="/" class="logo"><strong>Lookforit</strong> Tool Directory</a></header>
<section>
<header class="major"><h1>$name</h1></header>
<p class="tool-hero-intro"><strong>Category:</strong> $($cat.Name)</p>
<p><strong>Status:</strong> $status | <strong>Last reviewed:</strong> $updatedAt</p>
<p>$name is listed in our expanding AI tools catalog for teams and creators who want practical tooling for $($cat.Desc).</p>
<p>For accurate adoption decisions, compare real workflow fit, output consistency, onboarding complexity, and cost before committing.</p>
$longFormContent
<ul class="actions">
<li><a href="$($cat.CatPage)" class="button">Explore $($cat.Name)</a></li>
<li><a href="../index.html" class="button">Main Tools Directory</a></li>
<li><a href="/articles/" class="button">Read Articles</a></li>
</ul>
</section>
</div></div>
<div id="sidebar"><div class="inner"><section id="search" class="alt"><form method="get" action="/tools/"><input type="text" name="query" id="query" placeholder="Search AI tools..." /></form></section><nav id="menu"><header class="major"><h2>Menu</h2></header><ul><li><a href="/">Homepage</a></li><li><a href="/tools/">AI Tools</a></li><li><a href="/articles/">Articles</a></li><li><a href="/listing-requests/">Submit Your Tool</a></li></ul></nav><footer id="footer"><p>Lookforit.xyz is an AI tools directory listing hundreds of artificial intelligence tools for productivity, design, coding, marketing, and business.</p><div class="footer-policy-links"><a href="../../privacy-policy.html">Privacy Policy</a><a href="../../terms.html">Terms</a><a href="../../refund.html">Refund Policy</a><a href="../../disclaimer.html">Disclaimer</a><a href="../../faq.html">FAQ</a><a href="../../contact.html">Contact</a></div><p class="copyright">&copy; 2026 <a href="/">Lookforit.xyz</a>. All rights reserved.</p></footer></div></div></div>
<script src="../../assets/js/jquery.min.js"></script><script src="../../assets/js/browser.min.js"></script><script src="../../assets/js/breakpoints.min.js"></script><script src="../../assets/js/util.js"></script><script src="../../assets/js/main.js"></script>
<script src="/assets/js/tools-data.js"></script><script src="/assets/js/sidebar-search.js"></script>
</body>
</html>
"@

    Set-Content -Path (Join-Path $catalogDir ($slug + '.html')) -Value $page -Encoding UTF8 -NoNewline

    $cards.Add('<article class="card" data-name="' + $name.ToLower() + '" data-category="' + $cat.Name + '"><div class="card-body"><div class="category">' + $cat.Name + '</div><h2><a href="' + $slug + '.html">' + $name + '</a></h2><p><strong>Status:</strong> ' + $status + ' | <strong>Updated:</strong> ' + $updatedAt + '</p><p>Catalog profile for ' + $name + ' in ' + $cat.Name + ' workflows.</p><div class="cta"><a href="' + $slug + '.html">View &rarr;</a></div></div></article>')
}

$cardsHtml = $cards -join "`n"

$catalogIndex = @"
<!DOCTYPE HTML>
<html lang="en">
<head>
<title>AI Tools Catalog (1000+) - Lookforit.xyz</title>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<meta name="robots" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
<meta name="googlebot" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
<meta name="theme-color" content="#0f172a" />
<meta name="description" content="Explore a large-scale AI tools catalog with 1000+ tool profiles across writing, image, video, code, voice, automation, and productivity." />
<link rel="canonical" href="https://lookforit.xyz/tools/catalog/" />
<meta property="og:title" content="AI Tools Catalog (1000+) - Lookforit.xyz" />
<meta property="og:description" content="Explore a large-scale AI tools catalog with 1000+ tool profiles across writing, image, video, code, voice, automation, and productivity." />
<meta property="og:type" content="website" />
<meta property="og:url" content="https://lookforit.xyz/tools/catalog/" />
<meta property="og:image" content="https://lookforit.xyz/Images/ai-tools-2026.jpg" />
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="AI Tools Catalog (1000+) - Lookforit.xyz" />
<meta name="twitter:description" content="Explore a large-scale AI tools catalog with 1000+ tool profiles across writing, image, video, code, voice, automation, and productivity." />
<meta name="twitter:image" content="https://lookforit.xyz/Images/ai-tools-2026.jpg" />
<link rel="stylesheet" href="../../assets/css/main.css" />
<style>
.cards-grid { display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); gap:1rem; }
.card { border:1px solid rgba(15,23,42,0.12); border-radius:12px; padding:1rem; background:rgba(15,23,42,0.03); }
.card .category { font-size:0.8rem; opacity:0.8; margin-bottom:0.4rem; }
@media (max-width:980px){ .cards-grid { grid-template-columns:repeat(2,minmax(0,1fr)); } }
@media (max-width:640px){ .cards-grid { grid-template-columns:1fr; } }
</style>
</head>
<body class="is-preload">
<div id="wrapper"><div id="main"><div class="inner">
<header id="header"><a href="/" class="logo"><strong>Lookforit</strong> Large-Scale Tool Catalog</a></header>
<section>
<header class="major"><h1>AI Tools Catalog (1000+)</h1></header>
<p>This expanded directory helps visitors discover AI tools by category, search intent, and practical workflow context.</p>
<div class="row gtr-uniform" style="margin-bottom:1rem;">
<div class="col-8 col-12-small"><input type="search" id="catalog-search" placeholder="Search by tool name or category" /></div>
<div class="col-4 col-12-small"><select id="catalog-category"><option value="">All Categories</option><option>AI Writing</option><option>AI Image</option><option>AI Video</option><option>AI Code</option><option>AI Voice</option><option>AI Productivity</option><option>AI Assistant</option><option>AI Automation</option></select></div>
</div>
<div id="catalog-grid" class="cards-grid">
$cardsHtml
</div>
</section>
</div></div>
<div id="sidebar"><div class="inner"><section id="search" class="alt"><form method="get" action="/tools/"><input type="text" name="query" id="query" placeholder="Search AI tools..." /></form></section><nav id="menu"><header class="major"><h2>Menu</h2></header><ul><li><a href="/">Homepage</a></li><li><a href="/tools/">AI Tools</a></li><li><a href="/articles/">Articles</a></li><li><a href="/listing-requests/">Submit Your Tool</a></li></ul></nav><footer id="footer"><p>Lookforit.xyz is an AI tools directory listing hundreds of artificial intelligence tools for productivity, design, coding, marketing, and business.</p><div class="footer-policy-links"><a href="../../privacy-policy.html">Privacy Policy</a><a href="../../terms.html">Terms</a><a href="../../refund.html">Refund Policy</a><a href="../../disclaimer.html">Disclaimer</a><a href="../../faq.html">FAQ</a><a href="../../contact.html">Contact</a></div><p class="copyright">&copy; 2026 <a href="/">Lookforit.xyz</a>. All rights reserved.</p></footer></div></div></div>
<script src="../../assets/js/jquery.min.js"></script><script src="../../assets/js/browser.min.js"></script><script src="../../assets/js/breakpoints.min.js"></script><script src="../../assets/js/util.js"></script><script src="../../assets/js/main.js"></script>
<script>
(function(){
  var s=document.getElementById('catalog-search');
  var c=document.getElementById('catalog-category');
  var cards=[].slice.call(document.querySelectorAll('#catalog-grid .card'));
  function apply(){
    var q=(s.value||'').toLowerCase().trim();
    var cv=(c.value||'').toLowerCase().trim();
    cards.forEach(function(card){
      var name=(card.getAttribute('data-name')||'').toLowerCase();
      var cat=(card.getAttribute('data-category')||'').toLowerCase();
      var okQ=!q || name.indexOf(q)!==-1 || cat.indexOf(q)!==-1;
      var okC=!cv || cat===cv;
      card.style.display=(okQ && okC)?'':'none';
    });
  }
  s.addEventListener('input',apply);
  c.addEventListener('change',apply);
})();
</script>
<script src="/assets/js/tools-data.js"></script><script src="/assets/js/sidebar-search.js"></script>
</body>
</html>
"@

Set-Content -Path (Join-Path $catalogDir 'index.html') -Value $catalogIndex -Encoding UTF8 -NoNewline

Write-Output "CATALOG_GENERATED=$($toolNames.Count)"

