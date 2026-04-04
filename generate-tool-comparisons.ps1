param(
  [int]$ComparisonPairsToCreate = 25
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$toolsDir = Join-Path $PSScriptRoot 'tools'
$compareDir = Join-Path $toolsDir 'comparison'

if (-not (Test-Path $toolsDir)) { throw "Missing tools directory" }
if (-not (Test-Path $compareDir)) { New-Item -ItemType Directory -Path $compareDir -Force | Out-Null }

$comparisonPairs = @(
  @{ t1 = 'ChatGPT'; f1 = 'chatgpt'; t2 = 'Claude'; f2 = 'claude'; cat = 'AI Assistant' },
  @{ t1 = 'ChatGPT'; f1 = 'chatgpt'; t2 = 'Gemini'; f2 = 'gemini'; cat = 'AI Assistant' },
  @{ t1 = 'Claude'; f1 = 'claude'; t2 = 'Gemini'; f2 = 'gemini'; cat = 'AI Assistant' },
  @{ t1 = 'ChatGPT'; f1 = 'chatgpt'; t2 = 'Perplexity'; f2 = 'perplexity'; cat = 'AI Search' },
  @{ t1 = 'Midjourney'; f1 = 'midjourney'; f2 = 'dall-e'; t2 = 'DALLE'; cat = 'Image Generation' },
  @{ t1 = 'Midjourney'; f1 = 'midjourney'; f2 = 'stable-diffusion'; t2 = 'StableDiffusion'; cat = 'Image Gen' },
  @{ t1 = 'RunwayML'; f1 = 'runway'; f2 = 'pika-labs'; t2 = 'Pika'; cat = 'Video' },
  @{ t1 = 'GitHubCopilot'; f1 = 'github-copilot'; f2 = 'codeium'; t2 = 'Codeium'; cat = 'DevTools' },
  @{ t1 = 'ElevenLabs'; f1 = 'elevenlabs'; f2 = 'murf-ai'; t2 = 'Murf'; cat = 'Voice' },
  @{ t1 = 'Synthesia'; f1 = 'synthesia'; f2 = 'heygen'; t2 = 'HeyGen'; cat = 'Video' },
  @{ t1 = 'Jasper'; f1 = 'jasper'; f2 = 'copy-ai'; t2 = 'CopyAI'; cat = 'Content' },
  @{ t1 = 'Grammarly'; f1 = 'grammarly'; f2 = 'quillbot'; t2 = 'QuillBot'; cat = 'Content' },
  @{ t1 = 'ClickUp'; f1 = 'clickup-ai'; f2 = 'notion-ai'; t2 = 'Notion'; cat = 'Productivity' },
  @{ t1 = 'Pinecone'; f1 = 'pinecone'; f2 = 'weaviate'; t2 = 'Weaviate'; cat = 'Databases' },
  @{ t1 = 'Chroma'; f1 = 'chroma'; f2 = 'qdrant'; t2 = 'Qdrant'; cat = 'VectorDB' }
)

function BuildComparisonPage([string]$t1, [string]$f1, [string]$t2, [string]$f2) {
  $title = "{0} vs {1} 2026: Comparison" -f $t1, $t2
  $slug = "{0}-vs-{1}" -f $f1, $f2
  $url1 = "../{0}.html" -f $f1
  $url2 = "../{0}.html" -f $f2
  
  $html = "<!DOCTYPE HTML>" + [Environment]::NewLine
  $html += "<html lang=`"en`">" + [Environment]::NewLine
  $html += "<head>" + [Environment]::NewLine
  $html += "<title>$title - Lookforit.xyz</title>" + [Environment]::NewLine
  $html += "<meta charset=`"utf-8`" />" + [Environment]::NewLine
  $html += "<link rel=`"icon`" href=`"/favicon.svg`" type=`"image/svg+xml`" />" + [Environment]::NewLine
  $html += "<meta name=`"viewport`" content=`"width=device-width, initial-scale=1`" />" + [Environment]::NewLine
  $html += "<meta name=`"robots`" content=`"index, follow`" />" + [Environment]::NewLine
  $html += "<meta name=`"description`" content=`"Compare $t1 vs $t2 with pricing, features, and recommendations.`" />" + [Environment]::NewLine
  $html += "<link rel=`"canonical`" href=`"https://lookforit.xyz/tools/comparison/$slug.html`" />" + [Environment]::NewLine
  $html += "<link rel=`"stylesheet`" href=`"../../assets/css/main.css`" />" + [Environment]::NewLine
  $html += "</head>" + [Environment]::NewLine
  $html += "<body class=`"is-preload`">" + [Environment]::NewLine
  $html += "<div id=`"wrapper`">" + [Environment]::NewLine
  $html += "<div id=`"main`">" + [Environment]::NewLine
  $html += "<div class=`"inner`">" + [Environment]::NewLine
  $html += "<header id=`"header`"><a href=`"/`" class=`"logo`"><strong>Lookforit</strong></a></header>" + [Environment]::NewLine
  $html += "<section>" + [Environment]::NewLine
  $html += "<header class=`"major`"><h1>$t1 vs $t2</h1></header>" + [Environment]::NewLine
  $html += "<p>Direct comparison to help you choose the best AI tool for your needs.</p>" + [Environment]::NewLine
  
  $html += "<h2>Quick Comparison</h2>" + [Environment]::NewLine
  $html += "<table>" + [Environment]::NewLine
  $html += "<thead><tr><th>Feature</th><th>$t1</th><th>$t2</th></tr></thead>" + [Environment]::NewLine
  $html += "<tbody>" + [Environment]::NewLine
  $html += "<tr><td>Best For</td><td>Speed and ease</td><td>Advanced features</td></tr>" + [Environment]::NewLine
  $html += "<tr><td>Free Tier</td><td>Yes</td><td>Yes</td></tr>" + [Environment]::NewLine
  $html += "<tr><td>Price Range</td><td>0-200/mo</td><td>0-200/mo</td></tr>" + [Environment]::NewLine
  $html += "<tr><td>Learning Curve</td><td>Easy</td><td>Moderate</td></tr>" + [Environment]::NewLine
  $html += "<tr><td>Integration Support</td><td>Excellent</td><td>Good</td></tr>" + [Environment]::NewLine
  $html += "</tbody></table>" + [Environment]::NewLine
  
  $html += "<h2>Detailed Comparison</h2>" + [Environment]::NewLine
  $html += "<h3>When to Choose $t1</h3>" + [Environment]::NewLine
  $html += "<ul>" + [Environment]::NewLine
  $html += "<li>You value speed and simplicity</li>" + [Environment]::NewLine
  $html += "<li>You need quick results on high volume</li>" + [Environment]::NewLine
  $html += "<li>You want strong tool integrations</li>" + [Environment]::NewLine
  $html += "<li>You are new to AI tools</li>" + [Environment]::NewLine
  $html += "</ul>" + [Environment]::NewLine
  
  $html += "<h3>When to Choose $t2</h3>" + [Environment]::NewLine
  $html += "<ul>" + [Environment]::NewLine
  $html += "<li>You need advanced features</li>" + [Environment]::NewLine
  $html += "<li>You want customization and control</li>" + [Environment]::NewLine
  $html += "<li>You have complex workflows</li>" + [Environment]::NewLine
  $html += "<li>You prioritize depth over speed</li>" + [Environment]::NewLine
  $html += "</ul>" + [Environment]::NewLine
  
  $html += "<h2>Pricing and ROI</h2>" + [Environment]::NewLine
  $html += "<p>Both tools offer generous free tiers for testing. For production use, budget 20-50 USD per month for your chosen platform.</p>" + [Environment]::NewLine
  
  $html += "<h2>Migration Guide</h2>" + [Environment]::NewLine
  $html += "<p>Switching between tools is straightforward since both support similar workflows:</p>" + [Environment]::NewLine
  $html += "<ol>" + [Environment]::NewLine
  $html += "<li>Export your best prompts and workflows</li>" + [Environment]::NewLine
  $html += "<li>Test them on the new tool</li>" + [Environment]::NewLine
  $html += "<li>Run both side-by-side for 1-2 weeks</li>" + [Environment]::NewLine
  $html += "<li>Choose based on actual results, not hype</li>" + [Environment]::NewLine
  $html += "</ol>" + [Environment]::NewLine
  
  $html += "<h2>See Also</h2>" + [Environment]::NewLine
  $html += "<ul class=`"alt`">" + [Environment]::NewLine
  $html += "<li><a href=`"$url1`">$t1 Review</a></li>" + [Environment]::NewLine
  $html += "<li><a href=`"$url2`">$t2 Review</a></li>" + [Environment]::NewLine
  $html += "<li><a href=`"../index.html`">All Tools</a></li>" + [Environment]::NewLine
  $html += "</ul>" + [Environment]::NewLine
  
  $html += "</section>" + [Environment]::NewLine
  $html += "</div></div></div>" + [Environment]::NewLine
  $html += "</body></html>" + [Environment]::NewLine
  
  return @{ html = $html; filename = "$slug.html" }
}

Write-Host "Generating Comparison Pages for AI Tools" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

$created = 0
for ($i = 0; $i -lt [Math]::Min($ComparisonPairsToCreate, $comparisonPairs.Count); $i++) {
  $pair = $comparisonPairs[$i]
  $f1 = Join-Path $toolsDir "$($pair.f1).html"
  $f2 = Join-Path $toolsDir "$($pair.f2).html"
  
  if ((Test-Path $f1) -and (Test-Path $f2)) {
    $result = BuildComparisonPage $pair.t1 $pair.f1 $pair.t2 $pair.f2
    $fp = Join-Path $compareDir $result.filename
    
    Set-Content -LiteralPath $fp -Value $result.html -Encoding UTF8
    $created++
    
    Write-Host "✓ Created: $($result.filename)"
  }
}

Write-Host "================================" -ForegroundColor Cyan
Write-Host "✓ Created $created comparison pages" -ForegroundColor Green
