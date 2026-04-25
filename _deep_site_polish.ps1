$ErrorActionPreference = 'Stop'
$root = 'c:\Users\syeds\lookforit'
$toolsDir = Join-Path $root 'tools'
$today = '2026-03-14'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Get-RelativePath([string]$fullPath) {
  return ($fullPath.Substring($root.Length).TrimStart('\\') -replace '\\','/')
}

function Get-AbsoluteUrl([string]$fullPath) {
  return 'https://lookforit.xyz/' + (Get-RelativePath $fullPath)
}

function Read-Meta([string]$content, [string]$pattern, [string]$fallback) {
  if ($content -match $pattern) { return $matches[1].Trim() }
  return $fallback
}

function Build-BreadcrumbJson([string]$rel,[string]$name) {
  $items = @()
  $items += [ordered]@{ '@type'='ListItem'; position=1; name='Home'; item='https://lookforit.xyz/index.html' }

  if ($rel -like 'articles/*' -and $rel -ne 'articles/index.html') {
    $items += [ordered]@{ '@type'='ListItem'; position=2; name='Articles'; item='https://lookforit.xyz/articles/index.html' }
    $items += [ordered]@{ '@type'='ListItem'; position=3; name=$name; item=('https://lookforit.xyz/' + $rel) }
  } elseif ($rel -eq 'articles/index.html') {
    $items += [ordered]@{ '@type'='ListItem'; position=2; name='Articles'; item='https://lookforit.xyz/articles/index.html' }
  } elseif ($rel -ne 'index.html') {
    $items += [ordered]@{ '@type'='ListItem'; position=2; name=$name; item=('https://lookforit.xyz/' + $rel) }
  }

  $obj = [ordered]@{ '@context'='https://schema.org'; '@type'='BreadcrumbList'; itemListElement=$items }
  return ($obj | ConvertTo-Json -Depth 8)
}

function Build-ArticleJson([string]$url,[string]$headline,[string]$description) {
  $obj = [ordered]@{
    '@context'='https://schema.org'
    '@type'='Article'
    headline=$headline
    description=$description
    dateModified=$today
    author=[ordered]@{ '@type'='Person'; name='Shahid' }
    publisher=[ordered]@{
      '@type'='Organization'; name='Lookforit.xyz'; url='https://lookforit.xyz';
      logo=[ordered]@{ '@type'='ImageObject'; url='https://lookforit.xyz/Images/ai-tools-2026.jpg' }
    }
    mainEntityOfPage=$url
  }
  return ($obj | ConvertTo-Json -Depth 8)
}

# ---------- 1) Unique hero intro on all 100 tool pages ----------
$toolPages = Get-ChildItem $toolsDir -Filter '*.html' | Where-Object { $_.Name -notin @('index.html','example-ai-tool.html') } | Sort-Object Name
$introTemplates = @(
  'If you need {0} outcomes in real workflows, {1} is one of the most practical {2} tools to evaluate right now.',
  '{1} stands out in the {2} category when speed, output quality, and day-to-day usability matter most.',
  'For teams and solo creators who want reliable {0} results, {1} is a strong option in today''s {2} landscape.',
  '{1} can reduce trial-and-error time by giving you a focused path from prompt to production-ready {0}.',
  'Among modern {2} tools, {1} is especially useful when you need fast execution without sacrificing output quality.'
)

