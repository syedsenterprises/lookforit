# Lookforit Article Template (SEO + Internal Linking)

Use this template whenever publishing a new article page.

## 1. File naming

- Location: `articles/your-topic-keyword-2026.html`
- Slug style: lowercase + hyphens
- Include target keyword in file name

## 2. Head metadata checklist

- `title` (55-65 chars, target keyword near start)
- `meta description` (120-155 chars)
- canonical URL
- OG: title, description, type=article, url, image
- Twitter: card, title, description, image
- robots + googlebot index/follow

## 3. JSON-LD blocks

Include both blocks:

1. `BreadcrumbList`
2. `Article`

For `Article`:
- headline
- description
- dateModified
- author
- publisher
- mainEntityOfPage

## 4. Body structure

- H1 with primary keyword
- Intro (2-3 paragraphs)
- 5-8 H2 sections with useful, non-thin content
- FAQ section (4-6 questions)
- Related articles block
- Author box

## 5. Internal links rule

Per article page include at least:
- 3 links to `/tools/` pages
- 2 links to other `/articles/` pages
- 1 link to `/tools/` hub or `/articles/` hub

## 6. Suggested scaffold

```html
<header class="major">
  <h1>Primary Keyword Title</h1>
  <p class="article-author-chip">Published by Syed Shahid</p>
</header>

<p><em>Published March 2026</em></p>
<p>Opening paragraph...</p>

<h2>Main Section 1</h2>
<p>...</p>

<h2>Main Section 2</h2>
<p>Reference <a href="../tools/chatgpt.html">ChatGPT</a> and <a href="../tools/gemini.html">Gemini</a> where relevant.</p>

<h2>FAQ</h2>
<h3>1) Question</h3>
<p>Answer.</p>

<h2>Related Articles</h2>
<ul>
  <li><a href="../articles/example-1.html">Related article 1</a></li>
  <li><a href="../articles/example-2.html">Related article 2</a></li>
</ul>

<ul class="actions">
  <li><a href="/articles/" class="button">More Articles</a></li>
  <li><a href="/tools/" class="button">Browse AI Tools</a></li>
</ul>
```

## 7. Final checks before publish

- Run `./qa-site.ps1`
- Ensure no broken links
- Ensure canonical URL matches file
- Ensure article appears in `sitemap.xml` (run `./generate-sitemap.ps1`)
- Add article card to `articles/index.html`
