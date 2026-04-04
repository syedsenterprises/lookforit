param(
  [bool]$ShowProgress = $true,
  [bool]$RebuildSitemap = $true
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$toolsDir = Join-Path $PSScriptRoot 'tools'

# Define tool categories and relationships
$toolCategories = @{
  'AI Assistant' = @('chatgpt', 'claude', 'copilot-assistant', 'cohere')
  'Chatbot' = @('chatgpt', 'character-ai', 'poe')
  'Developer Tools' = @('github-copilot', 'codeium', 'tabnine', 'cursor', 'windsurf', 'replit-ghostwriter', 'blackbox-ai')
  'Image Generation' = @('midjourney', 'dall-e', 'stable-diffusion', 'leonardo-ai', 'remove-bg')
  'Image Editing' = @('remove-bg', 'cleanup-pictures')
  'Voice' = @('elevenlabs', 'murf-ai', 'udio', 'suno', 'speechify')
  'Video' = @('runway', 'pika-labs', 'synthesia', 'heygen', 'capcut-ai', 'veed-ai', 'invideo-ai')
  'Content' = @('jasper', 'copy-ai', 'writesonic', 'wordtune', 'grammarly', 'quillbot', 'writer')
  'Productivity' = @('notion-ai', 'clickup-ai', 'coda-ai', 'mem-ai', 'rewind-ai')
  'Search' = @('perplexity', 'you-com', 'phind')
  'Design' = @('canva-ai', 'figma-ai', 'framer-ai', 'gamma', 'tom-e')
  'Video-Gen' = @('synthesia', 'runway', 'pika-labs', 'heygen')
  'Automation' = @('zapier-ai', 'make-com')
  'Platform' = @('langchain', 'langsmith', 'promptlayer', 'anthropic-api', 'openai-api')
  'LLM' = @('mistral-ai', 'gpt-neox', 'llama-3', 'cohere')
  'Infrastructure' = @('runpod', 'modal', 'octoai', 'together-ai', 'vertex-ai')
  'Databases' = @('pinecone', 'weaviate', 'chroma', 'qdrant', 'milvus', 'supabase-vector', 'zilliz')
  'MLOps' = @('weights-and-biases', 'neptune-ai', 'comet-ml', 'helm')
}

# Define complementary tool relationships
$complements = @{
  'chatgpt' = @('zapier-ai', 'make-com', 'langchain')
  'claude' = @('zapier-ai', 'make-com', 'langchain')
  'github-copilot' = @('cursor', 'replit-ghostwriter')
  'midjourney' = @('figma-ai', 'canva-ai')
  'dall-e' = @('canva-ai', 'figma-ai')
  'runway' = @('synthesia', 'capcut-ai')
  'pinecone' = @('langchain', 'cohere')
}

# Define competing alternatives
$alternatives = @{
  'chatgpt' = @('claude', 'gemini', 'perplexity', 'grok')
  'claude' = @('chatgpt', 'gemini')
  'midjourney' = @('dall-e', 'stable-diffusion', 'leonardo-ai')
  'dall-e' = @('midjourney', 'stable-diffusion')
  'github-copilot' = @('codeium', 'tabnine')
  'runway' = @('synthesia', 'pika-labs')
}

function ExtractToolSlug([string]$filename) {
  return [System.IO.Path]::GetFileNameWithoutExtension($filename).ToLower()
}

function GetRelatedToolsForSlug([string]$slug, [hashtable]$categories, [hashtable]$complements, [hashtable]$alternatives) {
  $related = [System.Collections.Generic.HashSet[string]]::new()
  
  # Find tools in the same category
  foreach ($category in $categories.Values) {
    if ($category -contains $slug) {
      foreach ($tool in $category) {
        if ($tool -ne $slug) {
          [void]$related.Add($tool)
        }
      }
      break
    }
  }
  
  # Add complementary tools
  if ($complements.ContainsKey($slug)) {
    foreach ($tool in $complements[$slug]) {
      [void]$related.Add($tool)
    }
  }
  
  # Add alternative tools
  if ($alternatives.ContainsKey($slug)) {
    foreach ($tool in $alternatives[$slug]) {
      [void]$related.Add($tool)
    }
  }
  
  # Return top 8 related tools
  return $related | Select-Object -First 8 | Sort-Object
}

function NormalizeToolName([string]$slug) {
  # Convert slug to readable name
  $name = $slug -replace '-', ' '
  $name = (Get-Culture).TextInfo.ToTitleCase($name)
  return $name
}

function BuildEnhancedRelatedToolsSection([string]$slug, [hashtable]$categories, [hashtable]$complements, [hashtable]$alternatives) {
  $relatedTools = GetRelatedToolsForSlug $slug $categories $complements $alternatives
  
  if ($relatedTools.Count -eq 0) {
    return ""
  }
  
  $html = "<h2>Related Tools & Alternatives</h2>`r`n"
  $html += "<p>Explore other tools in the same category and complementary platforms:</p>`r`n"
  $html += "<ul class=`"alt`">`r`n"
  
  foreach ($tool in $relatedTools) {
    if (Test-Path (Join-Path $toolsDir "$tool.html")) {
      $toolName = NormalizeToolName $tool
      $html += "<li><a href=`"$tool.html`">$toolName</a></li>`r`n"
    }
  }
  
  $html += "</ul>`r`n"
  
  return $html
}

