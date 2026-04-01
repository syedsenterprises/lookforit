(function() {
  "use strict";

  var memoryStore = {};

  var defaults = {
    enabled: true,
    adsense: {
      enabled: false,
      publisherId: "",
      autoAds: false,
      articleSlots: { aboveFold: "", midContent: "", endContent: "" },
      toolSlots: { aboveFold: "", midContent: "", endContent: "" }
    },
    tracking: {
      outboundClicks: true,
      ctaClicks: true,
      affiliateClicks: true,
      scrollDepth: true,
      engagement: true
    },
    utm: {
      source: "lookforit",
      medium: "affiliate",
      campaignByPageType: {
        tool: "toolpage",
        article: "article",
        default: "site"
      },
      contentMap: {
        stickybar: "stickybar",
        inline: "inlinecta",
        pricing_table: "pricingtable",
        popup: "popupcta",
        sidebar: "sidebarcta"
      }
    },
    affiliate: {
      autoMarkExternalAsSponsored: true,
      fallbackUrl: "/tools/",
      domains: [],
      routing: {
        "default": {
          keywords: [],
          urgency: "Free trial available",
          stickyText: "Compare top tools and choose faster",
          offers: [{ name: "Top Tools", network: "internal", url: "/tools/" }]
        }
      }
    },
    leadMagnet: {
      enabled: true,
      title: "Get weekly AI workflow checklists",
      description: "Get templates, prompts, and practical workflows every week.",
      ctaText: "Get Checklist",
      targetUrl: "/contact.html"
    },
    leadScoring: {
      popupSubmit: 10,
      affiliateClick: 5,
      pricingTableClick: 7,
      returnVisit: 3,
      scroll90: 2
    },
    comparisonData: {}
  };

  function mergeDeep(target, source) {
    var output = target || {};
    var src = source || {};
    Object.keys(src).forEach(function(key) {
      var srcVal = src[key];
      var tgtVal = output[key];
      if (srcVal && typeof srcVal === "object" && !Array.isArray(srcVal)) {
        output[key] = mergeDeep(tgtVal && typeof tgtVal === "object" ? tgtVal : {}, srcVal);
      } else {
        output[key] = srcVal;
      }
    });
    return output;
  }

  var config = mergeDeep(mergeDeep({}, defaults), window.LookforitMonetization || {});
  if (config.enabled === false) {
    return;
  }

  function storageGet(key, fallback) {
    try {
      var raw = localStorage.getItem(key);
      if (raw === null || typeof raw === "undefined") {
        return typeof fallback === "undefined" ? null : fallback;
      }
      return JSON.parse(raw);
    } catch (_e) {
      if (typeof memoryStore[key] !== "undefined") {
        return memoryStore[key];
      }
      return typeof fallback === "undefined" ? null : fallback;
    }
  }

  function storageSet(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value));
    } catch (_e) {
      memoryStore[key] = value;
    }
  }

  var eventsKey = "lookforit_monetization_events";
  var historyKey = "lookforit_monetization_history";
  var leadsKey = "lookforit_monetization_leads";
  var leadProfileKey = "lookforit_lead_profile";
  var visitKey = "lookforit_visit_count";

  var path = (window.location.pathname || "").toLowerCase();
  var title = String(document.title || "");
  var isArticlePage = path.indexOf("/articles/") === 0 && path !== "/articles/" && path !== "/articles/index.html";
  var isToolsIndex = path === "/tools/" || path === "/tools" || path === "/tools/index.html";
  var isToolDetail = path.indexOf("/tools/") === 0 && !isToolsIndex && path.indexOf("/tools/category/") !== 0;
  var isWebTools = path.indexOf("/web-tools/") === 0;

  var pageType = isArticlePage ? "article" : (isToolDetail || isToolsIndex ? "tool" : "default");
  var seenEvents = {};

  function detectDeviceType() {
    var ua = (navigator.userAgent || "").toLowerCase();
    if (ua.indexOf("mobile") !== -1) return "mobile";
    if (ua.indexOf("tablet") !== -1 || ua.indexOf("ipad") !== -1) return "tablet";
    return "desktop";
  }

  function maskEmail(email) {
    var parts = String(email || "").split("@");
    if (parts.length !== 2) return "";
    var n = parts[0];
    var d = parts[1];
    if (n.length <= 2) return "**@" + d;
    return n.slice(0, 2) + "***@" + d;
  }

  function getCategorySignals() {
    var signals = [];
    var body = document.body;
    if (body && body.getAttribute("data-category")) {
      signals.push(body.getAttribute("data-category"));
    }

    var main = document.querySelector("#main[data-category], section[data-category], article[data-category]");
    if (main && main.getAttribute("data-category")) {
      signals.push(main.getAttribute("data-category"));
    }

    signals.push(path);
    signals.push(title);

    var metaKeywords = document.querySelector("meta[name='keywords']");
    if (metaKeywords && metaKeywords.getAttribute("content")) {
      signals.push(metaKeywords.getAttribute("content"));
    }

    var tags = document.querySelectorAll("[data-tag], .tag, .tags a, .tool-tag");
    for (var i = 0; i < tags.length; i++) {
      var t = tags[i];
      var txt = (t.getAttribute("data-tag") || t.textContent || "").trim();
      if (txt) signals.push(txt);
    }

    return signals.join(" ").toLowerCase();
  }

  function detectCategory() {
    var routing = config.affiliate && config.affiliate.routing ? config.affiliate.routing : {};
    var signals = getCategorySignals();
    var keys = Object.keys(routing).filter(function(k) { return k !== "default"; });

    for (var i = 0; i < keys.length; i++) {
      var cat = keys[i];
      var def = routing[cat] || {};
      var kws = def.keywords || [];
      for (var j = 0; j < kws.length; j++) {
        var kw = String(kws[j] || "").toLowerCase();
        if (kw && signals.indexOf(kw) !== -1) {
          return { category: cat, keyword: kw };
        }
      }
    }

    if (isWebTools) return { category: "productivity", keyword: "web-tools" };
    return { category: "default", keyword: "fallback" };
  }

  var detected = detectCategory();
  var currentCategory = detected.category;

  function currentCategoryConfig() {
    var routing = config.affiliate && config.affiliate.routing ? config.affiliate.routing : {};
    return routing[currentCategory] || routing["default"] || { offers: [] };
  }

  function getPrimaryOffer() {
    var catCfg = currentCategoryConfig();
    var offers = catCfg.offers || [];
    if (offers.length > 0) return offers[0];
    return { name: "Top Tools", network: "internal", url: config.affiliate.fallbackUrl || "/tools/" };
  }

  function isExternalUrl(url) {
    if (!url) return false;
    try {
      var u = new URL(url, window.location.origin);
      return u.origin !== window.location.origin;
    } catch (_e) {
      return false;
    }
  }

  function appendUTM(rawUrl, sourceName) {
    if (!rawUrl) return rawUrl;
    try {
      var parsed = new URL(rawUrl, window.location.origin);
      if (parsed.origin === window.location.origin && parsed.pathname.indexOf("/tools/") !== 0) {
        return parsed.toString();
      }

      if (!parsed.searchParams.get("utm_source")) parsed.searchParams.set("utm_source", config.utm.source || "lookforit");
      if (!parsed.searchParams.get("utm_medium")) parsed.searchParams.set("utm_medium", config.utm.medium || "affiliate");

      var campaignMap = (config.utm && config.utm.campaignByPageType) || {};
      var campaign = campaignMap[pageType] || campaignMap.default || "site";
      if (!parsed.searchParams.get("utm_campaign")) parsed.searchParams.set("utm_campaign", campaign);

      var contentMap = (config.utm && config.utm.contentMap) || {};
      var content = contentMap[sourceName] || contentMap.inline || "inlinecta";
      if (!parsed.searchParams.get("utm_content")) parsed.searchParams.set("utm_content", content);

      return parsed.toString();
    } catch (_e) {
      return rawUrl;
    }
  }

  function getLeadProfile() {
    return storageGet(leadProfileKey, {
      score: 0,
      tags: [],
      lastUpdated: new Date().toISOString(),
      history: []
    });
  }

  function tagForCategory(category) {
    var map = {
      "seo": "seo",
      "default": "ai-tools",
      "resume": "resume",
      "hosting": "hosting",
      "productivity": "productivity",
      "ai-writing": "blogging",
      "ai-image": "ai-tools",
      "video": "ai-tools",
      "developer": "ai-tools",
      "design": "ai-tools"
    };
    return map[category] || "ai-tools";
  }

  function updateLeadScore(points, reason) {
    var profile = getLeadProfile();
    profile.score = (profile.score || 0) + (points || 0);
    profile.lastUpdated = new Date().toISOString();
    profile.history = profile.history || [];
    profile.history.push({ at: profile.lastUpdated, reason: reason || "event", points: points || 0, category: currentCategory });
    if (profile.history.length > 300) profile.history = profile.history.slice(profile.history.length - 300);

    var tg = tagForCategory(currentCategory);
    profile.tags = profile.tags || [];
    if (profile.tags.indexOf(tg) === -1) profile.tags.push(tg);
    storageSet(leadProfileKey, profile);
  }

  function rememberEvent(name, payload) {
    var events = storageGet(eventsKey, []);
    events.push({
      name: name,
      at: new Date().toISOString(),
      path: window.location.pathname,
      payload: payload || {}
    });
    if (events.length > 2000) events = events.slice(events.length - 2000);
    storageSet(eventsKey, events);

    var history = storageGet(historyKey, []);
    history.push({ name: name, at: new Date().toISOString() });
    if (history.length > 500) history = history.slice(history.length - 500);
    storageSet(historyKey, history);
  }

  function emitEvent(name, payload, options) {
    var meta = payload || {};
    var base = {
      page_url: window.location.href,
      page_path: window.location.pathname,
      page_title: title,
      category: currentCategory,
      device_type: detectDeviceType(),
      timestamp: new Date().toISOString(),
      cta_source: meta.cta_source || "",
      affiliate_network: meta.affiliate_network || ""
    };

    var finalPayload = mergeDeep(base, meta);
    var dedupeKey = (options && options.onceKey) || "";
    if (dedupeKey) {
      if (seenEvents[dedupeKey]) return;
      seenEvents[dedupeKey] = true;
    }

    if (typeof window.gtag === "function") {
      try { window.gtag("event", name, finalPayload); } catch (_e) {}
    }

    rememberEvent(name, finalPayload);
  }

  function saveLead(input) {
    var lead = input || {};
    var leads = storageGet(leadsKey, []);
    var category = lead.category || currentCategory;
    var tags = [tagForCategory(category)];

    leads.push({
      email: lead.email || "",
      email_masked: maskEmail(lead.email || ""),
      category: category,
      page_url: window.location.href,
      referral_source: document.referrer || "direct",
      timestamp: new Date().toISOString(),
      source: lead.source || "lead_magnet",
      tags: tags,
      score_at_capture: getLeadProfile().score || 0
    });

    if (leads.length > 700) leads = leads.slice(leads.length - 700);
    storageSet(leadsKey, leads);
  }

  function bindMonetizedLink(link, sourceName) {
    if (!link || link.getAttribute("data-monetized-bound") === "1") return;
    link.setAttribute("data-monetized-bound", "1");

    var ctaSource = sourceName || link.getAttribute("data-cta-source") || "inline";
    var href = (link.getAttribute("href") || "").trim();
    var offer = getPrimaryOffer();

    if (!href || href === "#") {
      href = offer.url || config.affiliate.fallbackUrl || "/tools/";
    }

    href = appendUTM(href, ctaSource);
    link.setAttribute("href", href);

    if (isExternalUrl(href)) {
      link.setAttribute("target", "_blank");
      link.setAttribute("rel", "nofollow sponsored noopener noreferrer");
    }

    link.addEventListener("click", function() {
      var eventName = "affiliate_click";
      if (ctaSource === "stickybar") eventName = "sticky_bar_click";
      if (ctaSource === "pricing_table") eventName = "pricing_table_click";
      if (ctaSource === "popup") eventName = "popup_submit";

      emitEvent(eventName, {
        cta_source: ctaSource,
        affiliate_network: offer.network || link.getAttribute("data-affiliate-network") || "direct",
        destination: href
      });

      if (eventName === "pricing_table_click") {
        updateLeadScore(config.leadScoring.pricingTableClick || 7, "pricing_table_click");
      } else {
        updateLeadScore(config.leadScoring.affiliateClick || 5, eventName);
      }
    });
  }

  function routeAffiliateLinks() {
    var targets = document.querySelectorAll("a[data-monetization='affiliate-cta'], a[data-affiliate='1'], .affiliate-cta a");
    for (var i = 0; i < targets.length; i++) {
      var a = targets[i];
      var source = a.getAttribute("data-cta-source") || (a.closest(".lookforit-revenue-bar") ? "stickybar" : "inline");
      bindMonetizedLink(a, source);
    }
  }

  function attachOutboundTracking() {
    if (!config.tracking || config.tracking.outboundClicks === false) return;
    document.addEventListener("click", function(event) {
      var a = event.target && event.target.closest ? event.target.closest("a[href]") : null;
      if (!a) return;
      var href = a.getAttribute("href") || "";
      if (!isExternalUrl(href)) return;

      emitEvent("outbound_click", {
        destination: href,
        cta_source: a.getAttribute("data-cta-source") || "general",
        affiliate_network: a.getAttribute("data-affiliate-network") || ""
      });
    }, true);
  }

  function markAffiliateRels() {
    if (!config.affiliate || config.affiliate.autoMarkExternalAsSponsored !== true) return;
    var anchors = document.querySelectorAll("a[href]");
    for (var i = 0; i < anchors.length; i++) {
      var a = anchors[i];
      var href = (a.getAttribute("href") || "").toLowerCase();
      if (!isExternalUrl(href)) continue;

      var rel = (a.getAttribute("rel") || "").toLowerCase();
      var tokens = rel ? rel.split(/\s+/) : [];
      ["nofollow", "sponsored", "noopener", "noreferrer"].forEach(function(token) {
        if (tokens.indexOf(token) === -1) tokens.push(token);
      });
      a.setAttribute("rel", tokens.join(" ").trim());
    }
  }

  function injectAdsenseScript() {
    if (!config.adsense || config.adsense.enabled !== true) return;
    var publisherId = (config.adsense.publisherId || "").trim();
    if (!publisherId) return;
    if (document.querySelector("script[data-lookforit-adsense='1']")) return;

    var adScript = document.createElement("script");
    adScript.async = true;
    adScript.src = "https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=" + encodeURIComponent(publisherId);
    adScript.crossOrigin = "anonymous";
    adScript.setAttribute("data-lookforit-adsense", "1");
    document.head.appendChild(adScript);
  }

  function insertAdSlotAt(target, slotId) {
    if (!target || !slotId) return;
    if (document.querySelector('.lookforit-ad-unit[data-slot="' + slotId + '"]')) return;

    var wrap = document.createElement("section");
    wrap.className = "lookforit-ad-unit";
    wrap.setAttribute("data-slot", slotId);
    wrap.innerHTML =
      '<header class="major"><h3>Sponsored</h3></header>' +
      '<ins class="adsbygoogle" style="display:block" data-ad-client="' +
      String(config.adsense.publisherId || "") +
      '" data-ad-slot="' + String(slotId) +
      '" data-ad-format="auto" data-full-width-responsive="true"></ins>';

    target.parentNode.insertBefore(wrap, target);
    try { (window.adsbygoogle = window.adsbygoogle || []).push({}); } catch (_e) {}
  }

  function injectAdSlots() {
    if (!config.adsense || config.adsense.enabled !== true) return;

    var articleSlots = config.adsense.articleSlots || {};
    var toolSlots = config.adsense.toolSlots || {};

    if (isArticlePage) {
      var h1a = document.querySelector("#main h1");
      var h2a = document.querySelector("#main h2");
      if (h1a && articleSlots.aboveFold) insertAdSlotAt(h1a, articleSlots.aboveFold);
      if (h2a && articleSlots.midContent) insertAdSlotAt(h2a, articleSlots.midContent);
      if (articleSlots.endContent) {
        var endHost = document.querySelector("#main .inner");
        if (endHost) {
          var tail = document.createElement("div");
          tail.className = "lookforit-ad-tail";
          endHost.appendChild(tail);
          insertAdSlotAt(tail, articleSlots.endContent);
        }
      }
    }

    if (isToolDetail || isToolsIndex) {
      var h1t = document.querySelector("#main h1");
      var h2t = document.querySelector("#main h2");
      if (h1t && toolSlots.aboveFold) insertAdSlotAt(h1t, toolSlots.aboveFold);
      if (h2t && toolSlots.midContent) insertAdSlotAt(h2t, toolSlots.midContent);
      if (toolSlots.endContent) {
        var tHost = document.querySelector("#main .inner");
        if (tHost) {
          var tTail = document.createElement("div");
          tTail.className = "lookforit-ad-tail";
          tHost.appendChild(tTail);
          insertAdSlotAt(tTail, toolSlots.endContent);
        }
      }
    }
  }

  function injectComparisonTable() {
    if (!(isArticlePage || isToolDetail)) return;

    var highIntent = ["seo", "resume", "hosting", "ai-writing", "ai-image"];
    if (highIntent.indexOf(currentCategory) === -1) return;
    if (document.querySelector(".lookforit-compare-section")) return;

    var rows = config.comparisonData[currentCategory] || [];
    if (!rows.length) return;

    var host = document.querySelector("#main .inner");
    if (!host) return;

    var section = document.createElement("section");
    section.className = "lookforit-compare-section";

    var html = '';
    html += '<header class="major"><h2>Compare top ' + currentCategory.replace("-", " ") + ' tools</h2></header>';
    html += '<div class="lookforit-compare-wrap"><table class="lookforit-compare-table">';
    html += '<thead><tr><th>Tool name</th><th>Best for</th><th>Free plan</th><th>Starting price</th><th>Key features</th><th>CTA</th></tr></thead><tbody>';

    for (var i = 0; i < rows.length; i++) {
      var r = rows[i];
      var offerUrl = (getPrimaryOffer().url || config.affiliate.fallbackUrl || "/tools/");
      var ctaUrl = appendUTM(offerUrl, "pricing_table");
      html += '<tr>' +
        '<td>' + r.tool + '</td>' +
        '<td>' + r.bestFor + '</td>' +
        '<td>' + r.freePlan + '</td>' +
        '<td>' + r.startPrice + '</td>' +
        '<td>' + r.keyFeatures + '</td>' +
        '<td><a class="button small" data-monetization="affiliate-cta" data-cta-source="pricing_table" href="' + ctaUrl + '">View deal</a></td>' +
        '</tr>';
    }

    html += '</tbody></table></div>';
    section.innerHTML = html;
    host.appendChild(section);
  }

  function injectLeadMagnet() {
    if (!config.leadMagnet || config.leadMagnet.enabled === false) return;
    if (!isArticlePage) return;
    if (document.querySelector(".lookforit-lead-magnet")) return;

    var host = document.querySelector("#main .inner");
    if (!host) return;

    var wrapper = document.createElement("section");
    wrapper.className = "lookforit-lead-magnet";
    wrapper.innerHTML =
      '<header class="major"><h2>' + String(config.leadMagnet.title || "Get weekly AI workflow checklists") + '</h2></header>' +
      '<p>' + String(config.leadMagnet.description || "Get templates, prompts, and practical workflows every week.") + '</p>' +
      '<form id="lookforit-lead-form" class="row gtr-uniform" novalidate>' +
      '<div class="col-8 col-12-small"><input type="email" id="lookforit-lead-email" placeholder="Your email" required /></div>' +
      '<div class="col-4 col-12-small"><button type="submit" class="button primary fit">' + String(config.leadMagnet.ctaText || "Get Checklist") + '</button></div>' +
      '</form>' +
      '<p id="lookforit-lead-status" style="margin-top:0.6rem;"></p>';

    host.appendChild(wrapper);

    var form = document.getElementById("lookforit-lead-form");
    var emailInput = document.getElementById("lookforit-lead-email");
    var status = document.getElementById("lookforit-lead-status");
    if (!form) return;

    form.addEventListener("submit", function(event) {
      event.preventDefault();
      var email = String(emailInput && emailInput.value || "").trim();
      if (!email || email.indexOf("@") === -1) {
        if (status) status.textContent = "Enter a valid email to continue.";
        return;
      }

      saveLead({ email: email, source: "inline" });
      emitEvent("lead_capture", { cta_source: "inline", email_masked: maskEmail(email) });
      updateLeadScore(config.leadScoring.popupSubmit || 10, "inline_lead_capture");

      if (status) status.textContent = "Saved. Opening checklist page...";
      setTimeout(function() {
        window.location.href = String(config.leadMagnet.targetUrl || "/contact.html");
      }, 300);
    });
  }

  function injectStickyRevenueBar() {
    if (!(isArticlePage || isToolDetail || isToolsIndex)) return;
    if (document.querySelector(".lookforit-revenue-bar")) return;

    var dismissKey = "lookforit_revenue_bar_dismissed_at";
    var dismissedAt = storageGet(dismissKey, 0) || 0;
    var cooldownMs = 1000 * 60 * 60 * 18;
    if (dismissedAt && (Date.now() - dismissedAt) < cooldownMs) return;

    var catCfg = currentCategoryConfig();
    var offer = getPrimaryOffer();
    var ctaUrl = appendUTM(offer.url || config.affiliate.fallbackUrl || "/tools/", "stickybar");

    var bar = document.createElement("div");
    bar.className = "lookforit-revenue-bar";
    bar.innerHTML =
      '<button type="button" class="rb-close" aria-label="Close">x</button>' +
      '<span class="rb-copy">' + String(catCfg.stickyText || "Compare top tools and choose faster") + '</span>' +
      '<span class="rb-urgency">' + String(catCfg.urgency || "Free trial available") + '</span>' +
      '<a class="button primary small" data-monetization="affiliate-cta" data-cta-source="stickybar" href="' + ctaUrl + '">Check Pricing</a>' +
      '<a class="button small" href="/listing-requests/" data-cta-source="sidebar">Submit Your Tool</a>';

    document.body.appendChild(bar);

    var closeBtn = bar.querySelector(".rb-close");
    if (closeBtn) {
      closeBtn.addEventListener("click", function() {
        storageSet(dismissKey, Date.now());
        bar.remove();
        emitEvent("sticky_bar_close", { cta_source: "stickybar" });
      });
    }
  }

  function injectExitPopup() {
    if (!(isArticlePage || isToolDetail)) return;
    var popupSeenKey = "lookforit_exit_popup_seen_at";
    var seenAt = storageGet(popupSeenKey, 0) || 0;
    if (seenAt && (Date.now() - seenAt) < (1000 * 60 * 60 * 24)) return;

    var shown = false;
    document.addEventListener("mouseout", function(event) {
      if (shown) return;
      if (!event || event.clientY > 10) return;

      shown = true;
      storageSet(popupSeenKey, Date.now());

      var overlay = document.createElement("div");
      overlay.className = "lookforit-exit-overlay";
      overlay.innerHTML =
        '<div class="lookforit-exit-modal">' +
        '<button type="button" class="exit-close" aria-label="Close">x</button>' +
        '<h3>Get the AI Tool Selection Checklist</h3>' +
        '<p>Save time and choose the right tools with a simple free checklist.</p>' +
        '<form id="lookforit-exit-form" novalidate>' +
        '<input type="email" id="lookforit-exit-email" placeholder="Your email" required />' +
        '<button type="submit" class="button primary" data-monetization="affiliate-cta" data-cta-source="popup">Send Checklist</button>' +
        '</form>' +
        '<p id="lookforit-exit-status"></p>' +
        '</div>';

      document.body.appendChild(overlay);
      emitEvent("popup_view", { cta_source: "popup" });

      var closeBtn = overlay.querySelector(".exit-close");
      if (closeBtn) {
        closeBtn.addEventListener("click", function() {
          overlay.remove();
          emitEvent("popup_close", { cta_source: "popup" });
        });
      }

      var form = overlay.querySelector("#lookforit-exit-form");
      var emailInput = overlay.querySelector("#lookforit-exit-email");
      var status = overlay.querySelector("#lookforit-exit-status");

      if (form) {
        form.addEventListener("submit", function(e) {
          e.preventDefault();
          var email = String(emailInput && emailInput.value || "").trim();
          if (!email || email.indexOf("@") === -1) {
            if (status) status.textContent = "Enter a valid email.";
            return;
          }

          saveLead({ email: email, source: "popup" });
          emitEvent("popup_submit", { cta_source: "popup", email_masked: maskEmail(email) });
          emitEvent("lead_capture", { cta_source: "popup", email_masked: maskEmail(email) });
          updateLeadScore(config.leadScoring.popupSubmit || 10, "popup_submit");

          if (status) status.textContent = "Saved. Opening checklist page...";
          setTimeout(function() {
            window.location.href = String(config.leadMagnet && config.leadMagnet.targetUrl || "/contact.html");
          }, 350);
        });
      }
    });
  }

  function trackScrollDepth() {
    if (!config.tracking || config.tracking.scrollDepth === false) return;
    var fired50 = false;
    var fired90 = false;

    function onScroll() {
      var doc = document.documentElement;
      var scrollTop = (window.pageYOffset || doc.scrollTop || 0);
      var maxScroll = Math.max(1, (doc.scrollHeight - window.innerHeight));
      var pct = (scrollTop / maxScroll) * 100;

      if (!fired50 && pct >= 50) {
        fired50 = true;
        emitEvent("scroll_50", { cta_source: "engagement" }, { onceKey: "scroll50" });
      }

      if (!fired90 && pct >= 90) {
        fired90 = true;
        emitEvent("scroll_90", { cta_source: "engagement" }, { onceKey: "scroll90" });
        updateLeadScore(config.leadScoring.scroll90 || 2, "scroll_90");
      }
    }

    window.addEventListener("scroll", onScroll, { passive: true });
    onScroll();
  }

  function trackTimeMilestones() {
    if (!config.tracking || config.tracking.engagement === false) return;
    setTimeout(function() { emitEvent("time_on_page_30", { cta_source: "engagement" }, { onceKey: "t30" }); }, 30000);
    setTimeout(function() { emitEvent("time_on_page_60", { cta_source: "engagement" }, { onceKey: "t60" }); }, 60000);
    setTimeout(function() { emitEvent("time_on_page_120", { cta_source: "engagement" }, { onceKey: "t120" }); }, 120000);
  }

  function trackReturningVisitor() {
    var visits = storageGet(visitKey, 0) || 0;
    visits += 1;
    storageSet(visitKey, visits);

    if (visits > 1) {
      emitEvent("returning_visitor", { cta_source: "engagement", visits: visits }, { onceKey: "returningVisitor" });
      updateLeadScore(config.leadScoring.returnVisit || 3, "returning_visitor");
    }
  }

  function fireCategoryView() {
    emitEvent("tool_category_view", {
      cta_source: "view",
      category_keyword: detected.keyword
    }, { onceKey: "categoryView" });
  }

  function safeInit() {
    try {
      injectAdsenseScript();
      injectAdSlots();
      injectComparisonTable();
      injectLeadMagnet();
      injectStickyRevenueBar();
      injectExitPopup();
      routeAffiliateLinks();
      attachOutboundTracking();
      markAffiliateRels();
      trackScrollDepth();
      trackTimeMilestones();
      trackReturningVisitor();
      fireCategoryView();
    } catch (_e) {
      // Keep page usable even if monetization module fails.
    }
  }

  safeInit();
})();