foreach ($file in $toolPages) {
  $c = [System.IO.File]::ReadAllText($file.FullName)
  $name = Read-Meta $c '<h1>([^<]+)</h1>' $file.BaseName
  $desc = Read-Meta $c '<meta name="description" content="([^"]*)"' ($name + ' is an AI tool on Lookforit.xyz.')
  $cat  = Read-Meta $c '"applicationCategory"\s*:\s*"([^"]+)"' 'AI Tool'

  $focus = 'higher quality'
  if ($desc -match 'coding|developer|code') { $focus = 'coding and shipping' }
  elseif ($desc -match 'image|visual|design') { $focus = 'visual content' }
  elseif ($desc -match 'video') { $focus = 'video content' }
  elseif ($desc -match 'voice|audio|speech') { $focus = 'voice and audio' }
  elseif ($desc -match 'productivity|notes|task|meeting') { $focus = 'productivity' }
  elseif ($desc -match 'search|research') { $focus = 'research and search' }

  $i = [Math]::Abs($file.BaseName.GetHashCode()) % $introTemplates.Count
  $intro = [string]::Format($introTemplates[$i], $focus, $name, $cat)

  $c = [regex]::Replace($c, '(?s)\s*<p class="tool-hero-intro">.*?</p>\s*', "`r`n")
  $introBlock = "`r`n<p class=""tool-hero-intro"">$intro</p>`r`n"
  $c = [regex]::Replace($c, '(<h1>[^<]+</h1>\s*</header>)', '$1' + $introBlock, 1)

  [System.IO.File]::WriteAllText($file.FullName, $c, $utf8NoBom)
}

# ---------- 2) Breadcrumb schema + article schema on all non-tool pages ----------
$nonToolPages = Get-ChildItem $root -Recurse -Filter '*.html' | Where-Object { $_.FullName -notmatch '\\tools\\' -and $_.Name -ne 'example-ai-tool.html' }

foreach ($file in $nonToolPages) {
  $c = [System.IO.File]::ReadAllText($file.FullName)
  $rel = Get-RelativePath $file.FullName
  $url = Get-AbsoluteUrl $file.FullName

  $headline = Read-Meta $c '<h1>([^<]+)</h1>' (Read-Meta $c '<title>([^<]+)</title>' $file.BaseName)
  $desc = Read-Meta $c '<meta name="description" content="([^"]*)"' ($headline + ' - Lookforit.xyz')

  $c = [regex]::Replace($c, '(?s)\s*<script type="application/ld\+json" data-ai="breadcrumb">.*?</script>\s*', "`r`n")
  $c = [regex]::Replace($c, '(?s)\s*<script type="application/ld\+json" data-ai="article">.*?</script>\s*', "`r`n")

  $breadcrumbJson = Build-BreadcrumbJson $rel $headline
  $articleJson = Build-ArticleJson $url $headline $desc

  $schemaBlock = @"
<script type="application/ld+json" data-ai="breadcrumb">
$breadcrumbJson
</script>
<script type="application/ld+json" data-ai="article">
$articleJson
</script>
"@

  if ($c -match '</head>') { $c = $c.Replace('</head>', "`r`n$schemaBlock`r`n</head>") }

  [System.IO.File]::WriteAllText($file.FullName, $c, $utf8NoBom)
}

# ---------- 3) Link integrity audit + safe auto-fix ----------
$allHtml = Get-ChildItem $root -Recurse -Filter '*.html' | Where-Object { $_.FullName -notmatch '\\.git\\' }
$internalChecked = 0
$internalFixed = 0
$brokenInternal = @()
$externalUrls = New-Object System.Collections.Generic.HashSet[string]

