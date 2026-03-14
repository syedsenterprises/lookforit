param(
    [Parameter(Mandatory = $true)]
    [string]$Title,

    [Parameter(Mandatory = $true)]
    [string]$Slug,

    [Parameter(Mandatory = $true)]
    [string]$Description,

    [Parameter(Mandatory = $true)]
    [string]$BodyFile,

    [string]$ImagePath = "../Images/pic07.svg",
    [string]$ImageAlt = "Article cover image",
    [string]$PublishedText = "Published March 2026",
    [string]$DateModified = (Get-Date -Format "yyyy-MM-dd"),
    [bool]$UpdateIndex = $true
)

$ErrorActionPreference = "Stop"

function Escape-Html {
    param([string]$Text)
    if ($null -eq $Text) { return "" }
    return [System.Net.WebUtility]::HtmlEncode($Text)
}

function Escape-JsonString {
    param([string]$Text)
    if ($null -eq $Text) { return "" }

    return ($Text -replace '\\', '\\\\' -replace '"', '\\"' -replace "`r", "" -replace "`n", "\\n")
}

function Convert-InlineMarkdown {
    param([string]$Text)

    $escaped = Escape-Html $Text
    $converted = [regex]::Replace(
        $escaped,
        "\[([^\]]+)\]\(([^\)]+)\)",
        {
            param($m)
            $label = $m.Groups[1].Value
            $url = $m.Groups[2].Value
            return ('<a href="{0}">{1}</a>' -f $url, $label)
        }
    )

    return $converted
}

function Convert-BodyToHtml {
    param([string]$RawText)

    $lines = $RawText -split "`r?`n"
    $html = New-Object System.Collections.Generic.List[string]

    $paragraphBuffer = New-Object System.Collections.Generic.List[string]
    $listBuffer = New-Object System.Collections.Generic.List[string]

    function Flush-Paragraph {
        if ($paragraphBuffer.Count -gt 0) {
            $joined = ($paragraphBuffer -join " ").Trim()
            if ($joined.Length -gt 0) {
                $html.Add("<p>$(Convert-InlineMarkdown $joined)</p>")
            }
            $paragraphBuffer.Clear()
        }
    }

    function Flush-List {
        if ($listBuffer.Count -gt 0) {
            $html.Add("<ul>")
            foreach ($item in $listBuffer) {
                $html.Add("<li>$(Convert-InlineMarkdown $item)</li>")
            }
            $html.Add("</ul>")
            $listBuffer.Clear()
        }
    }

    foreach ($line in $lines) {
        $trimmed = $line.Trim()

        if ($trimmed -eq "") {
            Flush-Paragraph
            Flush-List
            continue
        }

        if ($trimmed.StartsWith("### ")) {
            Flush-Paragraph
            Flush-List
            $h = $trimmed.Substring(4).Trim()
            $html.Add("<h3>$(Convert-InlineMarkdown $h)</h3>")
            continue
        }

        if ($trimmed.StartsWith("## ")) {
            Flush-Paragraph
            Flush-List
            $h = $trimmed.Substring(3).Trim()
            $html.Add("<h2>$(Convert-InlineMarkdown $h)</h2>")
            continue
        }

        if ($trimmed.StartsWith("- ")) {
            Flush-Paragraph
            $listBuffer.Add($trimmed.Substring(2).Trim())
            continue
        }

        Flush-List
        $paragraphBuffer.Add($trimmed)
    }

    Flush-Paragraph
    Flush-List

    return ($html -join "`n")
}

function Get-FirstBodyParagraph {
    param([string]$RawText)

    $lines = $RawText -split "`r?`n"
    foreach ($line in $lines) {
        $t = $line.Trim()
        if ($t -eq "") { continue }
        if ($t.StartsWith("## ") -or $t.StartsWith("### ") -or $t.StartsWith("- ")) { continue }
        return $t
    }

    return ""
}

