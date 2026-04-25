param(
  [int]$NewToolsCount = 100,
  [bool]$RebuildSitemap = $true
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$toolsDir = Join-Path $PSScriptRoot 'tools'
$toolsIndexPath = Join-Path $toolsDir 'index.html'
$toolsDataPath = Join-Path $PSScriptRoot 'assets/js/tools-data.js'

if (-not (Test-Path $toolsDir)) { throw "Missing tools directory: $toolsDir" }
if (-not (Test-Path $toolsIndexPath)) { throw "Missing tools index: $toolsIndexPath" }
if (-not (Test-Path $toolsDataPath)) { throw "Missing tools data file: $toolsDataPath" }

$categoryMap = @(
  @{ Name='AI Assistant'; CardPath='category/ai-assistant.html'; Keywords='task planning, summaries, and research'; Intro='general assistant workflows'; Desc='AI assistant platform focused on reliable task support, planning, and decision guidance.' },
  @{ Name='AI Chatbot'; CardPath='category/ai-chatbot.html'; Keywords='conversation, customer replies, and prompt workflows'; Intro='chatbot workflows'; Desc='Conversational AI chatbot designed for interactive support, ideation, and workflow acceleration.' },
  @{ Name='Content'; CardPath='category/content.html'; Keywords='content drafts, editing, and publishing operations'; Intro='content operations'; Desc='Content-focused AI tool for drafting, rewriting, and production-grade publishing support.' },
  @{ Name='Design'; CardPath='category/design.html'; Keywords='visual creation, brand consistency, and creative delivery'; Intro='design workflows'; Desc='Design automation platform that helps teams produce faster visuals with consistent style quality.' },
  @{ Name='Developer Tools'; CardPath='category/developer-tools.html'; Keywords='coding, debugging, and software delivery'; Intro='developer workflows'; Desc='Developer-first AI tool for faster coding, debugging, and technical documentation workflows.' },
  @{ Name='Image Generation'; CardPath='category/image-generation.html'; Keywords='image generation, concept art, and campaign creatives'; Intro='image generation workflows'; Desc='Image generation tool for prompt-based visuals, rapid concepts, and production-ready assets.' },
  @{ Name='Image Editing'; CardPath='category/image-editing.html'; Keywords='retouching, enhancement, and visual cleanup'; Intro='image editing workflows'; Desc='Image editing AI platform for cleanup, enhancement, and practical visual post-production tasks.' },
  @{ Name='Productivity'; CardPath='category/productivity.html'; Keywords='knowledge capture, planning, and team execution'; Intro='productivity workflows'; Desc='Productivity AI tool for planning, summarization, and structured execution at team scale.' },
  @{ Name='Video'; CardPath='category/video.html'; Keywords='video generation, editing, and short-form publishing'; Intro='video workflows'; Desc='Video AI platform for scripting, production, and efficient publishing across media channels.' },
  @{ Name='Voice'; CardPath='category/voice.html'; Keywords='voice generation, narration, and audio delivery'; Intro='voice workflows'; Desc='Voice AI tool for narration, synthetic speech, and multilingual audio content workflows.' },
  @{ Name='Platform'; CardPath='category/platform.html'; Keywords='model deployment, integrations, and production operations'; Intro='platform workflows'; Desc='AI platform layer designed for model operations, integrations, and production reliability.' },
  @{ Name='Automation'; CardPath='category/automation.html'; Keywords='automated processes, triggers, and cross-tool orchestration'; Intro='automation workflows'; Desc='Automation-first AI product that connects tools and executes repeatable business workflows.' },
  @{ Name='LLM'; CardPath='category/llm.html'; Keywords='language modeling, reasoning, and generation tasks'; Intro='LLM workflows'; Desc='LLM-oriented tool built for reasoning, structured generation, and scalable language operations.' },
  @{ Name='AI Search'; CardPath='category/ai-search.html'; Keywords='semantic retrieval, cited answers, and rapid research'; Intro='search workflows'; Desc='AI search tool for fast retrieval, summarized answers, and evidence-based research workflows.' },
  @{ Name='Infrastructure'; CardPath='category/infrastructure.html'; Keywords='GPU workloads, serving, and performance scaling'; Intro='infrastructure workflows'; Desc='Infrastructure AI service for scalable compute, model serving, and high-availability operations.' },
  @{ Name='Databases'; CardPath='category/databases.html'; Keywords='vector retrieval, embeddings, and AI data pipelines'; Intro='database workflows'; Desc='Database-layer AI tooling for vector search, retrieval quality, and operational query performance.' },
  @{ Name='MLOps'; CardPath='category/mlops.html'; Keywords='monitoring, experiments, and model lifecycle management'; Intro='MLOps workflows'; Desc='MLOps platform for experiment tracking, observability, and stable model lifecycle execution.' },
  @{ Name='Data Labeling'; CardPath='category/data-labeling.html'; Keywords='annotation quality, datasets, and training pipelines'; Intro='data labeling workflows'; Desc='Data labeling tool focused on dataset quality, annotation speed, and model training readiness.' },
  @{ Name='Evaluation'; CardPath='category/evaluation.html'; Keywords='benchmarking, quality checks, and model validation'; Intro='evaluation workflows'; Desc='Evaluation-focused AI toolkit for benchmarking, regression checks, and model quality assurance.' },
  @{ Name='Audio/Video'; CardPath='category/audio-video.html'; Keywords='audio cleanup, dubbing, and multi-format production'; Intro='audio/video workflows'; Desc='Audio and video AI toolkit for cross-format editing, enhancement, and content localization.' }
)

function Slugify([string]$text) {
  $slug = $text.ToLowerInvariant()
  $slug = $slug -replace '[^a-z0-9]+', '-'
  $slug = $slug.Trim('-')
  return $slug
}

function EscapeJs([string]$text) {
  return ($text -replace '\\', '\\\\' -replace "'", "\\'")
}

function BuildSeoExpansion([string]$toolName, [string]$categoryName, [string]$introSentence, [string]$toolPurpose) {
  return @"
<!-- SEO_EXPANDED_CONTENT_START -->
<h2>Purpose and Core Value of $toolName</h2>
<p>$toolName is built to help teams and individual creators execute $introSentence with more speed, more consistency, and fewer repeated manual steps. The practical purpose is not just to generate output quickly, but to make outcomes predictable and easier to improve over time. In most real workflows, tools become valuable when they reduce revision loops, shorten turnaround, and keep quality stable under pressure. That is the context in which $toolName is usually evaluated by serious users.</p>
<p>The platform is especially useful for people who need repeatable systems instead of one-off experimentation. Whether you are a solo operator, a freelancer, a startup team, or an internal operations lead, the bigger opportunity is building a process around the tool rather than relying on occasional prompts. If your objective is to save time while improving output quality, $toolName can serve as a workflow layer that supports planning, execution, and review.</p>

<h2>Who Should Use $toolName</h2>
<p>$toolName is typically a strong fit for users who value clarity, measurable output, and scalable execution. Beginners can use it to shorten learning curves and produce acceptable first drafts quickly. Intermediate users can turn it into a repeatable production system with templates and quality checkpoints. Advanced users can connect it with broader stacks and automate repetitive parts of delivery. The best fit appears when there is a clear business or productivity goal, a defined output format, and a willingness to monitor quality weekly.</p>

<h2>Key Advantages in Daily Workflow</h2>
<ul>
<li>Faster first-pass output with less setup friction.</li>
<li>More consistent quality when used with reusable templates.</li>
<li>Improved delivery speed for recurring client or internal tasks.</li>
<li>Cleaner handoff between strategy, production, and review phases.</li>
<li>Easier experimentation with measurable performance outcomes.</li>
</ul>

<h2>Pros and Cons of $toolName</h2>
<p><strong>Pros:</strong> strong speed-to-output performance, lower production overhead for repetitive tasks, and good leverage when paired with structured prompts and review checklists. <strong>Cons:</strong> output still requires human quality control, cost can increase with heavy usage, and performance varies by use case complexity. Like most AI systems, the highest ROI comes from disciplined implementation rather than casual usage.</p>

<h2>Step-by-Step Guide to Get Better Results</h2>
<ol>
<li>Define one high-frequency workflow where delay or inconsistency is currently expensive.</li>
<li>Create a template that includes objective, constraints, required format, and quality criteria.</li>
<li>Run five to ten real tasks through the same process and document output quality.</li>
<li>Track metrics such as turnaround time, revision count, and acceptance rate.</li>
<li>Refine your template weekly and store strong examples as reusable references.</li>
<li>Scale only after results are stable across different task inputs.</li>
</ol>

<h2>Frequently Asked Questions</h2>
<h3>1) Is $toolName good for beginners?</h3>
<p>Yes. Beginners can achieve useful results quickly if they define clear goals and use structured prompts instead of vague instructions.</p>
<h3>2) Can $toolName replace manual work completely?</h3>
<p>No. It can reduce manual effort significantly, but human review remains important for accuracy, context, and final quality control.</p>
<h3>3) How do I evaluate ROI from $toolName?</h3>
<p>Track delivery speed, correction rate, and consistency across recurring tasks. ROI improves when process discipline improves.</p>
<h3>4) What is the best way to start?</h3>
<p>Start with one narrow workflow, run it repeatedly for two weeks, and optimize based on measurable output quality instead of assumptions.</p>
<!-- SEO_EXPANDED_CONTENT_END -->
"@
}

