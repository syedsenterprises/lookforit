/* Lookforit fresh v1 — interactions. No fake data anywhere.
   Dark mode, mobile nav, scroll reveal, back-to-top, direct-mail forms. */
(function () {
  'use strict';

  /* Theme: boot already applied pre-CSS in head; toggle keeps it. */
  var toggle = document.getElementById('theme-toggle');
  if (toggle) {
    var syncToggle = function () {
      var dark = document.documentElement.getAttribute('data-theme') === 'dark';
      toggle.textContent = dark ? '☀' : '☾';
      toggle.setAttribute('aria-label', dark ? 'Switch to light mode' : 'Switch to dark mode');
    };
    syncToggle();
    toggle.addEventListener('click', function () {
      var dark = document.documentElement.getAttribute('data-theme') === 'dark';
      if (dark) {
        document.documentElement.removeAttribute('data-theme');
        try { localStorage.removeItem('lookforit-theme'); } catch (e) {}
      } else {
        document.documentElement.setAttribute('data-theme', 'dark');
        try { localStorage.setItem('lookforit-theme', 'dark'); } catch (e) {}
      }
      syncToggle();
    });
  }

  /* Mobile nav */
  var navToggle = document.getElementById('nav-toggle');
  var nav = document.querySelector('.site-nav');
  if (navToggle && nav) {
    navToggle.addEventListener('click', function () {
      var open = nav.classList.toggle('open');
      navToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
  }

  /* Scroll reveal */
  var revealEls = document.querySelectorAll('.reveal');
  if ('IntersectionObserver' in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        if (en.isIntersecting) { en.target.classList.add('visible'); io.unobserve(en.target); }
      });
    }, { threshold: 0.12 });
    revealEls.forEach(function (el) { io.observe(el); });
  } else {
    revealEls.forEach(function (el) { el.classList.add('visible'); });
  }

  /* Back to top */
  var toTop = document.getElementById('to-top');
  if (toTop) {
    window.addEventListener('scroll', function () {
      toTop.style.display = window.scrollY > 600 ? 'block' : 'none';
    });
    toTop.addEventListener('click', function () { window.scrollTo({ top: 0, behavior: 'smooth' }); });
  }

  /* Copy page link */
  var copyBtn = document.getElementById('copy-link-btn');
  if (copyBtn) {
    copyBtn.addEventListener('click', function () {
      var done = function () { copyBtn.textContent = 'Link copied ✓'; };
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(window.location.href).then(done).catch(function () {});
      }
    });
  }

  /* Direct-mail forms: compose a mailto: email to the site owner.
     No third-party form service, nothing stored server-side.
     Without JavaScript, the forms fall back to a plain mailto: post. */
  var TO = 'syedsinterprises@gmail.com';
  function field(form, name) {
    var el = form.querySelector('[name="' + name + '"]');
    return el ? el.value.trim() : '';
  }
  function send(subject, lines) {
    window.location.href = 'mailto:' + TO + '?subject=' + encodeURIComponent(subject) +
      '&body=' + encodeURIComponent(lines.join('\n'));
  }
  var SUBJECT_LABELS = {
    suggestion: 'Suggest a Tool or Website',
    correction: 'Report an Error',
    partnership: 'Partnership / Collaboration',
    other: 'Other'
  };
  var PLAN_LABELS = {
    standard: 'Standard Listing - $49',
    featured: 'Featured Listing - $129',
    sponsored: 'Sponsored Campaign - Custom'
  };
  var contactForm = document.getElementById('contact-form');
  if (contactForm) {
    contactForm.addEventListener('submit', function (e) {
      e.preventDefault();
      var name = field(contactForm, 'name'), email = field(contactForm, 'email'),
          subj = field(contactForm, 'subject'), msg = field(contactForm, 'message');
      if (!name || !email || !msg) return;
      send('Lookforit contact: ' + (SUBJECT_LABELS[subj] || 'General enquiry'),
        ['Name: ' + name, 'Email: ' + email,
         'Subject: ' + (SUBJECT_LABELS[subj] || subj || '-'), '', msg]);
    });
  }
  var listingForm = document.getElementById('listing-form');
  if (listingForm) {
    listingForm.addEventListener('submit', function (e) {
      e.preventDefault();
      var tool = field(listingForm, 'tool_name'), url = field(listingForm, 'tool_url'),
          founder = field(listingForm, 'founder_name'), email = field(listingForm, 'email'),
          plan = field(listingForm, 'listing_plan'), cat = field(listingForm, 'category'),
          desc = field(listingForm, 'description');
      if (!tool || !url || !founder || !email || !plan || !desc) return;
      send('New tool listing request: ' + tool,
        ['Tool name: ' + tool, 'Official website: ' + url, 'Your name: ' + founder,
         'Contact email: ' + email, 'Listing plan: ' + (PLAN_LABELS[plan] || plan),
         'Suggested category: ' + (cat || '-'), '', desc]);
    });
  }

  /* Directory search (honest empty state until entries exist). */
  var heroSearch = document.getElementById('hero-search');
  var heroNote = document.getElementById('hero-search-note');
  if (heroSearch) {
    heroSearch.addEventListener('submit', function (e) {
      e.preventDefault();
      var q = (document.getElementById('hero-search-input') || {}).value || '';
      q = q.trim();
      if (heroNote) {
        heroNote.textContent = q
          ? 'No tools match "' + q + '" yet — the directory is rebuilding from zero. Submit a tool and it will appear here after editorial review.'
          : 'Type a tool name or category to search the directory.';
      }
      if (q) { window.location.href = '/tools/?query=' + encodeURIComponent(q); }
    });
  }

  /* v2 search: pages + built-in free tools, matched client-side. */
  var SEARCH_INDEX = [
    { n: 'Home', u: '/', k: 'home lookforit directory' },
    { n: 'AI Tools', u: '/tools/', k: 'ai tools directory listings' },
    { n: 'Free Tools', u: '/free-tools/', k: 'free tools browser utilities' },
    { n: 'Articles', u: '/articles/', k: 'articles guides' },
    { n: 'Earn Online', u: '/earn-online.html', k: 'earn online freelancing guides' },
    { n: 'Submit Tool', u: '/listing-requests/', k: 'submit tool listing request' },
    { n: 'FAQ', u: '/faq.html', k: 'faq questions help' },
    { n: 'Contact', u: '/contact.html', k: 'contact email' },
    { n: 'About', u: '/about.html', k: 'about lookforit' },
    { n: 'AI Cost Calculator', u: '/free-tools/ai-cost-calculator.html', k: 'ai cost calculator tokens price api' },
    { n: 'Prompt Builder', u: '/free-tools/prompt-builder.html', k: 'prompt builder ai prompt writing' },
    { n: 'Word Counter & Readability', u: '/free-tools/word-counter.html', k: 'word counter readability flesch words characters' },
    { n: 'JSON Formatter & Validator', u: '/free-tools/json-formatter.html', k: 'json formatter validator minify' },
    { n: 'Password Generator', u: '/free-tools/password-generator.html', k: 'password generator random strong' },
    { n: 'Color Palette & Gradient', u: '/free-tools/color-palette.html', k: 'color palette gradient hex css' },
    { n: 'Meta Tag Generator', u: '/free-tools/meta-tag-generator.html', k: 'meta tags seo open graph' },
    { n: 'Text Toolkit', u: '/free-tools/text-toolkit.html', k: 'text case convert sort lines duplicates' },
    { n: 'Unit Converter', u: '/free-tools/unit-converter.html', k: 'unit converter length weight temperature data' },
    { n: 'Markdown Preview', u: '/free-tools/markdown-preview.html', k: 'markdown preview renderer' },
    { n: 'Focus Timer', u: '/free-tools/focus-timer.html', k: 'focus timer pomodoro productivity' },
    { n: 'Base64 Encoder & Decoder', u: '/free-tools/base64-encoder.html', k: 'base64 encode decode' },
    { n: 'UUID Generator', u: '/free-tools/uuid-generator.html', k: 'uuid generator random id' },
    { n: 'Regex Tester', u: '/free-tools/regex-tester.html', k: 'regex tester regular expression match' },
    { n: 'Color Contrast Checker', u: '/free-tools/contrast-checker.html', k: 'contrast checker wcag accessibility color ratio' },
    { n: 'Lorem Ipsum Generator', u: '/free-tools/lorem-ipsum.html', k: 'lorem ipsum placeholder text' },
    { n: 'CSV to JSON Converter', u: '/free-tools/csv-to-json.html', k: 'csv json converter' },
    { n: 'Text Diff', u: '/free-tools/text-diff.html', k: 'text diff compare lines' },
    { n: 'Stopwatch & Countdown', u: '/free-tools/stopwatch.html', k: 'stopwatch countdown timer' },
    { n: 'Random Picker', u: '/free-tools/random-picker.html', k: 'random picker winner number' },
    { n: 'AI21 Labs', u: '/tools/ai21.html', k: 'ai21 labs llm ai tools ai tool' },
    { n: 'Airtable AI', u: '/tools/airtable-ai.html', k: 'airtable ai productivity ai tools ai tool' },
    { n: 'Anthropic API', u: '/tools/anthropic-api.html', k: 'anthropic api platform ai tools ai tool' },
    { n: 'Anyscale', u: '/tools/anyscale.html', k: 'anyscale infrastructure ai tools ai tool' },
    { n: 'AWS Bedrock', u: '/tools/aws-bedrock.html', k: 'aws bedrock platform ai tools ai tool' },
    { n: 'Azure OpenAI Service', u: '/tools/azure-openai.html', k: 'azure openai service platform ai tools ai tool' },
    { n: 'Black Forest Labs', u: '/tools/black-forest-labs.html', k: 'black forest labs image generation ai tools ai tool' },
    { n: 'Blackbox AI', u: '/tools/blackbox-ai.html', k: 'blackbox ai developer tools ai tools ai tool' },
    { n: 'Bolt.new', u: '/tools/bolt-new.html', k: 'bolt.new developer tools ai tools ai tool' },
    { n: 'Canva AI', u: '/tools/canva-ai.html', k: 'canva ai design ai tools ai tool' },
    { n: 'CapCut AI', u: '/tools/capcut-ai.html', k: 'capcut ai video ai tools ai tool' },
    { n: 'Cerebras', u: '/tools/cerebras.html', k: 'cerebras infrastructure ai tools ai tool' },
    { n: 'Character.AI', u: '/tools/character-ai.html', k: 'character.ai ai chatbot ai tools ai tool' },
    { n: 'ChatGPT', u: '/tools/chatgpt.html', k: 'chatgpt ai chatbot ai tools ai tool' },
    { n: 'Chroma', u: '/tools/chroma.html', k: 'chroma databases ai tools ai tool' },
    { n: 'Claude', u: '/tools/claude.html', k: 'claude ai assistant ai tools ai tool' },
    { n: 'Cleanup.pictures', u: '/tools/cleanup-pictures.html', k: 'cleanup.pictures image editing ai tools ai tool' },
    { n: 'ClickUp AI', u: '/tools/clickup-ai.html', k: 'clickup ai productivity ai tools ai tool' },
    { n: 'Coda AI', u: '/tools/coda-ai.html', k: 'coda ai productivity ai tools ai tool' },
    { n: 'Codeium', u: '/tools/codeium.html', k: 'codeium developer tools ai tools ai tool' },
    { n: 'Cohere', u: '/tools/cohere.html', k: 'cohere llm ai tools ai tool' },
    { n: 'Comet ML', u: '/tools/comet-ml.html', k: 'comet ml mlops ai tools ai tool' },
    { n: 'Copy.ai', u: '/tools/copy-ai.html', k: 'copy.ai content ai tools ai tool' },
    { n: 'Cursor', u: '/tools/cursor.html', k: 'cursor developer tools ai tools ai tool' },
    { n: 'DALL-E', u: '/tools/dall-e.html', k: 'dall-e image generation ai tools ai tool' },
    { n: 'DeepL', u: '/tools/deepl.html', k: 'deepl content ai tools ai tool' },
    { n: 'DeepSeek', u: '/tools/deepseek.html', k: 'deepseek llm ai tools ai tool' },
    { n: 'Descript', u: '/tools/descript.html', k: 'descript audio/video ai tools ai tool' },
    { n: 'EleutherAI GPT-NeoX', u: '/tools/gpt-neox.html', k: 'eleutherai gpt-neox llm ai tools ai tool' },
    { n: 'ElevenLabs', u: '/tools/elevenlabs.html', k: 'elevenlabs voice ai tools ai tool' },
    { n: 'Eval Harness (HELM)', u: '/tools/helm.html', k: 'eval harness (helm) evaluation ai tools ai tool' },
    { n: 'Figma AI', u: '/tools/figma-ai.html', k: 'figma ai design ai tools ai tool' },
    { n: 'Fireflies.ai', u: '/tools/fireflies-ai.html', k: 'fireflies.ai productivity ai tools ai tool' },
    { n: 'Framer AI', u: '/tools/framer-ai.html', k: 'framer ai design ai tools ai tool' },
    { n: 'Gamma', u: '/tools/gamma.html', k: 'gamma productivity ai tools ai tool' },
    { n: 'Genspark', u: '/tools/genspark.html', k: 'genspark platform ai tools ai tool' },
    { n: 'GitHub Copilot', u: '/tools/github-copilot.html', k: 'github copilot developer tools ai tools ai tool' },
    { n: 'Google Gemini', u: '/tools/google-gemini.html', k: 'google gemini ai assistant ai tools ai tool' },
    { n: 'Grammarly', u: '/tools/grammarly.html', k: 'grammarly content ai tools ai tool' },
    { n: 'Grok', u: '/tools/grok.html', k: 'grok ai chatbot ai tools ai tool' },
    { n: 'HeyGen', u: '/tools/heygen.html', k: 'heygen video ai tools ai tool' },
    { n: 'Hugging Face', u: '/tools/hugging-face.html', k: 'hugging face platform ai tools ai tool' },
    { n: 'Humanloop', u: '/tools/humanloop.html', k: 'humanloop mlops ai tools ai tool' },
    { n: 'Ideogram', u: '/tools/ideogram.html', k: 'ideogram image generation ai tools ai tool' },
    { n: 'InnerCanvas', u: '/tools/innercanvas.html', k: 'innercanvas productivity ai tools ai tool' },
    { n: 'InVideo AI', u: '/tools/invideo-ai.html', k: 'invideo ai video ai tools ai tool' },
    { n: 'Jasper', u: '/tools/jasper.html', k: 'jasper content ai tools ai tool' },
    { n: 'Kimi', u: '/tools/kimi.html', k: 'kimi ai chatbot ai tools ai tool' },
    { n: 'Kling', u: '/tools/kling.html', k: 'kling video ai tools ai tool' },
    { n: 'Krisp', u: '/tools/krisp.html', k: 'krisp voice ai tools ai tool' },
    { n: 'Label Studio', u: '/tools/label-studio.html', k: 'label studio data labeling ai tools ai tool' },
    { n: 'LangChain', u: '/tools/langchain.html', k: 'langchain developer tools ai tools ai tool' },
    { n: 'LangSmith', u: '/tools/langsmith.html', k: 'langsmith mlops ai tools ai tool' },
    { n: 'Leonardo AI', u: '/tools/leonardo-ai.html', k: 'leonardo ai image generation ai tools ai tool' },
    { n: 'Llama 3', u: '/tools/llama-3.html', k: 'llama 3 llm ai tools ai tool' },
    { n: 'LMSYS Chatbot Arena', u: '/tools/lmsys-arena.html', k: 'lmsys chatbot arena evaluation ai tools ai tool' },
    { n: 'Lovable', u: '/tools/lovable.html', k: 'lovable developer tools ai tools ai tool' },
    { n: 'Luma', u: '/tools/luma.html', k: 'luma video ai tools ai tool' },
    { n: 'Make.com', u: '/tools/make-com.html', k: 'make.com automation ai tools ai tool' },
    { n: 'Manus', u: '/tools/manus.html', k: 'manus ai assistant ai tools ai tool' },
    { n: 'Mem AI', u: '/tools/mem-ai.html', k: 'mem ai productivity ai tools ai tool' },
    { n: 'Midjourney', u: '/tools/midjourney.html', k: 'midjourney image generation ai tools ai tool' },
    { n: 'Milvus', u: '/tools/milvus.html', k: 'milvus databases ai tools ai tool' },
    { n: 'Mistral AI', u: '/tools/mistral-ai.html', k: 'mistral ai llm ai tools ai tool' },
    { n: 'Modal', u: '/tools/modal.html', k: 'modal infrastructure ai tools ai tool' },
    { n: 'Murf AI', u: '/tools/murf-ai.html', k: 'murf ai voice ai tools ai tool' },
    { n: 'n8n', u: '/tools/n8n.html', k: 'n8n automation ai tools ai tool' },
    { n: 'Napkin AI', u: '/tools/napkin-ai.html', k: 'napkin ai design ai tools ai tool' },
    { n: 'Neptune.ai', u: '/tools/neptune-ai.html', k: 'neptune.ai mlops ai tools ai tool' },
    { n: 'Notion AI', u: '/tools/notion-ai.html', k: 'notion ai productivity ai tools ai tool' },
    { n: 'OctoAI', u: '/tools/octoai.html', k: 'octoai platform ai tools ai tool' },
    { n: 'OpenAI API', u: '/tools/openai-api.html', k: 'openai api platform ai tools ai tool' },
    { n: 'Otter.ai', u: '/tools/otter-ai.html', k: 'otter.ai productivity ai tools ai tool' },
    { n: 'Perplexity', u: '/tools/perplexity.html', k: 'perplexity ai search ai tools ai tool' },
    { n: 'Phind', u: '/tools/phind.html', k: 'phind ai search ai tools ai tool' },
    { n: 'Pika Labs', u: '/tools/pika-labs.html', k: 'pika labs video ai tools ai tool' },
    { n: 'Pinecone', u: '/tools/pinecone.html', k: 'pinecone databases ai tools ai tool' },
    { n: 'Poe', u: '/tools/poe.html', k: 'poe ai chatbot ai tools ai tool' },
    { n: 'PromptLayer', u: '/tools/promptlayer.html', k: 'promptlayer mlops ai tools ai tool' },
    { n: 'Qdrant', u: '/tools/qdrant.html', k: 'qdrant databases ai tools ai tool' },
    { n: 'QuillBot', u: '/tools/quillbot.html', k: 'quillbot content ai tools ai tool' },
    { n: 'Qwen', u: '/tools/qwen.html', k: 'qwen ai chatbot ai tools ai tool' },
    { n: 'Raycast', u: '/tools/raycast.html', k: 'raycast productivity ai tools ai tool' },
    { n: 'Remove.bg', u: '/tools/remove-bg.html', k: 'remove.bg image editing ai tools ai tool' },
    { n: 'Replicate', u: '/tools/replicate.html', k: 'replicate platform ai tools ai tool' },
    { n: 'Replit Ghostwriter', u: '/tools/replit-ghostwriter.html', k: 'replit ghostwriter developer tools ai tools ai tool' },
    { n: 'Rewind AI', u: '/tools/rewind-ai.html', k: 'rewind ai productivity ai tools ai tool' },
    { n: 'RunPod', u: '/tools/runpod.html', k: 'runpod infrastructure ai tools ai tool' },
    { n: 'Runway', u: '/tools/runway.html', k: 'runway video ai tools ai tool' },
    { n: 'Scale AI', u: '/tools/scale-ai.html', k: 'scale ai data labeling ai tools ai tool' },
    { n: 'SlidesAI', u: '/tools/slidesai.html', k: 'slidesai productivity ai tools ai tool' },
    { n: 'Snorkel', u: '/tools/snorkel.html', k: 'snorkel data labeling ai tools ai tool' },
    { n: 'Speechify', u: '/tools/speechify.html', k: 'speechify voice ai tools ai tool' },
    { n: 'Stable Diffusion', u: '/tools/stable-diffusion.html', k: 'stable diffusion image generation ai tools ai tool' },
    { n: 'Suno', u: '/tools/suno.html', k: 'suno audio/video ai tools ai tool' },
    { n: 'Supabase Vector', u: '/tools/supabase-vector.html', k: 'supabase vector databases ai tools ai tool' },
    { n: 'Synthesia', u: '/tools/synthesia.html', k: 'synthesia video ai tools ai tool' },
    { n: 'Tabnine', u: '/tools/tabnine.html', k: 'tabnine developer tools ai tools ai tool' },
    { n: 'Together AI', u: '/tools/together-ai.html', k: 'together ai platform ai tools ai tool' },
    { n: 'Udio', u: '/tools/udio.html', k: 'udio audio/video ai tools ai tool' },
    { n: 'Upstage Solar LLM', u: '/tools/upstage-solar.html', k: 'upstage solar llm llm ai tools ai tool' },
    { n: 'v0', u: '/tools/v0.html', k: 'v0 developer tools ai tools ai tool' },
    { n: 'VEED AI', u: '/tools/veed-ai.html', k: 'veed ai video ai tools ai tool' },
    { n: 'Vertex AI', u: '/tools/vertex-ai.html', k: 'vertex ai platform ai tools ai tool' },
    { n: 'Weaviate', u: '/tools/weaviate.html', k: 'weaviate databases ai tools ai tool' },
    { n: 'Weights & Biases', u: '/tools/weights-and-biases.html', k: 'weights & biases mlops ai tools ai tool' },
    { n: 'Windsurf', u: '/tools/windsurf.html', k: 'windsurf developer tools ai tools ai tool' },
    { n: 'Wordtune', u: '/tools/wordtune.html', k: 'wordtune content ai tools ai tool' },
    { n: 'Writer', u: '/tools/writer.html', k: 'writer content ai tools ai tool' },
    { n: 'Writesonic', u: '/tools/writesonic.html', k: 'writesonic content ai tools ai tool' },
    { n: 'You.com', u: '/tools/you-com.html', k: 'you.com ai search ai tools ai tool' },
    { n: 'Zapier AI', u: '/tools/zapier-ai.html', k: 'zapier ai automation ai tools ai tool' },
    { n: 'Zilliz', u: '/tools/zilliz.html', k: 'zilliz databases ai tools ai tool' },
  ];
  function searchMatches(q) {
    q = (q || '').toLowerCase().trim();
    if (!q) { return []; }
    return SEARCH_INDEX.filter(function (e) {
      return (e.n + ' ' + e.k).toLowerCase().indexOf(q) > -1;
    });
  }
  /* Tools page: render matches for ?query= (directory is empty, free tools are real). */
  var toolsResults = document.getElementById('search-results');
  if (toolsResults) {
    var q = new URLSearchParams(location.search).get('query');
    if (q) {
      var matches = searchMatches(q);
      var note = document.getElementById('search-note');
      if (note) { note.hidden = false; }
      if (matches.length) {
        if (note) { note.textContent = 'Matches for "' + q + '":'; }
        toolsResults.innerHTML = matches.map(function (m) {
          return '<div class="search-result"><h3><a href="' + m.u + '">' + m.n + '</a></h3><p>' + m.k + '</p></div>';
        }).join('');
      } else {
        if (note) { note.textContent = 'No tools match "' + q + '" yet \u2014 try a category name, or try the free built-in tools.'; }
      }
    }
  }

})();
