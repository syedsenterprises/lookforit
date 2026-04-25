param(
    [string]$BaseUrl = "https://lookforit.xyz"
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Get-SharedHead {
    param(
        [string]$Title,
        [string]$Description,
        [string]$Canonical,
        [string]$CssPrefix,
        [string]$OgType = "website"
    )

@"
<head>
<title>$Title - Lookforit.xyz</title>
<meta charset="utf-8" />
<link rel="icon" href="/favicon.svg" type="image/svg+xml" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<meta name="description" content="$Description" />
<meta name="robots" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
<meta name="googlebot" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
<meta name="theme-color" content="#0f172a" />
<link rel="canonical" href="$Canonical" />
<meta property="og:title" content="$Title" />
<meta property="og:description" content="$Description" />
<meta property="og:type" content="$OgType" />
<meta property="og:url" content="$Canonical" />
<meta property="og:site_name" content="Lookforit.xyz" />
<meta property="og:image" content="https://lookforit.xyz/Images/ai-tools-2026-pro.svg" />
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="$Title" />
<meta name="twitter:description" content="$Description" />
<meta name="twitter:image" content="https://lookforit.xyz/Images/ai-tools-2026-pro.svg" />
<link rel="stylesheet" href="${CssPrefix}assets/css/main.css?v=20260315-layout2" />
<link rel="stylesheet" href="${CssPrefix}assets/css/web-tools.css?v=20260316-wt1" />
</head>
"@
}

function Get-Sidebar {
@"
<div id="sidebar">
<div class="inner">
<section id="search" class="alt">
<form method="get" action="/web-tools/">
<input type="text" name="query" id="query" placeholder="Search built-in tools..." />
</form>
</section>
<nav id="menu">
<header class="major"><h2>Menu</h2></header>
<ul>
<li>
<span class="opener">Home</span>
<ul>
<li><a href="/">Homepage</a></li>
<li><a href="/about.html">About Us</a></li>
<li><a href="/contact.html">Contact</a></li>
<li><a href="/privacy-policy.html">Privacy Policy</a></li>
<li><a href="/terms.html">Terms &amp; Conditions</a></li>
<li><a href="/refund.html">Refund Policy</a></li>
<li><a href="/disclaimer.html">Disclaimer</a></li>
</ul>
</li>
<li><a href="/web-tools/">Built-in Web Tools</a></li>
<li><a href="/tools/">External AI Tools</a></li>
<li><a href="/articles/">Articles</a></li>
<li><a href="/resources.html">Resources</a></li>
<li><a href="/faq.html">FAQ</a></li>
</ul>
</nav>
<section>
<header class="major"><h2>Popular Built-in Tools</h2></header>
<div class="mini-posts">
<article><a href="/web-tools/text/word-counter.html" class="image"><img src="/Images/pic10.svg" alt="Word Counter" decoding="async" loading="lazy" /></a><p><a href="/web-tools/text/word-counter.html"><strong>Word Counter</strong></a> - Count words, characters, sentences instantly.</p></article>
<article><a href="/web-tools/converter/json-formatter.html" class="image"><img src="/Images/pic10.svg" alt="JSON Formatter" decoding="async" loading="lazy" /></a><p><a href="/web-tools/converter/json-formatter.html"><strong>JSON Formatter</strong></a> - Parse and beautify JSON safely in browser.</p></article>
<article><a href="/web-tools/productivity/todo-list.html" class="image"><img src="/Images/pic10.svg" alt="Todo List" decoding="async" loading="lazy" /></a><p><a href="/web-tools/productivity/todo-list.html"><strong>Todo List</strong></a> - Lightweight task manager with localStorage.</p></article>
</div>
<ul class="actions fit">
<li><a href="/web-tools/" class="button">View All Built-in Tools</a></li>
<li><a href="/tools/" class="button">View External AI Tools</a></li>
</ul>
</section>
<footer id="footer">
<div class="footer-policy-links">
<a href="/privacy-policy.html">Privacy Policy</a>
<a href="/terms.html">Terms</a>
<a href="/refund.html">Refund Policy</a>
<a href="/disclaimer.html">Disclaimer</a>
<a href="/faq.html">FAQ</a>
<a href="/contact.html">Contact</a>
</div>
<p class="copyright">&copy; 2026 <a href="/">Lookforit.xyz</a>. All rights reserved.</p>
</footer>
</div>
</div>
"@
}

function Get-FooterScripts {
    param([string]$JsPrefix)
@"
<script src="${JsPrefix}assets/js/jquery.min.js"></script>
<script src="${JsPrefix}assets/js/browser.min.js"></script>
<script src="${JsPrefix}assets/js/breakpoints.min.js"></script>
<script src="${JsPrefix}assets/js/util.js"></script>
<script src="${JsPrefix}assets/js/main.js"></script>
<script src="/assets/js/web-tools-runtime.js?v=20260316-wt1"></script>
<script src="/assets/js/tools-data.js"></script>
<script src="/assets/js/sidebar-search.js"></script>
"@
}

$categories = @(
    [PSCustomObject]@{ Slug = 'text'; Title = 'Text Tools'; Description = 'Text cleanup, counting, formatting, and comparison tools.'; Icon = 'TXT' },
    [PSCustomObject]@{ Slug = 'converter'; Title = 'Converter Tools'; Description = 'Format and encode data in your browser only.'; Icon = 'CNV' },
    [PSCustomObject]@{ Slug = 'developer'; Title = 'Developer Tools'; Description = 'Daily helper utilities for web developers.'; Icon = 'DEV' },
    [PSCustomObject]@{ Slug = 'image'; Title = 'Image Tools'; Description = 'Client-side image processing with canvas and FileReader.'; Icon = 'IMG' },
    [PSCustomObject]@{ Slug = 'calculator'; Title = 'Calculator Tools'; Description = 'Fast calculators for common personal and work use.'; Icon = 'CAL' },
    [PSCustomObject]@{ Slug = 'productivity'; Title = 'Productivity Tools'; Description = 'Simple tools to organize, focus, and decide faster.'; Icon = 'PRD' }
)

$tools = @(
    [PSCustomObject]@{ Category='text'; Slug='word-counter'; Title='Word Counter'; Description='Count words, characters, lines, and reading time for any text.' },
    [PSCustomObject]@{ Category='text'; Slug='character-counter'; Title='Character Counter'; Description='Track character and paragraph counts for content writing tasks.' },
    [PSCustomObject]@{ Category='text'; Slug='text-case-converter'; Title='Text Case Converter'; Description='Convert text to upper, lower, title, and sentence case instantly.' },
    [PSCustomObject]@{ Category='text'; Slug='remove-duplicate-lines'; Title='Remove Duplicate Lines'; Description='Clean repeated lines from text blocks while preserving order.' },
    [PSCustomObject]@{ Category='text'; Slug='text-sorter'; Title='Text Sorter'; Description='Sort lines alphabetically with ascending and descending options.' },
    [PSCustomObject]@{ Category='text'; Slug='text-compare'; Title='Text Compare'; Description='Compare two text blocks and highlight matching and changed lines.' },

    [PSCustomObject]@{ Category='converter'; Slug='json-formatter'; Title='JSON Formatter'; Description='Validate and beautify JSON with indentation and syntax safety.' },
    [PSCustomObject]@{ Category='converter'; Slug='base64-encode-decode'; Title='Base64 Encode Decode'; Description='Encode plain text to Base64 and decode Base64 back to text.' },
    [PSCustomObject]@{ Category='converter'; Slug='url-encoder-decoder'; Title='URL Encoder Decoder'; Description='Encode and decode URL-safe strings for web links and query values.' },
    [PSCustomObject]@{ Category='converter'; Slug='color-converter'; Title='Color Converter'; Description='Convert color values between HEX, RGB, and HSL formats.' },
    [PSCustomObject]@{ Category='converter'; Slug='unit-converter'; Title='Unit Converter'; Description='Convert length, weight, and temperature values quickly.' },

    [PSCustomObject]@{ Category='developer'; Slug='password-generator'; Title='Password Generator'; Description='Generate secure random passwords with configurable options.' },
    [PSCustomObject]@{ Category='developer'; Slug='uuid-generator'; Title='UUID Generator'; Description='Create UUID values instantly for IDs and development workflows.' },
    [PSCustomObject]@{ Category='developer'; Slug='hash-generator'; Title='Hash Generator'; Description='Create SHA-256 hash values directly in your browser.' },
    [PSCustomObject]@{ Category='developer'; Slug='regex-tester'; Title='Regex Tester'; Description='Test regular expressions against sample text with live matches.' },
    [PSCustomObject]@{ Category='developer'; Slug='timestamp-converter'; Title='Timestamp Converter'; Description='Convert Unix timestamps to date-time and back with timezone clarity.' },

    [PSCustomObject]@{ Category='image'; Slug='image-resizer'; Title='Image Resizer'; Description='Resize uploaded images with canvas while staying fully client-side.' },
    [PSCustomObject]@{ Category='image'; Slug='image-cropper'; Title='Image Cropper'; Description='Crop an image by pixel region and export the new file.' },
    [PSCustomObject]@{ Category='image'; Slug='image-to-base64'; Title='Image to Base64'; Description='Convert image files into Base64 strings for embedding.' },
    [PSCustomObject]@{ Category='image'; Slug='image-compressor'; Title='Image Compressor'; Description='Compress image quality in browser using canvas output settings.' },
    [PSCustomObject]@{ Category='image'; Slug='color-picker'; Title='Color Picker'; Description='Pick color values from an uploaded image at pixel-level.' },

    [PSCustomObject]@{ Category='calculator'; Slug='calculator'; Title='Calculator'; Description='Perform basic arithmetic operations quickly with keypad input.' },
    [PSCustomObject]@{ Category='calculator'; Slug='percentage-calculator'; Title='Percentage Calculator'; Description='Find percentages, increases, and decreases in one place.' },
    [PSCustomObject]@{ Category='calculator'; Slug='age-calculator'; Title='Age Calculator'; Description='Calculate exact age in years, months, and days.' },
    [PSCustomObject]@{ Category='calculator'; Slug='bmi-calculator'; Title='BMI Calculator'; Description='Calculate body mass index from height and weight values.' },
    [PSCustomObject]@{ Category='calculator'; Slug='random-number-generator'; Title='Random Number Generator'; Description='Generate random integers between a minimum and maximum.' },

    [PSCustomObject]@{ Category='productivity'; Slug='todo-list'; Title='Todo List'; Description='Manage tasks locally with completion state saved in browser.' },
    [PSCustomObject]@{ Category='productivity'; Slug='notes'; Title='Notes'; Description='Take and auto-save quick notes in localStorage.' },
    [PSCustomObject]@{ Category='productivity'; Slug='timer'; Title='Timer'; Description='Countdown timer with start, pause, and reset controls.' },
    [PSCustomObject]@{ Category='productivity'; Slug='stopwatch'; Title='Stopwatch'; Description='Track elapsed time with lap support and reset control.' },
    [PSCustomObject]@{ Category='productivity'; Slug='random-picker'; Title='Random Picker'; Description='Pick a random option from a custom list of entries.' }
)

$toolUis = @{
    'word-counter' = @"
<div class="wt-container">
<label class="wt-label" for="wcInput">Enter text</label>
<textarea id="wcInput" class="wt-textarea" placeholder="Paste or type text here..."></textarea>
<div class="wt-stats-grid">
<div class="wt-stat-item"><span id="wcWords" class="wt-stat-value">0</span><span class="wt-stat-label">Words</span></div>
<div class="wt-stat-item"><span id="wcChars" class="wt-stat-value">0</span><span class="wt-stat-label">Characters</span></div>
<div class="wt-stat-item"><span id="wcLines" class="wt-stat-value">0</span><span class="wt-stat-label">Lines</span></div>
<div class="wt-stat-item"><span id="wcRead" class="wt-stat-value">0</span><span class="wt-stat-label">Read Min</span></div>
</div>
</div>
"@;
    'character-counter' = @"
<div class="wt-container">
<label class="wt-label" for="ccInput">Enter text</label>
<textarea id="ccInput" class="wt-textarea" placeholder="Type text to count characters..."></textarea>
<div class="wt-stats-grid">
<div class="wt-stat-item"><span id="ccChars" class="wt-stat-value">0</span><span class="wt-stat-label">Characters</span></div>
<div class="wt-stat-item"><span id="ccNoSpace" class="wt-stat-value">0</span><span class="wt-stat-label">No Spaces</span></div>
<div class="wt-stat-item"><span id="ccWords" class="wt-stat-value">0</span><span class="wt-stat-label">Words</span></div>
<div class="wt-stat-item"><span id="ccParas" class="wt-stat-value">0</span><span class="wt-stat-label">Paragraphs</span></div>
</div>
</div>
"@;
    'text-case-converter' = @"
<div class="wt-container">
<label class="wt-label" for="tccInput">Enter text</label>
<textarea id="tccInput" class="wt-textarea" placeholder="Enter text for case conversion..."></textarea>
<div class="wt-buttons">
<button id="tccUpper" class="wt-btn">UPPERCASE</button>
<button id="tccLower" class="wt-btn blue">lowercase</button>
<button id="tccTitle" class="wt-btn grey">Title Case</button>
<button id="tccSentence" class="wt-btn green">Sentence case</button>
<button id="tccCopy" class="wt-btn">Copy</button>
</div>
</div>
"@;
    'remove-duplicate-lines' = @"
<div class="wt-container">
<label class="wt-label" for="rdlInput">Lines with duplicates</label>
<textarea id="rdlInput" class="wt-textarea" placeholder="One line per entry..."></textarea>
<div class="wt-buttons">
<button id="rdlRun" class="wt-btn">Remove Duplicates</button>
<button id="rdlCopy" class="wt-btn blue">Copy Output</button>
<button id="rdlClear" class="wt-btn grey">Clear</button>
</div>
<label class="wt-label" for="rdlOutput">Output</label>
<textarea id="rdlOutput" class="wt-textarea" readonly></textarea>
<div id="rdlStats" class="wt-status"></div>
</div>
"@;
    'text-sorter' = @"
<div class="wt-container">
<label class="wt-label" for="tsInput">Lines to sort</label>
<textarea id="tsInput" class="wt-textarea" placeholder="One line per item..."></textarea>
<div class="wt-row">
<div>
<label class="wt-label" for="tsOrder">Order</label>
<select id="tsOrder" class="wt-select"><option value="asc">Ascending (A-Z)</option><option value="desc">Descending (Z-A)</option></select>
</div>
<div>
<label class="wt-label" for="tsCase">Case</label>
<select id="tsCase" class="wt-select"><option value="insensitive">Case-insensitive</option><option value="sensitive">Case-sensitive</option></select>
</div>
</div>
<div class="wt-buttons"><button id="tsSort" class="wt-btn">Sort</button><button id="tsCopy" class="wt-btn blue">Copy Output</button></div>
<label class="wt-label" for="tsOutput">Output</label>
<textarea id="tsOutput" class="wt-textarea" readonly></textarea>
</div>
"@;
    'text-compare' = @"
<div class="wt-container">
<div class="wt-row">
<div><label class="wt-label" for="tcA">Text A</label><textarea id="tcA" class="wt-textarea" placeholder="Original text..."></textarea></div>
<div><label class="wt-label" for="tcB">Text B</label><textarea id="tcB" class="wt-textarea" placeholder="Updated text..."></textarea></div>
</div>
<div class="wt-buttons"><button id="tcCompare" class="wt-btn">Compare Text</button></div>
<div id="tcOut" class="diff-output"></div>
</div>
"@;

    'json-formatter' = @"
<div class="wt-container">
<label class="wt-label" for="jfInput">JSON Input</label>
<textarea id="jfInput" class="wt-textarea" placeholder='{"name":"Lookforit"}'></textarea>
<div class="wt-buttons">
<button id="jfFormat" class="wt-btn">Format JSON</button>
<button id="jfMinify" class="wt-btn blue">Minify</button>
<button id="jfCopy" class="wt-btn grey">Copy</button>
</div>
<label class="wt-label" for="jfOutput">Output</label>
<textarea id="jfOutput" class="wt-textarea" readonly></textarea>
<div id="jfStatus" class="wt-status"></div>
</div>
"@;
    'base64-encode-decode' = @"
<div class="wt-container">
<label class="wt-label" for="b64Input">Text / Base64 Input</label>
<textarea id="b64Input" class="wt-textarea" placeholder="Enter plain text or Base64..."></textarea>
<div class="wt-buttons"><button id="b64Encode" class="wt-btn">Encode</button><button id="b64Decode" class="wt-btn blue">Decode</button><button id="b64Copy" class="wt-btn grey">Copy</button></div>
<label class="wt-label" for="b64Output">Output</label>
<textarea id="b64Output" class="wt-textarea" readonly></textarea>
<div id="b64Status" class="wt-status"></div>
</div>
"@;
    'url-encoder-decoder' = @"
<div class="wt-container">
<label class="wt-label" for="uedInput">Input</label>
<textarea id="uedInput" class="wt-textarea" placeholder="URL text..."></textarea>
<div class="wt-buttons"><button id="uedEncode" class="wt-btn">URL Encode</button><button id="uedDecode" class="wt-btn blue">URL Decode</button></div>
<label class="wt-label" for="uedOutput">Output</label>
<textarea id="uedOutput" class="wt-textarea" readonly></textarea>
<div id="uedStatus" class="wt-status"></div>
</div>
"@;
    'color-converter' = @"
<div class="wt-container">
<label class="wt-label" for="ccvInput">Enter HEX, RGB or HSL</label>
<input id="ccvInput" class="wt-input" type="text" placeholder="#f56a6a or rgb(245,106,106)" />
<div class="wt-buttons"><button id="ccvConvert" class="wt-btn">Convert Color</button></div>
<div class="wt-color-row"><span id="ccvSwatch" class="wt-swatch"></span><span id="ccvHex" class="wt-color-val">HEX: -</span><span id="ccvRgb" class="wt-color-val">RGB: -</span><span id="ccvHsl" class="wt-color-val">HSL: -</span></div>
<div id="ccvStatus" class="wt-status"></div>
</div>
"@;
    'unit-converter' = @"
<div class="wt-container">
<div class="wt-row">
<div>
<label class="wt-label" for="ucType">Type</label>
<select id="ucType" class="wt-select"><option value="length">Length</option><option value="weight">Weight</option><option value="temperature">Temperature</option></select>
</div>
<div>
<label class="wt-label" for="ucValue">Value</label>
<input id="ucValue" class="wt-input" type="number" step="any" value="1" />
</div>
</div>
<div class="wt-row">
<div><label class="wt-label" for="ucFrom">From</label><select id="ucFrom" class="wt-select"></select></div>
<div><label class="wt-label" for="ucTo">To</label><select id="ucTo" class="wt-select"></select></div>
</div>
<div class="wt-buttons"><button id="ucConvert" class="wt-btn">Convert</button></div>
<div id="ucResult" class="wt-result"></div>
</div>
"@;

    'password-generator' = @"
<div class="wt-container">
<div class="wt-row">
<div><label class="wt-label" for="pgLength">Password Length</label><input id="pgLength" class="wt-input" type="number" min="6" max="64" value="16" /></div>
<div><label class="wt-label">Options</label>
<div><label><input type="checkbox" id="pgUpper" checked /> Uppercase</label></div>
<div><label><input type="checkbox" id="pgLower" checked /> Lowercase</label></div>
<div><label><input type="checkbox" id="pgNumber" checked /> Numbers</label></div>
<div><label><input type="checkbox" id="pgSymbol" checked /> Symbols</label></div>
</div>
</div>
<div class="wt-buttons"><button id="pgGenerate" class="wt-btn">Generate Password</button><button id="pgCopy" class="wt-btn blue">Copy</button></div>
<input id="pgOutput" class="wt-input" type="text" readonly />
<div id="pgStatus" class="wt-status"></div>
</div>
"@;
    'uuid-generator' = @"
<div class="wt-container">
<label class="wt-label" for="ugCount">How many UUIDs?</label>
<input id="ugCount" class="wt-input" type="number" min="1" max="100" value="5" />
<div class="wt-buttons"><button id="ugGenerate" class="wt-btn">Generate UUIDs</button><button id="ugCopy" class="wt-btn blue">Copy All</button></div>
<textarea id="ugOutput" class="wt-textarea" readonly></textarea>
</div>
"@;
    'hash-generator' = @"
<div class="wt-container">
<label class="wt-label" for="hgInput">Text to hash (SHA-256)</label>
<textarea id="hgInput" class="wt-textarea" placeholder="Text input..."></textarea>
<div class="wt-buttons"><button id="hgGenerate" class="wt-btn">Generate Hash</button><button id="hgCopy" class="wt-btn blue">Copy</button></div>
<textarea id="hgOutput" class="wt-textarea" readonly></textarea>
<div id="hgStatus" class="wt-status"></div>
</div>
"@;
    'regex-tester' = @"
<div class="wt-container">
<div class="wt-row">
<div><label class="wt-label" for="rtPattern">Regex Pattern</label><input id="rtPattern" class="wt-input" type="text" placeholder="\\b[a-zA-Z]{4}\\b" /></div>
<div><label class="wt-label" for="rtFlags">Flags</label><input id="rtFlags" class="wt-input" type="text" placeholder="gi" value="g" /></div>
</div>
<label class="wt-label" for="rtInput">Test Text</label>
<textarea id="rtInput" class="wt-textarea" placeholder="Write sample text..."></textarea>
<div class="wt-buttons"><button id="rtRun" class="wt-btn">Test Regex</button></div>
<div id="rtCount" class="wt-status"></div>
<div id="rtOutput" class="wt-container wt-highlighted"></div>
</div>
"@;
    'timestamp-converter' = @"
<div class="wt-container">
<div class="wt-row">
<div><label class="wt-label" for="tcTsInput">Unix Timestamp (seconds)</label><input id="tcTsInput" class="wt-input" type="number" placeholder="1710576000" /></div>
<div><label class="wt-label" for="tcDateInput">Date & Time</label><input id="tcDateInput" class="wt-input" type="datetime-local" /></div>
</div>
<div class="wt-buttons"><button id="tcToDate" class="wt-btn">Timestamp to Date</button><button id="tcToTs" class="wt-btn blue">Date to Timestamp</button><button id="tcNow" class="wt-btn grey">Now</button></div>
<div id="tcResult" class="wt-result"></div>
</div>
"@;

    'image-resizer' = @"
<div class="wt-container">
<label class="wt-label" for="irFile">Upload image</label>
<input id="irFile" class="wt-input" type="file" accept="image/*" />
<div class="wt-row">
<div><label class="wt-label" for="irWidth">Width</label><input id="irWidth" class="wt-input" type="number" min="1" /></div>
<div><label class="wt-label" for="irHeight">Height</label><input id="irHeight" class="wt-input" type="number" min="1" /></div>
</div>
<div class="wt-buttons"><button id="irResize" class="wt-btn">Resize Image</button><button id="irDownload" class="wt-btn blue">Download</button></div>
<div class="wt-canvas-wrap"><canvas id="irCanvas"></canvas></div>
<div id="irStatus" class="wt-status"></div>
</div>
"@;
    'image-cropper' = @"
<div class="wt-container">
<label class="wt-label" for="icFile">Upload image</label>
<input id="icFile" class="wt-input" type="file" accept="image/*" />
<div class="wt-row">
<div><label class="wt-label" for="icX">X</label><input id="icX" class="wt-input" type="number" min="0" value="0" /></div>
<div><label class="wt-label" for="icY">Y</label><input id="icY" class="wt-input" type="number" min="0" value="0" /></div>
<div><label class="wt-label" for="icW">Width</label><input id="icW" class="wt-input" type="number" min="1" value="100" /></div>
<div><label class="wt-label" for="icH">Height</label><input id="icH" class="wt-input" type="number" min="1" value="100" /></div>
</div>
<div class="wt-buttons"><button id="icCrop" class="wt-btn">Crop</button><button id="icDownload" class="wt-btn blue">Download</button></div>
<div class="wt-canvas-wrap"><canvas id="icCanvas"></canvas></div>
<div id="icStatus" class="wt-status"></div>
</div>
"@;
    'image-to-base64' = @"
<div class="wt-container">
<label class="wt-label" for="ibFile">Upload image</label>
<input id="ibFile" class="wt-input" type="file" accept="image/*" />
<div class="wt-buttons"><button id="ibCopy" class="wt-btn">Copy Base64</button></div>
<textarea id="ibOutput" class="wt-textarea" readonly placeholder="Base64 output..."></textarea>
<img id="ibPreview" class="wt-preview-img" alt="Image preview" />
<div id="ibStatus" class="wt-status"></div>
</div>
"@;
    'image-compressor' = @"
<div class="wt-container">
<label class="wt-label" for="imcFile">Upload image</label>
<input id="imcFile" class="wt-input" type="file" accept="image/*" />
<label class="wt-label" for="imcQuality">Quality (0.1 - 1.0)</label>
<input id="imcQuality" class="wt-input" type="range" min="0.1" max="1" step="0.05" value="0.7" />
<div class="wt-buttons"><button id="imcCompress" class="wt-btn">Compress</button><button id="imcDownload" class="wt-btn blue">Download</button></div>
<div class="wt-canvas-wrap"><canvas id="imcCanvas"></canvas></div>
<div id="imcStatus" class="wt-status"></div>
</div>
"@;
    'color-picker' = @"
<div class="wt-container">
<label class="wt-label" for="cpFile">Upload image</label>
<input id="cpFile" class="wt-input" type="file" accept="image/*" />
<p>Click on the image to pick a color.</p>
<div class="wt-canvas-wrap"><canvas id="cpCanvas"></canvas></div>
<div class="wt-color-row"><span id="cpSwatch" class="wt-swatch"></span><span id="cpHex" class="wt-color-val">HEX: -</span><span id="cpRgb" class="wt-color-val">RGB: -</span></div>
</div>
"@;

    'calculator' = @"
<div class="wt-container wt-calc-wrap">
<input id="calcDisplay" class="wt-calc-display" type="text" value="0" readonly />
<div class="wt-calc-grid">
<button class="wt-calc-btn clr" data-calc="C">C</button>
<button class="wt-calc-btn" data-calc="(">(</button>
<button class="wt-calc-btn" data-calc=")">)</button>
<button class="wt-calc-btn op" data-calc="/">/</button>
<button class="wt-calc-btn" data-calc="7">7</button>
<button class="wt-calc-btn" data-calc="8">8</button>
<button class="wt-calc-btn" data-calc="9">9</button>
<button class="wt-calc-btn op" data-calc="*">*</button>
<button class="wt-calc-btn" data-calc="4">4</button>
<button class="wt-calc-btn" data-calc="5">5</button>
<button class="wt-calc-btn" data-calc="6">6</button>
<button class="wt-calc-btn op" data-calc="-">-</button>
<button class="wt-calc-btn" data-calc="1">1</button>
<button class="wt-calc-btn" data-calc="2">2</button>
<button class="wt-calc-btn" data-calc="3">3</button>
<button class="wt-calc-btn op" data-calc="+">+</button>
<button class="wt-calc-btn wide" data-calc="0">0</button>
<button class="wt-calc-btn" data-calc=".">.</button>
<button class="wt-calc-btn eq" data-calc="=">=</button>
</div>
</div>
"@;
    'percentage-calculator' = @"
<div class="wt-container">
<div class="wt-inner-title">What is X% of Y?</div>
<div class="wt-row">
<div><label class="wt-label" for="pcPercent">X</label><input id="pcPercent" class="wt-input" type="number" step="any" /></div>
<div><label class="wt-label" for="pcValue">Y</label><input id="pcValue" class="wt-input" type="number" step="any" /></div>
</div>
<div class="wt-inner-title">Percentage Change</div>
<div class="wt-row">
<div><label class="wt-label" for="pcFrom">From</label><input id="pcFrom" class="wt-input" type="number" step="any" /></div>
<div><label class="wt-label" for="pcTo">To</label><input id="pcTo" class="wt-input" type="number" step="any" /></div>
</div>
<div class="wt-buttons"><button id="pcCalc" class="wt-btn">Calculate</button></div>
<div id="pcResult" class="wt-result"></div>
</div>
"@;
    'age-calculator' = @"
<div class="wt-container">
<label class="wt-label" for="acBirth">Date of Birth</label>
<input id="acBirth" class="wt-input" type="date" />
<div class="wt-buttons"><button id="acCalc" class="wt-btn">Calculate Age</button></div>
<div id="acResult" class="wt-result"></div>
</div>
"@;
    'bmi-calculator' = @"
<div class="wt-container">
<div class="wt-row">
<div><label class="wt-label" for="bmiWeight">Weight (kg)</label><input id="bmiWeight" class="wt-input" type="number" step="any" /></div>
<div><label class="wt-label" for="bmiHeight">Height (cm)</label><input id="bmiHeight" class="wt-input" type="number" step="any" /></div>
</div>
<div class="wt-buttons"><button id="bmiCalc" class="wt-btn">Calculate BMI</button></div>
<div id="bmiResult" class="wt-result"></div>
</div>
"@;
    'random-number-generator' = @"
<div class="wt-container">
<div class="wt-row">
<div><label class="wt-label" for="rngMin">Minimum</label><input id="rngMin" class="wt-input" type="number" value="1" /></div>
<div><label class="wt-label" for="rngMax">Maximum</label><input id="rngMax" class="wt-input" type="number" value="100" /></div>
</div>
<div class="wt-buttons"><button id="rngGenerate" class="wt-btn">Generate</button></div>
<div id="rngResult" class="wt-pick-result"></div>
</div>
"@;

    'todo-list' = @"
<div class="wt-container">
<div class="wt-row">
<div style="flex:3"><input id="tdInput" class="wt-input" type="text" placeholder="Add a task..." /></div>
<div style="flex:1"><button id="tdAdd" class="wt-btn" style="width:100%">Add Task</button></div>
</div>
<div id="tdList" style="margin-top:1em"></div>
<div id="tdCount" class="wt-todo-count"></div>
</div>
"@;
    'notes' = @"
<div class="wt-container">
<label class="wt-label" for="ntInput">Your Notes</label>
<textarea id="ntInput" class="wt-textarea" placeholder="Write your notes here..."></textarea>
<div class="wt-buttons"><button id="ntClear" class="wt-btn grey">Clear Notes</button></div>
<div id="ntMeta" class="wt-notes-meta"></div>
</div>
"@;
    'timer' = @"
<div class="wt-container">
<div class="wt-row">
<div><label class="wt-label" for="tmMinutes">Minutes</label><input id="tmMinutes" class="wt-input" type="number" min="0" value="5" /></div>
<div><label class="wt-label" for="tmSeconds">Seconds</label><input id="tmSeconds" class="wt-input" type="number" min="0" max="59" value="0" /></div>
</div>
<div id="tmDisplay" class="wt-timer-display">05:00</div>
<div class="wt-buttons"><button id="tmStart" class="wt-btn">Start</button><button id="tmPause" class="wt-btn blue">Pause</button><button id="tmReset" class="wt-btn grey">Reset</button></div>
</div>
"@;
    'stopwatch' = @"
<div class="wt-container">
<div id="swDisplay" class="wt-timer-display">00:00:00</div>
<div class="wt-buttons"><button id="swStart" class="wt-btn">Start</button><button id="swPause" class="wt-btn blue">Pause</button><button id="swLap" class="wt-btn green">Lap</button><button id="swReset" class="wt-btn grey">Reset</button></div>
<div id="swLaps"></div>
</div>
"@;
    'random-picker' = @"
<div class="wt-container">
<label class="wt-label" for="rpInput">Items (one per line)</label>
<textarea id="rpInput" class="wt-textarea" placeholder="Apple&#10;Banana&#10;Orange"></textarea>
<div class="wt-buttons"><button id="rpPick" class="wt-btn">Pick Random Item</button></div>
<div id="rpResult" class="wt-pick-result"></div>
</div>
"@
}

function Get-HowToHtml {
    param([string]$toolTitle)
@"
<h2>How to Use $toolTitle</h2>
<ol>
<li>Enter or upload your input in the tool interface above.</li>
<li>Click the main action button to process your input instantly.</li>
<li>Review the output and use copy or download where available.</li>
</ol>
"@
}

function Get-FeatureHtml {
@"
<h2>Features</h2>
<div class="wt-features">
<ul>
<li>Runs entirely in your browser with no server processing.</li>
<li>Fast processing for lightweight day-to-day tasks.</li>
<li>Works on static hosting including GitHub Pages.</li>
<li>Designed to match the existing Lookforit site layout.</li>
</ul>
</div>
"@
}

function Get-FaqHtml {
    param([string]$toolTitle)
@"
<h2>FAQ</h2>
<div class="wt-faq">
<details>
<summary>Is $toolTitle free to use?</summary>
<div class="wt-faq-answer">Yes. This tool is free to use directly on this site.</div>
</details>
<details>
<summary>Does this tool send my data to a server?</summary>
<div class="wt-faq-answer">No. The processing is done client-side in your browser for this lightweight version.</div>
</details>
<details>
<summary>Can I use this tool on mobile?</summary>
<div class="wt-faq-answer">Yes. The interface is responsive and supports both desktop and mobile browsers.</div>
</details>
</div>
"@
}

function Get-ToolCardsHtml {
    param([object[]]$toolList, [string]$categorySlug)

    $cards = [System.Collections.Generic.List[string]]::new()
    foreach ($tool in $toolList) {
        $cards.Add(@"
<a class="wt-tool-card" href="/web-tools/$categorySlug/$($tool.Slug).html">
<div class="wt-tool-card-icon">TOOL</div>
<div class="wt-tool-card-name">$($tool.Title)</div>
<div class="wt-tool-card-desc">$($tool.Description)</div>
</a>
"@)
    }
    return ($cards -join "`n")
}

function Get-CommonJsonLd {
    param(
        [string]$name,
        [string]$description,
        [string]$url,
        [string]$crumbSecondName,
        [string]$crumbSecondUrl,
        [string]$crumbThirdName,
        [string]$crumbThirdUrl
    )
@"
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    {"@type": "ListItem", "position": 1, "name": "Home", "item": "https://lookforit.xyz/"},
    {"@type": "ListItem", "position": 2, "name": "$crumbSecondName", "item": "$crumbSecondUrl"},
    {"@type": "ListItem", "position": 3, "name": "$crumbThirdName", "item": "$crumbThirdUrl"}
  ]
}
</script>
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebApplication",
  "name": "$name",
  "url": "$url",
  "description": "$description",
  "applicationCategory": "UtilitiesApplication",
  "operatingSystem": "Any",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  }
}
</script>
"@
}