function EnsureSeoContent([string]$filePath) {
  $raw = Get-Content -LiteralPath $filePath -Raw

  $nameMatch = [regex]::Match($raw, '<h1>\s*(?<n>[^<]+?)\s*</h1>', 'IgnoreCase')
  if (-not $nameMatch.Success) { return $false }
  $toolName = $nameMatch.Groups['n'].Value.Trim()

  $catMatch = [regex]::Match($raw, 'in the\s+(?<c>[^<]+?)\s+category', 'IgnoreCase')
  $categoryName = if ($catMatch.Success) { $catMatch.Groups['c'].Value.Trim() } else { 'AI' }

  $descMatch = [regex]::Match($raw, '<p>(?<d>[^<]{30,300})</p>', 'IgnoreCase')
  $purposeText = if ($descMatch.Success) { $descMatch.Groups['d'].Value.Trim() } else { "$toolName supports practical $categoryName tasks for modern teams." }

  $introSentence = "$categoryName tasks with measurable output quality"
  $seoBlock = BuildSeoExpansion -toolName $toolName -categoryName $categoryName -introSentence $introSentence -toolPurpose $purposeText

  $markerPattern = '(?s)<!-- SEO_EXPANDED_CONTENT_START -->.*?<!-- SEO_EXPANDED_CONTENT_END -->'
  if ([regex]::IsMatch($raw, $markerPattern)) {
    $updated = [regex]::Replace($raw, $markerPattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $seoBlock }, 1)
    if ($updated -ne $raw) {
      Set-Content -LiteralPath $filePath -Value $updated -Encoding UTF8
      return $true
    }
    return $false
  }

  $insertPattern = '<h2>Related Tools</h2>'
  if ([regex]::IsMatch($raw, $insertPattern, 'IgnoreCase')) {
    $insertRegex = New-Object System.Text.RegularExpressions.Regex($insertPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $updated = $insertRegex.Replace($raw, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $seoBlock + "`r`n`r`n" + $m.Value }, 1)
    Set-Content -LiteralPath $filePath -Value $updated -Encoding UTF8
    return $true
  }

  $jsonPattern = '<script type="application/ld\+json">'
  if ([regex]::IsMatch($raw, $jsonPattern, 'IgnoreCase')) {
    $jsonRegex = New-Object System.Text.RegularExpressions.Regex($jsonPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $updated = $jsonRegex.Replace($raw, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $seoBlock + "`r`n`r`n" + $m.Value }, 1)
    Set-Content -LiteralPath $filePath -Value $updated -Encoding UTF8
    return $true
  }

  return $false
}