foreach ($file in $allHtml) {
  $c = [System.IO.File]::ReadAllText($file.FullName)
  $dir = Split-Path $file.FullName -Parent

  $refs = [regex]::Matches($c, '(href|src)="([^"]+)"')
  foreach ($r in $refs) {
    $attr = $r.Groups[1].Value
    $raw = $r.Groups[2].Value
    if ([string]::IsNullOrWhiteSpace($raw)) { continue }
    if ($raw.StartsWith('#') -or $raw.StartsWith('mailto:') -or $raw.StartsWith('tel:') -or $raw.StartsWith('javascript:')) { continue }

    if ($raw -match '^https?://') {
      [void]$externalUrls.Add($raw)
      continue
    }

    $internalChecked++
    $pathPart = $raw.Split('?')[0].Split('#')[0]
    $resolved = [System.IO.Path]::GetFullPath((Join-Path $dir ($pathPart -replace '/', '\\')))

    if (-not (Test-Path $resolved)) {
      $fixed = $null
      if ($pathPart.EndsWith('/')) {
        $try = [System.IO.Path]::GetFullPath((Join-Path $dir (($pathPart + 'index.html') -replace '/', '\\')))
        if (Test-Path $try) { $fixed = $raw.TrimEnd('/') + '/index.html' }
      } elseif ([System.IO.Path]::GetExtension($pathPart) -eq '') {
        $tryHtml = [System.IO.Path]::GetFullPath((Join-Path $dir (($pathPart + '.html') -replace '/', '\\')))
        $tryIndex = [System.IO.Path]::GetFullPath((Join-Path $dir (($pathPart + '/index.html') -replace '/', '\\')))
        if (Test-Path $tryHtml) { $fixed = $raw + '.html' }
        elseif (Test-Path $tryIndex) { $fixed = $raw.TrimEnd('/') + '/index.html' }
      }

      if ($fixed) {
        $from = ('{0}="{1}"' -f $attr, $raw)
        $to = ('{0}="{1}"' -f $attr, $fixed)
        $c = $c.Replace($from, $to)
        $internalFixed++
      } else {
        $brokenInternal += [PSCustomObject]@{ File=$file.FullName; Url=$raw }
      }
    }
  }

  $c = $c.Replace('target="_blank" rel="noopener noreferrer"','target="_blank" rel="noopener noreferrer"')
  [System.IO.File]::WriteAllText($file.FullName, $c, $utf8NoBom)
}

$badExternal = @()
$httpToHttpsFixes = 0
foreach ($u in $externalUrls) {
  try {
    $resp = Invoke-WebRequest -Uri $u -Method Head -UseBasicParsing -MaximumRedirection 5 -TimeoutSec 8 -ErrorAction Stop
    if ($resp.StatusCode -ge 400) {
      $badExternal += [PSCustomObject]@{ Url=$u; Status=$resp.StatusCode }
    }
  } catch {
    if ($u.StartsWith('http://')) {
      $https = 'https://' + $u.Substring(7)
      try {
        $resp2 = Invoke-WebRequest -Uri $https -Method Head -UseBasicParsing -MaximumRedirection 5 -TimeoutSec 8 -ErrorAction Stop
        if ($resp2.StatusCode -lt 400) {
          foreach ($f in $allHtml) {
            $txt = [System.IO.File]::ReadAllText($f.FullName)
            if ($txt.Contains($u)) {
              $txt = $txt.Replace($u, $https)
              [System.IO.File]::WriteAllText($f.FullName, $txt, $utf8NoBom)
              $httpToHttpsFixes++
            }
          }
        } else {
          $badExternal += [PSCustomObject]@{ Url=$u; Status=$resp2.StatusCode }
        }
      } catch {
        $badExternal += [PSCustomObject]@{ Url=$u; Status='unreachable' }
      }
    } else {
      $badExternal += [PSCustomObject]@{ Url=$u; Status='unreachable' }
    }
  }
}

$report = @()
$report += ('Tool pages updated with unique hero intro: {0}' -f $toolPages.Count)
$report += ('Non-tool pages updated with breadcrumb + article schema: {0}' -f $nonToolPages.Count)
$report += ('Internal links checked: {0}' -f $internalChecked)
$report += ('Internal links auto-fixed: {0}' -f $internalFixed)
$report += ('External URLs checked: {0}' -f $externalUrls.Count)
$report += ('HTTP->HTTPS external fixes: {0}' -f $httpToHttpsFixes)
$report += ('Potentially broken internal links: {0}' -f $brokenInternal.Count)
$report += ('Potentially broken external URLs: {0}' -f $badExternal.Count)

[System.IO.File]::WriteAllLines((Join-Path $root 'link-audit-report.txt'), $report, $utf8NoBom)

Write-Host 'Deep site polish completed.'
Write-Host ($report -join "`n")