New-Item -ItemType Directory -Path (Join-Path $PSScriptRoot 'web-tools') -Force | Out-Null
foreach ($cat in $categories) {
    New-Item -ItemType Directory -Path (Join-Path $PSScriptRoot "web-tools/$($cat.Slug)") -Force | Out-Null
}

# Hub page
$categoryCards = [System.Collections.Generic.List[string]]::new()
foreach ($cat in $categories) {
    $count = ($tools | Where-Object { $_.Category -eq $cat.Slug }).Count
    $categoryCards.Add(@"
<a class="wt-cat-card" href="/web-tools/$($cat.Slug)/">
<span class="wt-cat-icon">$($cat.Icon)</span>
<div class="wt-cat-title">$($cat.Title)</div>
<div class="wt-cat-desc">$($cat.Description)</div>
<div class="wt-cat-count">$count tools</div>
</a>
"@)
}

$hubHead = Get-SharedHead -Title 'Built-in Web Tools' -Description 'Free built-in web tools from Lookforit for text, conversion, developer, image, calculator, and productivity workflows.' -Canonical "$BaseUrl/web-tools/" -CssPrefix '../'
$hubLd = Get-CommonJsonLd -name 'Built-in Web Tools' -description 'Free built-in web tools from Lookforit.' -url "$BaseUrl/web-tools/" -crumbSecondName 'Built-in Web Tools' -crumbSecondUrl "$BaseUrl/web-tools/" -crumbThirdName 'Tool Categories' -crumbThirdUrl "$BaseUrl/web-tools/"

$hubHtml = @"
<!DOCTYPE HTML>
<html lang="en">
$hubHead
<body class="is-preload">
<div id="wrapper">
<div id="main">
<div class="inner">
<header id="header">
<a href="/" class="logo"><strong>Lookforit</strong></a> <span class="logo-by">by</span> <a href="https://www.letusassume.com" target="_blank" rel="noopener noreferrer" class="logo-author">Letusassume</a>
</header>
$hubLd
<section>
<div class="wt-breadcrumb"><a href="/">Home</a><span class="sep">/</span><span>Built-in Web Tools</span></div>
<header class="major">
<h1>Built-in Web Tools</h1>
<p>Fast and lightweight browser tools built directly inside Lookforit.</p>
</header>
<p>These tools are separate from the external AI tools directory and run fully on static hosting with no backend and no API keys.</p>
<div class="wt-cat-grid">
$($categoryCards -join "`n")
</div>
<h2>Browse by Category</h2>
<ul>
<li><a href="/web-tools/text/">Text Tools</a></li>
<li><a href="/web-tools/converter/">Converter Tools</a></li>
<li><a href="/web-tools/developer/">Developer Tools</a></li>
<li><a href="/web-tools/image/">Image Tools</a></li>
<li><a href="/web-tools/calculator/">Calculator Tools</a></li>
<li><a href="/web-tools/productivity/">Productivity Tools</a></li>
</ul>
<p><a href="/">Back to Homepage</a> | <a href="/tools/">Go to External Tools Directory</a></p>
</section>
</div>
</div>
$(Get-Sidebar)
</div>
$(Get-FooterScripts -JsPrefix '../')
</body>
</html>
"@

Set-Content -Path (Join-Path $PSScriptRoot 'web-tools/index.html') -Value $hubHtml -Encoding UTF8

# Category pages
foreach ($cat in $categories) {
    $catTools = $tools | Where-Object { $_.Category -eq $cat.Slug }
    $toolCards = Get-ToolCardsHtml -toolList $catTools -categorySlug $cat.Slug

    $catHead = Get-SharedHead -Title "$($cat.Title) - Built-in Tools" -Description "$($cat.Description) Explore built-in static tools inside Lookforit." -Canonical "$BaseUrl/web-tools/$($cat.Slug)/" -CssPrefix '../../'
    $catLd = Get-CommonJsonLd -name "$($cat.Title)" -description "$($cat.Description)" -url "$BaseUrl/web-tools/$($cat.Slug)/" -crumbSecondName 'Built-in Web Tools' -crumbSecondUrl "$BaseUrl/web-tools/" -crumbThirdName $cat.Title -crumbThirdUrl "$BaseUrl/web-tools/$($cat.Slug)/"

    $catHtml = @"
<!DOCTYPE HTML>
<html lang="en">
$catHead
<body class="is-preload">
<div id="wrapper">
<div id="main">
<div class="inner">
<header id="header">
<a href="/" class="logo"><strong>Lookforit</strong></a> <span class="logo-by">by</span> <a href="https://www.letusassume.com" target="_blank" rel="noopener noreferrer" class="logo-author">Letusassume</a>
</header>
$catLd
<section>
<div class="wt-breadcrumb"><a href="/">Home</a><span class="sep">/</span><a href="/web-tools/">Built-in Web Tools</a><span class="sep">/</span><span>$($cat.Title)</span></div>
<header class="major">
<h1>$($cat.Title)</h1>
<p>$($cat.Description)</p>
</header>
<div class="wt-tools-list">
$toolCards
</div>
<p><a href="/web-tools/">View All Built-in Tools</a> | <a href="/">Back to Homepage</a></p>
</section>
</div>
</div>
$(Get-Sidebar)
</div>
$(Get-FooterScripts -JsPrefix '../../')
</body>
</html>
"@

    Set-Content -Path (Join-Path $PSScriptRoot "web-tools/$($cat.Slug)/index.html") -Value $catHtml -Encoding UTF8
}

# Tool pages
foreach ($tool in $tools) {
    $cat = $categories | Where-Object { $_.Slug -eq $tool.Category } | Select-Object -First 1
    $related = $tools | Where-Object { $_.Category -eq $tool.Category -and $_.Slug -ne $tool.Slug } | Select-Object -First 4
    $relatedLinks = [System.Collections.Generic.List[string]]::new()
    foreach ($r in $related) {
        $relatedLinks.Add("<a href='/web-tools/$($r.Category)/$($r.Slug).html'>$($r.Title)</a>")
    }

    $toolHead = Get-SharedHead -Title "$($tool.Title) - Built-in Tool" -Description $tool.Description -Canonical "$BaseUrl/web-tools/$($tool.Category)/$($tool.Slug).html" -CssPrefix '../../' -OgType 'article'
    $toolLd = Get-CommonJsonLd -name $tool.Title -description $tool.Description -url "$BaseUrl/web-tools/$($tool.Category)/$($tool.Slug).html" -crumbSecondName 'Built-in Web Tools' -crumbSecondUrl "$BaseUrl/web-tools/" -crumbThirdName $tool.Title -crumbThirdUrl "$BaseUrl/web-tools/$($tool.Category)/$($tool.Slug).html"

    $ui = $toolUis[$tool.Slug]
    if (-not $ui) {
        $ui = "<div class='wt-container'><p>Tool UI placeholder.</p></div>"
    }

    $toolHtml = @"
<!DOCTYPE HTML>
<html lang="en">
$toolHead
<body class="is-preload" data-web-tool="$($tool.Slug)">
<div id="wrapper">
<div id="main">
<div class="inner">
<header id="header">
<a href="/" class="logo"><strong>Lookforit</strong></a> <span class="logo-by">by</span> <a href="https://www.letusassume.com" target="_blank" rel="noopener noreferrer" class="logo-author">Letusassume</a>
</header>
$toolLd
<section>
<div class="wt-breadcrumb"><a href="/">Home</a><span class="sep">/</span><a href="/web-tools/">Built-in Web Tools</a><span class="sep">/</span><a href="/web-tools/$($cat.Slug)/">$($cat.Title)</a><span class="sep">/</span><span>$($tool.Title)</span></div>
<header class="major">
<h1>$($tool.Title)</h1>
<p>$($tool.Description)</p>
</header>
<img src="/Images/pic10.svg" class="tool-hero-img" width="96" height="96" alt="$($tool.Title) icon" loading="lazy" decoding="async" />
$ui
$(Get-HowToHtml -toolTitle $tool.Title)
$(Get-FeatureHtml)
$(Get-FaqHtml -toolTitle $tool.Title)
<h2>Related Tools</h2>
<div class="wt-related">
$($relatedLinks -join "`n")
</div>
<p><strong>Category:</strong> <a href="/web-tools/$($cat.Slug)/">$($cat.Title)</a></p>
<p><a href="/web-tools/">All Built-in Tools</a> | <a href="/">Homepage</a> | <a href="/tools/">External Tools</a></p>
</section>
</div>
</div>
$(Get-Sidebar)
</div>
$(Get-FooterScripts -JsPrefix '../../')
</body>
</html>
"@

    Set-Content -Path (Join-Path $PSScriptRoot "web-tools/$($tool.Category)/$($tool.Slug).html") -Value $toolHtml -Encoding UTF8
}

Write-Host "WEB_TOOLS_GENERATED: hub + $($categories.Count) categories + $($tools.Count) tools"

& (Join-Path $PSScriptRoot 'generate-sitemap.ps1')