$existingToolFiles = Get-ChildItem -Path $toolsDir -Filter *.html -File | Where-Object {
  $_.Name -notin @('index.html', 'example-ai-tool.html')
}

$existingSlugs = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
foreach ($f in $existingToolFiles) {
  [void]$existingSlugs.Add([System.IO.Path]::GetFileNameWithoutExtension($f.Name))
}

$prefixes = @('Adaptive','Apex','Astra','Atlas','Beacon','Bridge','Catalyst','Cobalt','Compass','Craft','Delta','Echo','Elevate','Envision','Falcon','Flux','Forge','Frame','Fusion','Helix','Horizon','Ignite','Insight','Jet','Kite','Lattice','Lumen','Matrix','Meridian','Momentum','Nebula','Nexus','Nova','Orbit','Origin','Pioneer','Pivot','Pulse','Quantum','Rally','Signal','Skyline','Spark','Stride','Summit','Synthesis','Titan','Vector','Vivid','Zenith')
$suffixes = @('AI','Flow','Studio','Labs','Pilot','Engine','Cloud','Works','Assist','Forge','Suite','Ops','Stack','Bridge','One','Core','Hub','Pulse','Sync','Agent')

$newRecords = New-Object System.Collections.Generic.List[object]
$target = [Math]::Max(1, $NewToolsCount)
$idx = 0
foreach ($p in $prefixes) {
  foreach ($s in $suffixes) {
    if ($newRecords.Count -ge $target) { break }

    $name = "$p $s"
    $slug = Slugify $name
    if ($existingSlugs.Contains($slug)) { continue }

    $cat = $categoryMap[$idx % $categoryMap.Count]
    $domain = ($name -replace '\s+', '').ToLowerInvariant() + '.ai'
    $desc = "$name is a $($cat.Name) tool focused on $($cat.Keywords)."

    $newRecords.Add([pscustomobject]@{
      Name = $name
      Slug = $slug
      Category = $cat.Name
      CategoryPath = $cat.CardPath
      Description = $desc
      Domain = $domain
    })

    [void]$existingSlugs.Add($slug)
    $idx += 1
  }
  if ($newRecords.Count -ge $target) { break }
}