function Add-ArticleToIndex {
    param(
        [string]$IndexPath,
        [string]$Slug,
        [string]$Title,
        [string]$ImagePath,
        [string]$ImageAlt,
        [string]$Teaser
    )

    if (-not (Test-Path -LiteralPath $IndexPath)) {
        Write-Warning "articles/index.html not found. Skipping index update."
        return
    }

    $indexRaw = Get-Content -LiteralPath $IndexPath -Raw

    if ($indexRaw -match [regex]::Escape("href=`"$Slug.html`"")) {
        Write-Output "Index already contains: $Slug.html"
        return
    }

    $safeTitle = Escape-Html $Title
    $safeAlt = Escape-Html $ImageAlt
    $safeTeaser = Escape-Html $Teaser
    $card = @"
<article>
<a href="$Slug.html" class="image"><img src="$ImagePath" alt="$safeAlt" decoding="async" loading="lazy" /></a>
<h3>$safeTitle</h3>
<p>$safeTeaser</p>
<ul class="actions">
<li><a href="$Slug.html" class="button">Read Article</a></li>
</ul>
</article>
"@

    $needle = '<div class="posts">'
    $idx = $indexRaw.IndexOf($needle)
    if ($idx -lt 0) {
        Write-Warning "Could not find a posts container in articles/index.html. Skipping index update."
        return
    }

    $insertPos = $idx + $needle.Length
    $newIndex = $indexRaw.Insert($insertPos, "`n$card")
    Set-Content -LiteralPath $IndexPath -Value $newIndex -Encoding UTF8
    Write-Output "Updated index: $IndexPath"
}

if (-not (Test-Path -LiteralPath $BodyFile)) {
    throw "Body file not found: $BodyFile"
}

if ($Slug -notmatch "^[a-z0-9\-]+$") {
    throw "Slug must use lowercase letters, numbers, and hyphens only. Example: ai-tools-for-students-2026"
}

$bodyRaw = Get-Content -LiteralPath $BodyFile -Raw
$bodyHtml = Convert-BodyToHtml -RawText $bodyRaw
$firstParagraph = Get-FirstBodyParagraph -RawText $bodyRaw
$teaser = if ($firstParagraph -and $firstParagraph.Length -gt 20) { $firstParagraph } else { $Description }

$outputPath = Join-Path $PSScriptRoot ("articles/{0}.html" -f $Slug)
$canonical = "https://lookforit.xyz/articles/$Slug.html"
$ogImage = "https://lookforit.xyz/" + ($ImagePath -replace "^\.\./", "" -replace "^/", "")

$safeTitleHtml = Escape-Html $Title
$safeDescriptionHtml = Escape-Html $Description
$safeImageAltHtml = Escape-Html $ImageAlt
$safePublishedTextHtml = Escape-Html $PublishedText

$safeTitleJson = Escape-JsonString $Title
$safeDescriptionJson = Escape-JsonString $Description

$template = @"
<!DOCTYPE HTML>
<html lang="en">
<head>
<title>$safeTitleHtml - Lookforit.xyz</title>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
<meta name="robots" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
<meta name="googlebot" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
<meta name="theme-color" content="#0f172a" />
<meta name="description" content="$safeDescriptionHtml" />
<link rel="canonical" href="$canonical" />
<meta property="og:title" content="$safeTitleHtml" />
<meta property="og:description" content="$safeDescriptionHtml" />
<meta property="og:type" content="article" />
<meta property="og:url" content="$canonical" />
<meta property="og:image" content="$ogImage" />
<meta name="twitter:card" content="summary_large_image" />
<link rel="stylesheet" href="../assets/css/main.css" />

<script type="application/ld+json" data-ai="breadcrumb">
{
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    "itemListElement": [
        {
            "@type": "ListItem",
            "position": 1,
            "name": "Home",
            "item": "https://lookforit.xyz/"
        },
        {
            "@type": "ListItem",
            "position": 2,
            "name": "Articles",
            "item": "https://lookforit.xyz/articles/"
        },
        {
            "@type": "ListItem",
            "position": 3,
            "name": "$safeTitleJson",
            "item": "$canonical"
        }
    ]
}
</script>
<script type="application/ld+json" data-ai="article">
{
    "@context": "https://schema.org",
    "@type": "Article",
    "headline": "$safeTitleJson",
    "description": "$safeDescriptionJson",
    "dateModified": "$DateModified",
    "author": {
        "@type": "Person",
        "name": "Syed Shahid"
    },
    "publisher": {
        "@type": "Organization",
        "name": "Lookforit.xyz",
        "url": "https://lookforit.xyz",
        "logo": {
            "@type": "ImageObject",
            "url": "https://lookforit.xyz/Images/ai-tools-2026.jpg"
        }
    },
    "mainEntityOfPage": "$canonical"
}
</script>
</head>
<body class="is-preload">
<div id="wrapper"><div id="main"><div class="inner">
<header id="header"><a href="/" class="logo"><strong>Lookforit</strong> by Syed Shahid</a></header>
<section>
<header class="major"><h1>$safeTitleHtml</h1><p class="article-author-chip">Published by Syed Shahid</p></header>
<span class="image main"><img src="$ImagePath" alt="$safeImageAltHtml" decoding="async" loading="lazy" /></span>
<p><em>$safePublishedTextHtml</em></p>
$bodyHtml
<div class="author-box">
<div class="author-box-inner">
<img src="../Images/Admin%20image.jpeg" alt="Syed Shahid" decoding="async" loading="lazy" />
<div>
<h3>About the Author: Syed Shahid</h3>
<p>Syed Shahid is the founder and admin of Lookforit.xyz, based in Hyderabad. He is pursuing B.Sc Computer Science at St. Mary's College, Yousufguda, and writes practical guides on AI tools, online income systems, and digital workflows for students, creators, and builders.</p>
<p><a href="../founder.html">Read full founder profile</a></p>
<div class="author-social">
<ul class="icons">
<li><a href="https://x.com/syedShahid1433" class="icon brands fa-twitter" target="_blank" rel="noopener noreferrer"><span class="label">Twitter</span></a></li>
<li><a href="https://www.instagram.com/shah.voidheart/" class="icon brands fa-instagram" target="_blank" rel="noopener noreferrer"><span class="label">Instagram</span></a></li>
<li><a href="https://medium.com/@syedsinterprises" class="icon brands fa-medium-m" target="_blank" rel="noopener noreferrer"><span class="label">Medium</span></a></li>
<li><a href="https://github.com/Ampersent" class="icon brands fa-github" target="_blank" rel="noopener noreferrer"><span class="label">GitHub</span></a></li>
</ul>
</div>
</div>
</div>
</div>
<ul class="actions">
<li><a href="/articles/" class="button">More Articles</a></li>
<li><a href="/tools/" class="button">Browse AI Tools</a></li>
</ul>
</section>
</div></div>
<div id="sidebar"><div class="inner"><section id="search" class="alt"><form method="get" action="/tools/"><input type="text" name="query" id="query" placeholder="Search AI tools..." /></form></section><nav id="menu"><header class="major"><h2>Menu</h2></header><ul><li><span class="opener">Home</span><ul><li><a href="/">Homepage</a></li><li><a href="../about.html">About Us</a></li><li><a href="../contact.html">Contact</a></li><li><a href="../privacy-policy.html">Privacy Policy</a></li><li><a href="../terms.html">Terms &amp; Conditions</a></li><li><a href="../refund.html">Refund Policy</a></li><li><a href="../disclaimer.html">Disclaimer</a></li></ul></li><li><a href="/tools/">AI Tools</a></li><li><a href="/articles/">Articles</a></li><li><a href="../faq.html">FAQ</a></li><li><a href="/listing-requests/">Submit Your Tool</a></li></ul></nav><footer id="footer"><div class="footer-policy-links">
<a href="../privacy-policy.html">Privacy Policy</a>
<a href="../terms.html">Terms</a>
<a href="../refund.html">Refund Policy</a>
<a href="../disclaimer.html">Disclaimer</a>
<a href="../faq.html">FAQ</a>
<a href="../contact.html">Contact</a>
</div>
<p class="copyright">&copy; 2026 <a href="/">Lookforit.xyz</a>. All rights reserved.</p></footer></div></div></div>
<script src="../assets/js/jquery.min.js"></script><script src="../assets/js/browser.min.js"></script><script src="../assets/js/breakpoints.min.js"></script><script src="../assets/js/util.js"></script><script src="../assets/js/main.js"></script>
</body>
</html>
"@

Set-Content -LiteralPath $outputPath -Value $template -Encoding UTF8
Write-Output "Created: $outputPath"

if ($UpdateIndex) {
    $indexPath = Join-Path $PSScriptRoot "articles/index.html"
    Add-ArticleToIndex -IndexPath $indexPath -Slug $Slug -Title $Title -ImagePath $ImagePath -ImageAlt $ImageAlt -Teaser $teaser
}
