/* Lookforit theme v2 — vanilla JS. No dependencies.
   1) mobile nav toggle  2) dark mode toggle (localStorage, no-flash boot in <head>)
   3) homepage hero search (tools-data.js)  4) homepage tool quiz
   5) catalog upgrades: result count, category sort, surprise, favorites
   6) article reading progress + back-to-top  7) tool page copy-link
   8) homepage animated stat counters  9) card logo fallback (initials)
   10) FAQ expand/collapse-all (accordion itself is native <details>)
   11) hero typing effect + scroll reveal (both skip reduced motion;
       reveal only hides content when JS runs, so no-JS stays readable)
   12) catalog compare widget (real tools + real pricing only)
   13) homepage tool of the day (deterministic daily rotation, real tools)
   14) tool page share button (Web Share API, clipboard fallback)
   15) "/" keyboard shortcut focusing site search */

/* ---- quiz scoring (pure function; also used by the Node logic test) ---- */
var LOOKFORIT_TASK_CATS = {
  writing: ['Content', 'AI Chatbot', 'AI Assistant'],
  coding: ['Developer Tools', 'LLM', 'AI Chatbot'],
  images: ['Image Generation', 'Image Editing', 'Design'],
  video: ['Video', 'Audio/Video'],
  audio: ['Voice', 'Audio/Video'],
  business: ['Productivity', 'Automation', 'Platform', 'Content'],
  data: ['Data Labeling', 'Databases', 'AI Search', 'Evaluation', 'MLOps', 'Infrastructure']
};
var LOOKFORIT_POWER_CATS = {
  speed: ['Productivity', 'Automation'],
  creativity: ['Image Generation', 'Design', 'Video', 'Content'],
  organization: ['Productivity', 'Databases', 'Platform'],
  insight: ['AI Search', 'Evaluation', 'Data Labeling', 'LLM']
};

function lookforitRecommend(data, pricing, task, budget, power) {
  var taskCats = LOOKFORIT_TASK_CATS[task] || [];
  var powerCats = LOOKFORIT_POWER_CATS[power] || [];
  var scored = [];
  for (var i = 0; i < data.length; i++) {
    var t = data[i];
    var slug = (t.s || '').replace(/\.html$/i, '');
    var price = (pricing && pricing[slug]) || 'unknown';
    if (budget === 'free' && price === 'paid') continue;
    var score = 0;
    if (taskCats.indexOf(t.c) !== -1) score += 2;
    if (powerCats.indexOf(t.c) !== -1) score += 1;
    if (budget === 'free' && price === 'free') score += 1;
    scored.push({ tool: t, price: price, score: score });
  }
  scored.sort(function (a, b) {
    if (b.score !== a.score) return b.score - a.score;
    var an = (a.tool.n || '').toLowerCase(), bn = (b.tool.n || '').toLowerCase();
    return an < bn ? -1 : (an > bn ? 1 : 0);
  });
  return scored.slice(0, 3);
}