if ($newRecords.Count -lt $target) {
  throw "Unable to generate $target unique tools. Generated $($newRecords.Count)."
}

$toolTemplate = Get-Content -LiteralPath (Join-Path $toolsDir 'chatgpt.html') -Raw

function BuildToolPage([pscustomobject]$rec) {
  $toolName = $rec.Name
  $slug = $rec.Slug
  $category = $rec.Category
  $description = $rec.Description
  $canonical = "https://lookforit.xyz/tools/$slug.html"
  $domain = $rec.Domain
  $seoBlock = BuildSeoExpansion -toolName $toolName -categoryName $category -introSentence "$category production workflows" -toolPurpose $description

  $head = @"
<!DOCTYPE HTML>
<html lang="en">
<head>
    <title>$toolName - Lookforit.xyz</title>
    <meta charset="utf-8" />
<link rel="icon" href="/favicon.svg" type="image/svg+xml" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<meta name="robots" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
<meta name="googlebot" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
<meta name="theme-color" content="#0f172a" />
<meta name="description" content="Discover $toolName with practical use cases, implementation guidance, pros and cons, and workflow-focused FAQs on Lookforit.xyz." />
<link rel="canonical" href="$canonical" />
<meta property="og:title" content="$toolName" />
<meta property="og:description" content="Discover $toolName with practical use cases, implementation guidance, pros and cons, and workflow-focused FAQs on Lookforit.xyz." />
<meta property="og:type" content="article" />
<meta property="og:url" content="$canonical" />
<meta property="og:site_name" content="Lookforit.xyz" />
<meta property="og:image" content="https://lookforit.xyz/Images/pic02.svg" />
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="$toolName" />
<meta name="twitter:description" content="Discover $toolName with practical use cases, implementation guidance, pros and cons, and workflow-focused FAQs on Lookforit.xyz." />
<meta name="twitter:image" content="https://lookforit.xyz/Images/pic02.svg" />
<meta name="twitter:image:alt" content="Lookforit featured visual" />
<link rel="stylesheet" href="../assets/css/main.css" />
</head>

<body class="is-preload">
<div id="wrapper">

<div id="main">
<div class="inner">

<header id="header">
<a href="/" class="logo"><strong>Lookforit</strong></a>
</header>

<section>
<header class="major">
<h1>$toolName</h1>
</header>
<p class="tool-hero-intro">$toolName stands out in the $category category when speed, output quality, and day-to-day usability matter most.</p>

<img class="tool-hero-img" width="96" height="96" src="https://www.google.com/s2/favicons?sz=128&domain=$domain" alt="$toolName logo" decoding="async" loading="lazy" />

<p>$description</p>

<p>
<a href="https://$domain" class="button primary" target="_blank" rel="noopener noreferrer">
Visit Tool
</a>
</p>

<h2>How to Use $toolName</h2>
<p>Start with one measurable workflow, define your expected output format, and apply a short review checklist before final publishing.</p>
<ol>
<li>Choose a high-frequency task where quality and speed both matter.</li>
<li>Set clear constraints and acceptance criteria before generating output.</li>
<li>Save winning templates and keep outputs versioned for comparison.</li>
<li>Track consistency, revision rate, and turnaround time every week.</li>
</ol>
<p><strong>Pro tip:</strong> Operational quality improves when prompts, review steps, and metrics are treated as one system.</p>

$seoBlock

<h2>Related Tools</h2>
<ul class="alt">
<li><a href="chatgpt.html">ChatGPT</a></li>
<li><a href="claude.html">Claude</a></li>
<li><a href="google-gemini.html">Google Gemini</a></li>
</ul>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "$toolName",
  "applicationCategory": "$category",
  "description": "$description",
  "url": "$canonical"
}
</script>
</section>

</div>
</div>
"@

  $sidebarStart = $toolTemplate.IndexOf('<div id="sidebar">')
  if ($sidebarStart -lt 0) {
    throw "Template missing sidebar block: tools/chatgpt.html"
  }

  $sidebarAndScripts = $toolTemplate.Substring($sidebarStart)
  return $head + "`r`n" + $sidebarAndScripts
}

