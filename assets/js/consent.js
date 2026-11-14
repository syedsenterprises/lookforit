/* LookForIt cookie consent — gates Ezoic advertising and Google Analytics until the visitor accepts.
   Choice stored in localStorage as 'lookforit-consent': 'accepted' | 'declined'.
   No advertising or analytics script loads before Accept. Essential site features work either way. */
(function () {
  window.__lfConsentHandled = true;
  var KEY = 'lookforit-consent';
  var GA_ID = 'G-WKN1GKE1SJ';
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
  function loadGA(granted) {
    if (window.__lfGALoaded) return;
    window.__lfGALoaded = true;
    window.dataLayer = window.dataLayer || [];
    window.gtag = window.gtag || function () { window.dataLayer.push(arguments); };
    window.gtag('consent', 'default', { analytics_storage: granted ? 'granted' : 'denied', ad_storage: 'denied' });
    var s = document.createElement('script');
    s.async = true;
    s.src = 'https://www.googletagmanager.com/gtag/js?id=' + GA_ID;
    document.head.appendChild(s);
    window.gtag('js', new Date());
    window.gtag('config', GA_ID);
  }
  function grantGA() {
    if (window.gtag) window.gtag('consent', 'update', { analytics_storage: 'granted' });
  }
  function banner() { return document.getElementById('lf-consent'); }
  function hideBanner() { var b = banner(); if (b) b.style.display = 'none'; }
  function showBanner() { var b = banner(); if (b) b.style.display = 'flex'; }
  function accept() {
    try { localStorage.setItem(KEY, 'accepted'); } catch (e) {}
    hideBanner(); loadEzoic(); loadGA(false); grantGA();
  }
  function decline() {
    try { localStorage.setItem(KEY, 'declined'); } catch (e) {}
    hideBanner();
  }
  function init() {
    var c = choice();
    if (c === 'accepted') { loadEzoic(); loadGA(true); return; }
    if (c === 'declined') { return; }
    var b = banner();
    if (b) {
      var p = b.querySelector('p');
      if (p) p.innerHTML = 'This site uses cookies for ads (Ezoic) and analytics (Google Analytics). Accept to load them, or decline and browse without them. See our <a href="/privacy-policy.html" style="color:#7dd3fc">Privacy Policy</a>.';
    }
    showBanner();
    var a = document.getElementById('lf-consent-accept');
    var d = document.getElementById('lf-consent-decline');
    if (a) a.addEventListener('click', accept);
    if (d) d.addEventListener('click', decline);
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
