$ErrorActionPreference = "Stop"

$root = (Get-Location).Path
$issues = New-Object System.Collections.Generic.List[string]

function Add-Issue {
    param([string]$Message)
    [void]$issues.Add($Message)
}

function Get-ResolvedTarget {
    param(
        [string]$BaseDir,
        [string]$Url
    )

    $clean = $Url.Split("?")[0].Split("#")[0]
    if ([string]::IsNullOrWhiteSpace($clean)) { return $null }

    $decoded = [System.Uri]::UnescapeDataString($clean)
    if ($decoded.StartsWith("/")) {
        return Join-Path $root $decoded.TrimStart('/')
    }

    return Join-Path $BaseDir $decoded
}

$htmlFiles = Get-ChildItem -Path $root -Recurse -File -Include *.html

foreach ($file in $htmlFiles) {
    $relative = $file.FullName.Substring($root.Length + 1)
    $raw = Get-Content -LiteralPath $file.FullName -Raw

    if ($raw -notmatch '<meta\s+name="description"') {
        Add-Issue("missing description: $relative")
    }

    if ($raw -notmatch '<link\s+rel="canonical"') {
        Add-Issue("missing canonical: $relative")
    }

    if ($raw -notmatch '<meta\s+property="og:title"') {
        Add-Issue("missing og:title: $relative")
    }

    if ($raw -notmatch '<meta\s+name="twitter:title"') {
        Add-Issue("missing twitter:title: $relative")
    }

    $linkRefs = [regex]::Matches($raw, '(?:href|src)="([^"]+)"', 'IgnoreCase')
    foreach ($m in $linkRefs) {
        $url = $m.Groups[1].Value.Trim()
        if ($url -match '^(https?:|mailto:|tel:|#|javascript:)') { continue }

        $target = Get-ResolvedTarget -BaseDir $file.DirectoryName -Url $url
        if ($null -eq $target) { continue }

        if (-not (Test-Path -LiteralPath $target)) {
            Add-Issue("broken internal ref in $relative => $url")
        }
    }
}

foreach ($file in $htmlFiles) {
    $relative = $file.FullName.Substring($root.Length + 1)
    $raw = Get-Content -LiteralPath $file.FullName -Raw
    if ($raw.Contains([string][char]0x00C3) -or $raw.Contains([string][char]0x00E2)) {
        Add-Issue("encoding artifact in $relative")
    }
}

if ($issues.Count -gt 0) {
    Write-Output "SITE_QUALITY_FAILED=$($issues.Count)"
    $issues | ForEach-Object { Write-Output $_ }
    exit 1
}

Write-Output "SITE_QUALITY_OK=1"
exit 0