$newPageCount = 0
foreach ($rec in $newRecords) {
  $page = BuildToolPage $rec
  $outPath = Join-Path $toolsDir ($rec.Slug + '.html')
  Set-Content -LiteralPath $outPath -Value $page -Encoding UTF8
  $newPageCount += 1
}

$indexRaw = Get-Content -LiteralPath $toolsIndexPath -Raw

$cardsBuilder = New-Object System.Text.StringBuilder
$cardImgOnError = "this.onerror=null;this.src='https://via.placeholder.com/128?text=AI';"
foreach ($rec in $newRecords) {
  [void]$cardsBuilder.AppendLine('      <article class="card" data-name="' + $rec.Name.ToLowerInvariant() + '" data-slug="' + $rec.Slug + '" data-category="' + $rec.Category + '">')
  [void]$cardsBuilder.AppendLine('        <div class="card-thumb">')
  [void]$cardsBuilder.AppendLine('          <img src="https://www.google.com/s2/favicons?sz=128&domain=' + $rec.Domain + '" alt="' + $rec.Name + '" onerror="' + $cardImgOnError + '" decoding="async" loading="lazy" />')
  [void]$cardsBuilder.AppendLine('        </div>')
  [void]$cardsBuilder.AppendLine('        <div class="card-body">')
  [void]$cardsBuilder.AppendLine('          <div class="category"><a href="' + $rec.CategoryPath + '">' + $rec.Category + '</a></div>')
  [void]$cardsBuilder.AppendLine('          <h2><a href="' + $rec.Slug + '.html">' + $rec.Name + '</a></h2>')
  [void]$cardsBuilder.AppendLine('          <p>' + $rec.Description + '</p>')
  [void]$cardsBuilder.AppendLine('          <div class="cta"><a href="' + $rec.Slug + '.html">View &rarr;</a></div>')
  [void]$cardsBuilder.AppendLine('        </div>')
  [void]$cardsBuilder.AppendLine('      </article>')
  [void]$cardsBuilder.AppendLine('')
}

$cardsToInsert = $cardsBuilder.ToString()

$gridClosePattern = '(?s)(<div class="posts tools-grid" id="grid">.*?)(\r?\n\s*</div>\s*\r?\n\s*</section>)'
if (-not [regex]::IsMatch($indexRaw, $gridClosePattern)) {
  throw 'Unable to locate tools grid close marker in tools/index.html'
}

$indexUpdated = [regex]::Replace(
  $indexRaw,
  $gridClosePattern,
  [System.Text.RegularExpressions.MatchEvaluator]{
    param($m)
    $prefix = $m.Groups[1].Value.TrimEnd()
    $suffix = $m.Groups[2].Value
    return $prefix + "`r`n`r`n" + $cardsToInsert + $suffix
  },
  1
)

Set-Content -LiteralPath $toolsIndexPath -Value $indexUpdated -Encoding UTF8

$toolsDataRaw = Get-Content -LiteralPath $toolsDataPath -Raw
if ($toolsDataRaw -notmatch '\];\s*$') {
  throw 'Unable to locate array closing in assets/js/tools-data.js'
}

$dataLines = New-Object System.Collections.Generic.List[string]
foreach ($rec in $newRecords) {
  $entry = "  {n:'" + (EscapeJs $rec.Name) + "',s:'" + (EscapeJs ($rec.Slug + '.html')) + "',c:'" + (EscapeJs $rec.Category) + "',d:'" + (EscapeJs $rec.Description) + "',k:'" + (EscapeJs $rec.Name.ToLowerInvariant()) + "'},"
  $dataLines.Add($entry)
}

$insertData = "`r`n" + ($dataLines -join "`r`n") + "`r`n"
$toolsDataUpdated = [regex]::Replace($toolsDataRaw, '\];\s*$', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $insertData + '];' }, 1)
Set-Content -LiteralPath $toolsDataPath -Value $toolsDataUpdated -Encoding UTF8

$expandedCount = 0
$allToolFiles = Get-ChildItem -Path $toolsDir -Filter *.html -File | Where-Object {
  $_.Name -notin @('index.html', 'example-ai-tool.html')
}

foreach ($file in $allToolFiles) {
  if (EnsureSeoContent $file.FullName) { $expandedCount += 1 }
}

if ($RebuildSitemap) {
  & (Join-Path $PSScriptRoot 'generate-sitemap.ps1')
}

Write-Output "NEW_TOOLS_CREATED=$newPageCount"
Write-Output "TOOLS_INDEX_UPDATED=1"
Write-Output "TOOLS_DATA_UPDATED=1"
Write-Output "TOOL_PAGES_EXPANDED=$expandedCount"

