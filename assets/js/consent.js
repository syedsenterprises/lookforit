/* LookForIt cookie consent — gates Ezoic advertising until the visitor accepts.
   Choice stored in localStorage as 'lookforit-consent': 'accepted' | 'declined'.
   No advertising script loads before Accept. Essential site features work either way. */
(function () {
  var KEY = 'lookforit-consent';
  function choice() { try { return localStorage.getItem(KEY); } catch (e) { return null; } }
  function loadEzoic() {
    if (window.__lfEzoicLoaded) return;
    window.__lfEzoicLoaded = true;
    window.ezstandalone = window.ezstandalone || {};
    window.ezstandalone.cmd = window.ezstandalone.cmd || [];
    var s = document.createElement('script');
    s.async = true;
    s.src = 'https://www.ezojs.com/ezoic/sa.min.js';
    document.head.appendChild(s);
  }
  function banner() { return document.getElementById('lf-consent'); }
  function hideBanner() { var b = banner(); if (b) b.style.display = 'none'; }
  function showBanner() { var b = banner(); if (b) b.style.display = 'flex'; }
  function accept() {
    try { localStorage.setItem(KEY, 'accepted'); } catch (e) {}
    hideBanner(); loadEzoic();
  }
  function decline() {
    try { localStorage.setItem(KEY, 'declined'); } catch (e) {}
    hideBanner();
  }
  function init() {
    var c = choice();
    if (c === 'accepted') { loadEzoic(); return; }
    if (c === 'declined') { return; }
    showBanner();
    var a = document.getElementById('lf-consent-accept');
    var d = document.getElementById('lf-consent-decline');
    if (a) a.addEventListener('click', accept);
    if (d) d.addEventListener('click', decline);
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
