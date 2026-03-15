/**
 * sidebar-search.js — Autocomplete dropdown for the sidebar search input
 *
 * Requires: tools-data.js loaded first (defines window.LookforitToolsData)
 * Place both scripts before </body> on any page that has the sidebar search input.
 *
 * Features:
 *  - Live dropdown of up to 8 matching tools as the user types
 *  - Filters by name, category, and description keywords
 *  - Arrow key + Enter keyboard navigation
 *  - Pressing Enter with no selection navigates to /tools/?query=...
 *  - Clicking outside closes the dropdown
 *  - Works on any page depth (uses absolute /tools/ URLs)
 */

(function () {
  'use strict';

  var MAX_RESULTS = 8;
  var TOOLS_URL   = '/tools/';

  function init() {
    var input = document.getElementById('query');
    if (!input) return;

    var tools = (window.LookforitToolsData || []);
    if (!tools.length) return;

    /* ---- Build dropdown container ---- */
    var dropdown = document.createElement('ul');
    dropdown.id = 'sidebar-search-dropdown';
    dropdown.setAttribute('role', 'listbox');
    dropdown.style.cssText = [
      'position:absolute',
      'z-index:9999',
      'background:#1d1f2b',
      'border:1px solid #333',
      'border-radius:6px',
      'margin:2px 0 0',
      'padding:0',
      'list-style:none',
      'width:100%',
      'box-shadow:0 6px 18px rgba(0,0,0,0.5)',
      'display:none'
    ].join(';');

    /* Wrap input in a relative container */
    var wrapper = document.createElement('div');
    wrapper.style.cssText = 'position:relative;';
    input.parentNode.insertBefore(wrapper, input);
    wrapper.appendChild(input);
    wrapper.appendChild(dropdown);

    var activeIdx = -1;

    /* ---- Helpers ---- */
    function score(tool, q) {
      var ql = q.toLowerCase();
      var nl = tool.n.toLowerCase();
      var kl = (tool.k || '').toLowerCase();
      var dl = (tool.d || '').toLowerCase();
      var cl = (tool.c || '').toLowerCase();
      if (nl === ql || kl === ql) return 100;
      if (nl.startsWith(ql) || kl.startsWith(ql)) return 80;
      if (nl.includes(ql) || kl.includes(ql)) return 60;
      if (dl.includes(ql)) return 40;
      if (cl.toLowerCase().includes(ql)) return 20;
      return 0;
    }

    function buildUrl(tool) {
        var slug = (tool && tool.s) ? String(tool.s).trim() : '';
        if (!slug) return TOOLS_URL;
        if (/^https?:\/\//i.test(slug)) return slug;
        if (!/\.html?$/i.test(slug)) slug += '.html';
        return TOOLS_URL + slug;
    }

    function closeDropdown() {
      dropdown.style.display = 'none';
      dropdown.innerHTML = '';
      activeIdx = -1;
    }

    function setActive(idx) {
      var items = dropdown.querySelectorAll('li');
      items.forEach(function (li, i) {
        li.setAttribute('aria-selected', i === idx ? 'true' : 'false');
        li.style.background = i === idx ? '#2d3250' : '';
      });
      activeIdx = idx;
    }

    function renderDropdown(q) {
      dropdown.innerHTML = '';
      activeIdx = -1;
      if (!q || q.length < 1) { dropdown.style.display = 'none'; return; }

      var results = tools
        .map(function (t) { return { tool: t, s: score(t, q) }; })
        .filter(function (r) { return r.s > 0; })
        .sort(function (a, b) { return b.s - a.s; })
        .slice(0, MAX_RESULTS);

      if (!results.length) {
        /* Show "Search all results" link */
        var li = document.createElement('li');
        li.style.cssText = 'padding:0.5rem 0.75rem;color:#888;font-size:0.85rem;';
        li.textContent = 'No direct match — press Enter to search all';
        dropdown.appendChild(li);
        dropdown.style.display = 'block';
        return;
      }

      results.forEach(function (r, i) {
        var li = document.createElement('li');
        li.setAttribute('role', 'option');
        li.setAttribute('aria-selected', 'false');
        li.style.cssText = 'padding:0.45rem 0.75rem;cursor:pointer;border-bottom:1px solid #2a2a3a;';

        var nameEl = document.createElement('span');
        nameEl.style.cssText = 'display:block;font-size:0.9rem;color:#e2e8f0;font-weight:600;';
        nameEl.textContent = r.tool.n;

        var catEl = document.createElement('span');
        catEl.style.cssText = 'font-size:0.75rem;color:#94a3b8;margin-left:0.4rem;';
        catEl.textContent = r.tool.c;

        var row = document.createElement('div');
        row.appendChild(nameEl);
        nameEl.appendChild(catEl);

        li.appendChild(row);

        li.addEventListener('mouseenter', function () { setActive(i); });
        li.addEventListener('mouseleave', function () { setActive(-1); });
        li.addEventListener('mousedown', function (e) {
          e.preventDefault(); /* prevent blur before click */
          window.location.href = buildUrl(r.tool);
        });

        dropdown.appendChild(li);
      });

      /* "View all results" footer */
      var footer = document.createElement('li');
      footer.style.cssText = 'padding:0.4rem 0.75rem;font-size:0.8rem;color:#6b7280;cursor:pointer;';
      footer.textContent = 'View all results for "' + q + '"';
      footer.addEventListener('mousedown', function (e) {
        e.preventDefault();
        window.location.href = TOOLS_URL + '?query=' + encodeURIComponent(q);
      });
      dropdown.appendChild(footer);

      dropdown.style.display = 'block';
    }

    /* ---- Event listeners ---- */
    input.addEventListener('input', function () {
      renderDropdown(input.value.trim());
    });

    input.addEventListener('keydown', function (e) {
      var items = dropdown.querySelectorAll('li[role="option"]');
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        setActive(Math.min(activeIdx + 1, items.length - 1));
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        setActive(Math.max(activeIdx - 1, 0));
      } else if (e.key === 'Enter') {
        e.preventDefault();
        if (activeIdx >= 0 && items[activeIdx]) {
          items[activeIdx].dispatchEvent(new MouseEvent('mousedown'));
        } else {
          var q = input.value.trim();
          if (q) window.location.href = TOOLS_URL + '?query=' + encodeURIComponent(q);
        }
      } else if (e.key === 'Escape') {
        closeDropdown();
      }
    });

    input.addEventListener('blur', function () {
      /* Slight delay so mousedown on dropdown fires first */
      setTimeout(closeDropdown, 150);
    });

    document.addEventListener('click', function (e) {
      if (!wrapper.contains(e.target)) closeDropdown();
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

})();
