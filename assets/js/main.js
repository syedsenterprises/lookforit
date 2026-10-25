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
})();
