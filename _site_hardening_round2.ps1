$ErrorActionPreference = 'Stop'
$root = 'c:\Users\syeds\lookforit'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$allHtml = Get-ChildItem $root -Recurse -Filter '*.html' | Where-Object { $_.FullName -notmatch '\\.git\\' }

$iconsBlock = @"
<ul class="icons">
<li><a href="https://x.com/syedShahid1433" class="icon brands fa-twitter" target="_blank" rel="noopener noreferrer"><span class="label">Twitter</span></a></li>
<li><a href="https://www.facebook.com/syed.shahed.273196" class="icon brands fa-facebook-f" target="_blank" rel="noopener noreferrer"><span class="label">Facebook</span></a></li>
<li><a href="https://www.youtube.com/@Ampersent" class="icon brands fa-youtube" target="_blank" rel="noopener noreferrer"><span class="label">YouTube</span></a></li>
<li><a href="https://www.instagram.com/shah.voidheart/" class="icon brands fa-instagram" target="_blank" rel="noopener noreferrer"><span class="label">Instagram</span></a></li>
<li><a href="https://medium.com/@syedsinterprises" class="icon brands fa-medium-m" target="_blank" rel="noopener noreferrer"><span class="label">Medium</span></a></li>
<li><a href="https://chat.whatsapp.com/J6EsOm6PFqgBZm2nkNy3w3" class="icon brands fa-whatsapp" target="_blank" rel="noopener noreferrer"><span class="label">Community</span></a></li>
</ul>
"@

$updated = 0
$robotsAdded = 0
$themeAdded = 0
$iconSectionsReplaced = 0

foreach ($file in $allHtml) {
  $c = [System.IO.File]::ReadAllText($file.FullName)
  $orig = $c

  if ($c -match '<ul class="icons">') {
    $before = $c
    $c = [regex]::Replace($c, '(?s)<ul class="icons">.*?</ul>', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $iconsBlock }, 1)
    if ($c -ne $before) { $iconSectionsReplaced++ }
  }

  $c = $c.Replace('href="#" class="icon brands fa-twitter"', 'href="https://x.com/syedShahid1433" class="icon brands fa-twitter" target="_blank" rel="noopener noreferrer"')
  $c = $c.Replace('href="#" class="icon brands fa-facebook-f"', 'href="https://www.facebook.com/syed.shahed.273196" class="icon brands fa-facebook-f" target="_blank" rel="noopener noreferrer"')
  $c = $c.Replace('href="#" class="icon brands fa-youtube"', 'href="https://www.youtube.com/@Ampersent" class="icon brands fa-youtube" target="_blank" rel="noopener noreferrer"')
  $c = $c.Replace('href="#" class="icon brands fa-instagram"', 'href="https://www.instagram.com/shah.voidheart/" class="icon brands fa-instagram" target="_blank" rel="noopener noreferrer"')
  $c = $c.Replace('href="#" class="icon brands fa-medium-m"', 'href="https://medium.com/@syedsinterprises" class="icon brands fa-medium-m" target="_blank" rel="noopener noreferrer"')

  if ($c -notmatch '<meta name="robots"') {
    if ($c -match '<meta name="viewport"[^>]*>') {
      $c = [regex]::Replace($c, '(<meta name="viewport"[^>]*>\s*)', '$1<meta name="robots" content="index, follow" />' + [Environment]::NewLine, 1)
      $robotsAdded++
    }
  }

  if ($c -notmatch '<meta name="theme-color"') {
    if ($c -match '<meta name="robots"[^>]*>') {
      $c = [regex]::Replace($c, '(<meta name="robots"[^>]*>\s*)', '$1<meta name="theme-color" content="#0f172a" />' + [Environment]::NewLine, 1)
      $themeAdded++
    } elseif ($c -match '<meta name="viewport"[^>]*>') {
      $c = [regex]::Replace($c, '(<meta name="viewport"[^>]*>\s*)', '$1<meta name="theme-color" content="#0f172a" />' + [Environment]::NewLine, 1)
      $themeAdded++
    }
  }

  if ($c -ne $orig) {
    [System.IO.File]::WriteAllText($file.FullName, $c, $utf8NoBom)
    $updated++
  }
}

Write-Host ('Files updated: {0}' -f $updated)
Write-Host ('Icon sections replaced: {0}' -f $iconSectionsReplaced)
Write-Host ('Robots tags added: {0}' -f $robotsAdded)
Write-Host ('Theme-color tags added: {0}' -f $themeAdded)