function EnhanceInternalLinkingInPage([string]$filePath, [string]$slug, [hashtable]$categories, [hashtable]$complements, [hashtable]$alternatives) {
  $raw = Get-Content -LiteralPath $filePath -Raw -Encoding UTF8
  
  # Check if already enhanced
  if ($raw -match '<!-- INTERNAL_LINKING_ENHANCED -->') {
    return @{ Success = $true; Changed = $false }
  }
  
  $relatedSection = BuildEnhancedRelatedToolsSection $slug $categories $complements $alternatives
  
  if ([string]::IsNullOrEmpty($relatedSection)) {
    return @{ Success = $true; Changed = $false }
  }
  
  # Try to replace existing "Related Tools" section
  $existingRelated = '<h2>Related Tools</h2>\s*<ul[^>]*>\s*(?:<li>.*?</li>\s*)*</ul>'
  if ([regex]::IsMatch($raw, $existingRelated, 'IgnoreCase')) {
    $newRelated = $relatedSection + "`r`n<!-- INTERNAL_LINKING_ENHANCED -->"
    $updated = [regex]::Replace($raw, $existingRelated, $newRelated, 1)
  } else {
    # Insert before JSON-LD schema
    $insertMarker = '<script type="application/ld\+json">'
    if ([regex]::IsMatch($raw, $insertMarker, 'IgnoreCase')) {
      $newContent = $relatedSection + "`r`n<!-- INTERNAL_LINKING_ENHANCED -->`r`n`r`n"
      $updated = [regex]::Replace($raw, $insertMarker, $newContent + $insertMarker, 1)
    } else {
      return @{ Success = $true; Changed = $false }
    }
  }
  
  if ($updated -ne $raw) {
    Set-Content -LiteralPath $filePath -Value $updated -Encoding UTF8 -Force
    return @{ Success = $true; Changed = $true }
  }
  
  return @{ Success = $true; Changed = $false }
}

# Main execution
Write-Host "Enhancing internal linking strategy across all tool pages..." -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

$toolFiles = Get-ChildItem -Path $toolsDir -Filter *.html -File | Where-Object {
  $_.Name -notin @('index.html', 'example-ai-tool.html') -and $_.DirectoryName -eq $toolsDir
}

$totalCount = $toolFiles.Count
$processedCount = 0
$enhancedCount = 0

foreach ($toolFile in $toolFiles) {
  $processedCount++
  $slug = ExtractToolSlug $toolFile.Name
  
  if ($ShowProgress -and $processedCount % 50 -eq 0) {
    $progress = [int](($processedCount / $totalCount) * 100)
    Write-Host "[$progress%] Processing $($toolFile.Name)..." -ForegroundColor Cyan
  }
  
  $result = EnhanceInternalLinkingInPage $toolFile.FullName $slug $toolCategories $complements $alternatives
  
  if ($result.Success -and $result.Changed) {
    $enhancedCount++
  }
}

Write-Host "================================" -ForegroundColor Cyan
Write-Host "✓ Enhanced internal linking for $enhancedCount of $totalCount tool pages" -ForegroundColor Green
Write-Host "✓ Added strategic cross-linking to related, complementary, and alternative tools" -ForegroundColor Green
Write-Host "✓ Improved site-wide link juice distribution and user navigation" -ForegroundColor Green

# Rebuild sitemap and audit
if ($RebuildSitemap) {
  Write-Host "`r`nRebuilding sitemap..."
  & "$PSScriptRoot\generate-sitemap.ps1" -ErrorAction Continue | Out-Null
  & "$PSScriptRoot\qa-site.ps1" -ErrorAction Continue | Out-Null
}

Write-Host "`r`n✓ Internal linking enhancement complete!" -ForegroundColor Green