(function () {
  'use strict';

  function esc(s) {
    return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }
  function norm(s) { return (s || '').toLowerCase().trim(); }

  /* ---- mobile nav ---- */
  var toggle = document.getElementById('nav-toggle');
  var header = document.querySelector('.site-header');
  if (toggle && header) {
    toggle.addEventListener('click', function () {
      header.classList.toggle('nav-open');
      toggle.setAttribute('aria-expanded', header.classList.contains('nav-open') ? 'true' : 'false');
    });
  }

  /* ---- dark mode toggle ---- */
  var themeBtn = document.getElementById('theme-toggle');
  function paintThemeButton() {
    if (!themeBtn) return;
    var dark = document.documentElement.getAttribute('data-theme') === 'dark';
    themeBtn.textContent = dark ? '☀' : '☾';
    themeBtn.setAttribute('aria-pressed', dark ? 'true' : 'false');
    themeBtn.setAttribute('aria-label', dark ? 'Switch to light mode' : 'Switch to dark mode');
  }
  if (themeBtn) {
    paintThemeButton();
    themeBtn.addEventListener('click', function () {
      var dark = document.documentElement.getAttribute('data-theme') === 'dark';
      if (dark) {
        document.documentElement.removeAttribute('data-theme');
        try { localStorage.setItem('lookforit-theme', 'light'); } catch (e) {}
      } else {
        document.documentElement.setAttribute('data-theme', 'dark');
        try { localStorage.setItem('lookforit-theme', 'dark'); } catch (e) {}
      }
      paintThemeButton();
    });
  }

  /* ---- homepage hero search ---- */
  var input = document.getElementById('hero-search');
  var results = document.getElementById('hero-results');
  if (input && results) {
    var data = window.LookforitToolsData || [];
    input.addEventListener('input', function () {
      var q = input.value.trim().toLowerCase();
      if (q.length < 2) { results.classList.remove('open'); results.innerHTML = ''; return; }
      var hits = [];
      for (var i = 0; i < data.length && hits.length < 8; i++) {
        var t = data[i];
        var hay = ((t.n || '') + ' ' + (t.d || '') + ' ' + (t.c || '')).toLowerCase();
        if (hay.indexOf(q) !== -1) hits.push(t);
      }
      if (!hits.length) { results.classList.remove('open'); results.innerHTML = ''; return; }
      var html = '';
      hits.forEach(function (t) {
        html += '<li><a href="/tools/' + esc(t.s) + '">' + esc(t.n) +
          '<small>' + esc(t.c || '') + ' — ' + esc(t.d || '') + '</small></a></li>';
      });
      results.innerHTML = html;
      results.classList.add('open');
    });
    input.addEventListener('blur', function () {
      setTimeout(function () { results.classList.remove('open'); }, 200);
    });
    input.addEventListener('focus', function () {
      if (results.innerHTML) results.classList.add('open');
    });
  }

  /* ---- homepage tool quiz ---- */
  var quiz = document.getElementById('tool-quiz');
  if (quiz) {
    var submit = document.getElementById('quiz-submit');
    var hint = document.getElementById('quiz-hint');
    var out = document.getElementById('quiz-results');
    var retake = document.getElementById('quiz-retake');
    function picked(name) {
      var el = quiz.querySelector('input[name="' + name + '"]:checked');
      return el ? el.value : null;
    }
    if (submit && out) {
      submit.addEventListener('click', function () {
        var task = picked('quiz-task'), budget = picked('quiz-budget'), power = picked('quiz-power');
        if (!task || !budget || !power) {
          if (hint) hint.hidden = false;
          return;
        }
        if (hint) hint.hidden = true;
        var recs = lookforitRecommend(window.LookforitToolsData || [],
          window.LookforitPricing || {}, task, budget, power);
        var priceLabel = { free: 'Free', paid: 'Paid', unknown: 'Pricing not listed on this site' };
        var html = '';
        if (!recs.length) {
          html = '<p>No tools match those answers — try Paid OK or another task.</p>';
        } else {
          recs.forEach(function (r) {
            var t = r.tool;
            html += '<article class="quiz-result"><h3><a href="/tools/' + esc(t.s) + '">' + esc(t.n) + '</a></h3>' +
              '<p class="quiz-cat">' + esc(t.c || '') + '</p>' +
              '<p>' + esc(t.d || '') + '</p>' +
              '<p class="quiz-price">' + esc(priceLabel[r.price] || priceLabel.unknown) + '</p></article>';
          });
        }
        out.innerHTML = html;
        if (retake) retake.hidden = false;
      });
    }
    if (retake) {
      retake.addEventListener('click', function () {
        var radios = quiz.querySelectorAll('input[type="radio"]');
        for (var i = 0; i < radios.length; i++) radios[i].checked = false;
        if (out) out.innerHTML = '';
        if (hint) hint.hidden = true;
        retake.hidden = true;
        var first = quiz.querySelector('input[type="radio"]');
        if (first) first.focus();
      });
    }
  }

  /* ---- homepage stat counters ---- */
  var counters = document.querySelectorAll('.stat-num[data-count]');
  if (counters.length) {
    var reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    function runCounter(el) {
      var target = parseInt(el.getAttribute('data-count'), 10) || 0;
      if (reduced || !window.requestAnimationFrame) { el.textContent = target; return; }
      var start = null;
      function step(ts) {
        if (!start) start = ts;
        var p = Math.min((ts - start) / 1000, 1);
        el.textContent = Math.round(target * (1 - Math.pow(1 - p, 2)));
        if (p < 1) window.requestAnimationFrame(step);
      }
      window.requestAnimationFrame(step);
    }
    if ('IntersectionObserver' in window) {
      var obs = new IntersectionObserver(function (entries) {
        entries.forEach(function (en) {
          if (en.isIntersecting) { runCounter(en.target); obs.unobserve(en.target); }
        });
      }, { threshold: 0.4 });
      counters.forEach(function (el) { obs.observe(el); });
    } else {
      counters.forEach(runCounter);
    }
  }

  /* ---- catalog upgrades (tools/index.html) ---- */
  var grid = document.getElementById('grid');
  var searchInput = document.getElementById('tools-search');
  var categorySelect = document.getElementById('tools-category');
  var pricingSelect = document.getElementById('tools-pricing');
  var sortSelect = document.getElementById('tools-sort');
  if (grid && searchInput && categorySelect && sortSelect) {
    var FAV_KEY = 'lookforit-favs';
    function loadFavs() {
      try {
        var v = JSON.parse(localStorage.getItem(FAV_KEY) || '[]');
        return Array.isArray(v) ? v : [];
      } catch (e) { return []; }
    }
    function saveFavs(favs) {
      try { localStorage.setItem(FAV_KEY, JSON.stringify(favs)); } catch (e) {}
    }
    var favs = loadFavs();
    function isFav(slug) { return favs.indexOf(slug) !== -1; }

    /* inject controls: result count, surprise, favorites-only */
    var controls = document.querySelector('.controls');
    var countEl = null, favOnly = null;
    if (controls) {
      countEl = document.createElement('span');
      countEl.id = 'tools-count';
      countEl.className = 'tools-count';
      countEl.setAttribute('aria-live', 'polite');
      controls.appendChild(countEl);
      var surprise = document.createElement('button');
      surprise.type = 'button';
      surprise.id = 'tools-surprise';
      surprise.className = 'button';
      surprise.textContent = 'Surprise me';
      surprise.addEventListener('click', function () {
        var all = Array.prototype.slice.call(grid.querySelectorAll('.card'));
        if (!all.length) return;
        var card = all[Math.floor(Math.random() * all.length)];
        var link = card.querySelector('h2 a[href]');
        if (link) window.location.href = link.getAttribute('href');
      });
      controls.appendChild(surprise);
      var favLabel = document.createElement('label');
      favLabel.className = 'fav-only';
      favOnly = document.createElement('input');
      favOnly.type = 'checkbox';
      favOnly.id = 'tools-fav-only';
      favLabel.appendChild(favOnly);
      favLabel.appendChild(document.createTextNode(' Favorites only'));
      controls.appendChild(favLabel);
    }

    /* category sort option (existing script only knows az/za) */
    var catOpt = document.createElement('option');
    catOpt.value = 'category';
    catOpt.textContent = 'Sort: Category';
    sortSelect.appendChild(catOpt);
    var params = new URLSearchParams(window.location.search);
    if (params.get('sort') === 'category') sortSelect.value = 'category';

    /* heart buttons on every card */
    var cards = Array.prototype.slice.call(grid.querySelectorAll('.card'));
    function cardSlug(card) {
      var s = card.getAttribute('data-slug');
      if (s) return s;
      var link = card.querySelector('h2 a[href]');
      if (!link) return '';
      return norm(link.getAttribute('href').split('/').pop().replace(/\.html$/i, ''));
    }
    cards.forEach(function (card) {
      var slug = cardSlug(card);
      if (slug) card.setAttribute('data-slug', slug);
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'fav-btn';
      btn.setAttribute('aria-label', 'Save to favorites');
      btn.setAttribute('aria-pressed', isFav(slug) ? 'true' : 'false');
      btn.textContent = isFav(slug) ? '♥' : '♡';
      btn.addEventListener('click', function () {
        var i = favs.indexOf(slug);
        if (i === -1) { favs.push(slug); } else { favs.splice(i, 1); }
        saveFavs(favs);
        btn.setAttribute('aria-pressed', isFav(slug) ? 'true' : 'false');
        btn.textContent = isFav(slug) ? '♥' : '♡';
        applyEnhanced();
      });
      card.appendChild(btn);
    });

    var stickySlugs = ['chatgpt', 'claude', 'google-gemini', 'grok', 'perplexity',
      'midjourney', 'github-copilot', 'cursor', 'runway', 'elevenlabs', 'canva-ai', 'leonardo-ai'];
    var stickyRank = {};
    stickySlugs.forEach(function (s, i) { stickyRank[s] = i; });
    function getCardText(card) {
      var title = card.querySelector('h2') ? card.querySelector('h2').textContent : '';
      var desc = card.querySelector('p') ? card.querySelector('p').textContent : '';
      return norm((card.getAttribute('data-name') || '') + ' ' + title + ' ' + desc + ' ' + (card.getAttribute('data-category') || ''));
    }
    function applyEnhanced() {
      var query = norm(searchInput.value);
      var category = categorySelect.value;
      var pricing = pricingSelect ? pricingSelect.value : '';
      var sort = sortSelect.value;
      var favOnlyOn = favOnly ? favOnly.checked : false;
      var visible = [];
      cards.forEach(function (card) {
        var text = getCardText(card);
        var cardCategory = card.getAttribute('data-category') || '';
        var cardPricing = card.getAttribute('data-pricing') || 'unknown';
        var show = (!query || text.indexOf(query) !== -1) &&
          (!category || cardCategory === category) &&
          (!pricing || cardPricing === pricing) &&
          (!favOnlyOn || isFav(cardSlug(card)));
        card.style.display = show ? '' : 'none';
        if (show) visible.push(card);
      });
      visible.sort(function (a, b) {
        if (sort === 'category') {
          var ca = norm(a.getAttribute('data-category') || ''), cb = norm(b.getAttribute('data-category') || '');
          if (ca !== cb) return ca < cb ? -1 : 1;
          var na = norm(a.getAttribute('data-name') || a.textContent), nb = norm(b.getAttribute('data-name') || b.textContent);
          return na < nb ? -1 : (na > nb ? 1 : 0);
        }
        var ra = stickyRank.hasOwnProperty(cardSlug(a)) ? stickyRank[cardSlug(a)] : 9999;
        var rb = stickyRank.hasOwnProperty(cardSlug(b)) ? stickyRank[cardSlug(b)] : 9999;
        if (ra !== rb) return ra - rb;
        var na2 = norm(a.getAttribute('data-name') || a.textContent), nb2 = norm(b.getAttribute('data-name') || b.textContent);
        return sort === 'za' ? (na2 < nb2 ? 1 : (na2 > nb2 ? -1 : 0)) : (na2 < nb2 ? -1 : (na2 > nb2 ? 1 : 0));
      });
      visible.forEach(function (card) { grid.appendChild(card); });
      if (countEl) countEl.textContent = 'Showing ' + visible.length + ' of ' + cards.length + ' tools';
    }
    ['input', 'change'].forEach(function (ev) {
      searchInput.addEventListener(ev, applyEnhanced);
      categorySelect.addEventListener(ev, applyEnhanced);
      if (pricingSelect) pricingSelect.addEventListener(ev, applyEnhanced);
      sortSelect.addEventListener(ev, applyEnhanced);
    });
    if (favOnly) favOnly.addEventListener('change', applyEnhanced);
    applyEnhanced();
  }

  /* ---- article reading progress + back-to-top ---- */
  var path = window.location.pathname || '';
  var isArticle = path.indexOf('/articles/') === 0 &&
    path !== '/articles/' && path !== '/articles/index.html';
  if (isArticle) {
    var prog = document.createElement('div');
    prog.id = 'reading-progress';
    var fill = document.createElement('div');
    fill.id = 'reading-progress-fill';
    prog.appendChild(fill);
    document.body.appendChild(prog);
    var toTop = document.createElement('button');
    toTop.id = 'to-top';
    toTop.type = 'button';
    toTop.textContent = '↑ Top';
    toTop.setAttribute('aria-label', 'Back to top');
    document.body.appendChild(toTop);
    var reducedMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    function onScroll() {
      var el = document.documentElement;
      var max = el.scrollHeight - el.clientHeight;
      var pct = max > 0 ? (el.scrollTop / max) * 100 : 0;
      fill.style.width = pct + '%';
      if (el.scrollTop > 600) { toTop.classList.add('show'); } else { toTop.classList.remove('show'); }
    }
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
    toTop.addEventListener('click', function () {
      window.scrollTo({ top: 0, behavior: reducedMotion ? 'auto' : 'smooth' });
    });
  }

  /* ---- tool page copy-link ---- */
  var copyBtn = document.getElementById('copy-link-btn');
  if (copyBtn) {
    copyBtn.addEventListener('click', function () {
      var link = document.querySelector('link[rel="canonical"]');
      var url = (link && link.getAttribute('href')) || window.location.href;
      var done = function () {
        var orig = copyBtn.textContent;
        copyBtn.textContent = 'Copied!';
        setTimeout(function () { copyBtn.textContent = orig; }, 2000);
      };
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(url).then(done, function () { fallbackCopy(url, done); });
      } else {
        fallbackCopy(url, done);
      }
    });
    function fallbackCopy(text, done) {
      var ta = document.createElement('textarea');
      ta.value = text;
      ta.style.cssText = 'position:fixed;opacity:0;';
      document.body.appendChild(ta);
      ta.select();
      try { document.execCommand('copy'); } catch (e) {}
      document.body.removeChild(ta);
      done();
    }
  }

  /* ---- hero typing effect (homepage headline) ---- */
  var reducedMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var heroH1 = document.querySelector('#banner h1');
  if (heroH1 && !reducedMotion) {
    var fullHeadline = heroH1.textContent;
    if (fullHeadline && fullHeadline.length < 120) {
      heroH1.textContent = '';
      heroH1.classList.add('typing');
      var ti = 0;
      var typer = setInterval(function () {
        ti++;
        heroH1.textContent = fullHeadline.slice(0, ti);
        if (ti >= fullHeadline.length) {
          clearInterval(typer);
          heroH1.classList.remove('typing');
        }
      }, 45);
    }
  }

  /* ---- scroll reveal (cards + homepage sections) ----
     .reveal classes are added by JS only, and CSS hides them only when
     html.js is present (set by the <head> boot script), so with JS
     disabled or reduced motion everything stays fully visible. */
  if ('IntersectionObserver' in window && !reducedMotion) {
    var revealEls = document.querySelectorAll(
      '.posts article, .tools-grid article, .card-grid article, ' +
      '.catalog-cards-grid article, .tool-quiz, .stats-strip, .totd, .compare-tool');
    revealEls.forEach(function (el) {
      el.classList.add('reveal');
      var siblings = el.parentNode ? el.parentNode.querySelectorAll('.reveal') : [];
      var idx = Array.prototype.indexOf.call(siblings, el);
      el.style.transitionDelay = ((idx % 6) * 60) + 'ms';
    });
    var robs = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        if (en.isIntersecting) {
          en.target.classList.add('revealed');
          robs.unobserve(en.target);
        }
      });
    }, { threshold: 0.15 });
    revealEls.forEach(function (el) { robs.observe(el); });
  }

  /* ---- catalog compare widget (tools/index.html) ---- */
  var compare = document.getElementById('compare-tool');
  if (compare && window.LookforitToolsData && window.LookforitToolsData.length) {
    var compData = window.LookforitToolsData.slice().sort(function (a, b) {
      var an = (a.n || '').toLowerCase(), bn = (b.n || '').toLowerCase();
      return an < bn ? -1 : (an > bn ? 1 : 0);
    });
    var compBySlug = {};
    compData.forEach(function (t) {
      compBySlug[(t.s || '').replace(/\.html$/i, '')] = t;
    });
    var compPrice = {};
    document.querySelectorAll('#grid .card').forEach(function (card) {
      var link = card.querySelector('h2 a[href]');
      if (!link) return;
      var slug = link.getAttribute('href').split('/').pop().replace(/\.html$/i, '');
      compPrice[slug] = card.getAttribute('data-pricing') || 'unknown';
    });
    var compPriceLabel = { free: 'Free', paid: 'Paid', unknown: 'Not listed on this site' };
    ['compare-1', 'compare-2', 'compare-3'].forEach(function (id, i) {
      var sel = document.getElementById(id);
      if (!sel) return;
      var opt0 = document.createElement('option');
      opt0.value = '';
      opt0.textContent = i < 2 ? 'Choose a tool…' : '— none —';
      sel.appendChild(opt0);
      compData.forEach(function (t) {
        var o = document.createElement('option');
        o.value = (t.s || '').replace(/\.html$/i, '');
        o.textContent = t.n;
        sel.appendChild(o);
      });
    });
    var compGo = document.getElementById('compare-go');
    var compClear = document.getElementById('compare-clear');
    var compHint = document.getElementById('compare-hint');
    var compOut = document.getElementById('compare-results');
    function compPicked() {
      var slugs = [];
      ['compare-1', 'compare-2', 'compare-3'].forEach(function (id) {
        var sel = document.getElementById(id);
        if (sel && sel.value && compBySlug[sel.value] && slugs.indexOf(sel.value) === -1) {
          slugs.push(sel.value);
        }
      });
      return slugs;
    }
    if (compGo && compOut) {
      compGo.addEventListener('click', function () {
        var slugs = compPicked();
        if (slugs.length < 2) {
          if (compHint) compHint.hidden = false;
          return;
        }
        if (compHint) compHint.hidden = true;
        var head = '<th></th>';
        slugs.forEach(function (slug) {
          var t = compBySlug[slug];
          head += '<th><a href="/tools/' + esc(t.s) + '">' + esc(t.n) + '</a></th>';
        });
        function row(label, fn) {
          var r = '<tr><th>' + label + '</th>';
          slugs.forEach(function (slug) { r += '<td>' + fn(compBySlug[slug], slug) + '</td>'; });
          return r + '</tr>';
        }
        compOut.innerHTML =
          '<table class="compare-table"><thead><tr>' + head + '</tr></thead><tbody>' +
          row('Category', function (t) { return esc(t.c || ''); }) +
          row('Description', function (t) { return esc(t.d || ''); }) +
          row('Pricing', function (t, slug) {
            return esc(compPriceLabel[compPrice[slug]] || compPriceLabel.unknown);
          }) +
          row('Directory page', function (t) {
            return '<a href="/tools/' + esc(t.s) + '">View ' + esc(t.n) + ' →</a>';
          }) +
          '</tbody></table>';
      });
    }
    if (compClear && compOut) {
      compClear.addEventListener('click', function () {
        ['compare-1', 'compare-2', 'compare-3'].forEach(function (id) {
          var sel = document.getElementById(id);
          if (sel) sel.value = '';
        });
        compOut.innerHTML = '';
        if (compHint) compHint.hidden = true;
      });
    }
  }

  /* ---- tool of the day (homepage) ----
     Deterministic UTC-day rotation over tools sorted by slug — the same
     rule the build used for the static pick, so JS and no-JS agree on
     the method (JS just advances it to the visitor's date). */
  var totdPick = document.getElementById('totd-pick');
  if (totdPick && window.LookforitToolsData && window.LookforitToolsData.length) {
    var totdSorted = window.LookforitToolsData.slice().sort(function (a, b) {
      var sa = (a.s || '').replace(/\.html$/i, ''), sb = (b.s || '').replace(/\.html$/i, '');
      return sa < sb ? -1 : (sa > sb ? 1 : 0);
    });
    var totdDays = Math.floor(Date.now() / 86400000);
    var totdTool = totdSorted[totdDays % totdSorted.length];
    var totdSlug = (totdTool.s || '').replace(/\.html$/i, '');
    var totdPrice = (window.LookforitPricing && window.LookforitPricing[totdSlug]) || 'unknown';
    var totdPriceLabel = { free: 'Free', paid: 'Paid', unknown: 'Pricing not listed on this site' };
    var totdDate = new Date(totdDays * 86400000).toLocaleDateString('en-US',
      { timeZone: 'UTC', year: 'numeric', month: 'long', day: 'numeric' });
    totdPick.innerHTML =
      '<h3><a href="/tools/' + esc(totdTool.s) + '">' + esc(totdTool.n) + '</a></h3>' +
      '<p class="totd-cat">' + esc(totdTool.c || '') + '</p>' +
      '<p>' + esc(totdTool.d || '') + '</p>' +
      '<p class="totd-price">' + esc(totdPriceLabel[totdPrice] || totdPriceLabel.unknown) + '</p>' +
      '<p class="totd-date">Pick for ' + esc(totdDate) + '</p>';
  }

  /* ---- tool page share button (Web Share API, clipboard fallback) ---- */
  var shareBtn = document.getElementById('share-btn');
  if (shareBtn) {
    shareBtn.addEventListener('click', function () {
      var link = document.querySelector('link[rel="canonical"]');
      var url = (link && link.getAttribute('href')) || window.location.href;
      function copiedFeedback() {
        var orig = shareBtn.textContent;
        shareBtn.textContent = 'Link copied!';
        setTimeout(function () { shareBtn.textContent = orig; }, 2000);
      }
      function clipboardFallback() {
        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(url).then(copiedFeedback, function () {});
          return;
        }
        var ta = document.createElement('textarea');
        ta.value = url;
        ta.style.cssText = 'position:fixed;opacity:0;';
        document.body.appendChild(ta);
        ta.select();
        try { document.execCommand('copy'); } catch (e) {}
        document.body.removeChild(ta);
        copiedFeedback();
      }
      if (navigator.share) {
        navigator.share({ title: document.title, url: url }).catch(function () {});
      } else {
        clipboardFallback();
      }
    });
  }

  /* ---- "/" shortcut: focus site search ---- */
  document.addEventListener('keydown', function (e) {
    if (e.key !== '/' || e.ctrlKey || e.metaKey || e.altKey) return;
    var t = e.target;
    if (t && (t.tagName === 'INPUT' || t.tagName === 'TEXTAREA' ||
              t.tagName === 'SELECT' || t.isContentEditable)) return;
    var target = document.getElementById('hero-search') ||
      document.getElementById('site-search');
    if (target) {
      e.preventDefault();
      target.focus();
    }
  });

  /* ---- FAQ expand / collapse all ---- */
  document.querySelectorAll('.faq-expand').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var list = btn.closest('.faq-list');
      if (list) list.querySelectorAll('details.faq-item').forEach(function (d) { d.open = true; });
    });
  });
  document.querySelectorAll('.faq-collapse').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var list = btn.closest('.faq-list');
      if (list) list.querySelectorAll('details.faq-item').forEach(function (d) { d.open = false; });
    });
  });

  /* ---- card logo fallback: a broken logo image becomes initials ----
     Covers both the extended catalog grid and the main catalog cards
     (whose logos are real files; a missing one degrades to initials,
     never to a placeholder image). */
  document.addEventListener('error', function (e) {
    var t = e.target;
    if (t && t.tagName === 'IMG' && t.closest &&
        (t.closest('#catalog-grid') || t.closest('.card-thumb'))) {
      var name = t.getAttribute('alt') || '';
      var card = t.closest('article.card');
      if (card) {
        var h2 = card.querySelector('h2');
        if (h2) name = h2.textContent;
      }
      if (!name) name = 'AI';
      var initials = name.split(/\s+/).map(function (w) { return w.charAt(0); }).join('').slice(0, 2).toUpperCase();
      var span = document.createElement('span');
      span.className = 'card-initials';
      span.setAttribute('aria-hidden', 'true');
      span.textContent = initials;
      if (t.parentNode) t.parentNode.replaceChild(span, t);
    }
  }, true);
})();
