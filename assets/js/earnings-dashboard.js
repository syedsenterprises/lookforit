(function () {
  "use strict";

  var LOCAL_KEY = "lookforit_monetization_events";
  var LEAD_EVENT_SET = {
    lead_magnet_submit: true,
    exit_popup_submit: true
  };

  function getEvents() {
    try {
      var raw = localStorage.getItem(LOCAL_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch (_e) {
      return [];
    }
  }

  function setEvents(events) {
    localStorage.setItem(LOCAL_KEY, JSON.stringify(events || []));
  }

  function toNumber(value) {
    var num = Number(value);
    return Number.isFinite(num) ? num : 0;
  }

  function pct(numerator, denominator) {
    if (!denominator) return "0%";
    return (Math.round((numerator / denominator) * 1000) / 10) + "%";
  }

  function weekKey(isoDate) {
    var d = new Date(isoDate || Date.now());
    if (isNaN(d.getTime())) return "Unknown";
    var first = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    var day = Math.floor((d - first) / 86400000);
    var week = Math.ceil((day + first.getUTCDay() + 1) / 7);
    return d.getUTCFullYear() + "-W" + String(week).padStart(2, "0");
  }

  function getProp(event, key, fallback) {
    var props = event && event.props ? event.props : {};
    return props[key] != null ? props[key] : fallback;
  }

  function fillKpi(id, value) {
    var el = document.getElementById(id);
    if (el) el.textContent = String(value);
  }

  function renderMiniBars(hostId, items, valueSuffix) {
    var host = document.getElementById(hostId);
    if (!host) return;
    if (!items.length) {
      host.innerHTML = "<p>No data yet.</p>";
      return;
    }

    var max = items.reduce(function (m, it) { return Math.max(m, it.value); }, 0) || 1;
    var html = "";
    items.forEach(function (it) {
      var width = Math.max(4, Math.round((it.value / max) * 100));
      html +=
        "<div class=\"mini-bar-row\">" +
        "<div>" + it.label + "</div>" +
        "<div class=\"mini-bar-track\"><div class=\"mini-bar-fill\" style=\"width:" + width + "%\"></div></div>" +
        "<div>" + it.value + (valueSuffix || "") + "</div>" +
        "</div>";
    });
    host.innerHTML = html;
  }

  function topN(map, n) {
    return Object.keys(map)
      .map(function (key) { return { label: key, value: map[key] }; })
      .sort(function (a, b) { return b.value - a.value; })
      .slice(0, n || 6);
  }

  function renderLocalMetrics() {
    var host = document.getElementById("localMetrics");
    if (!host) return;

    var events = getEvents();
    var outbound = events.filter(function (e) { return e.name === "outbound_click"; }).length;
    var affiliate = events.filter(function (e) { return e.name === "affiliate_click"; }).length;
    var cta = events.filter(function (e) { return e.name === "cta_click"; }).length;
    var leads = events.filter(function (e) { return !!LEAD_EVENT_SET[e.name]; }).length;

    var stickyImpressions = events.filter(function (e) { return e.name === "sticky_bar_impression"; }).length;
    var stickyClicks = events.filter(function (e) { return e.name === "sticky_bar_click"; }).length;
    var popupViews = events.filter(function (e) { return e.name === "exit_popup_view"; }).length;
    var popupSubmits = events.filter(function (e) { return e.name === "exit_popup_submit"; }).length;
    var pricingImpressions = events.filter(function (e) { return e.name === "comparison_table_impression"; }).length;
    var pricingClicks = events.filter(function (e) { return e.name === "comparison_table_click" || e.name === "pricing_click"; }).length;

    var byPage = {};
    var byCategory = {};
    var byPlacement = {};
    var byDestination = {};
    var leadsByWeek = {};
    var returnVisitorEvents = 0;
    events.forEach(function (e) {
      var key = e.path || "unknown";
      byPage[key] = (byPage[key] || 0) + 1;

      var category = String(getProp(e, "category", "uncategorized"));
      byCategory[category] = (byCategory[category] || 0) + 1;

      var placement = String(getProp(e, "placement", "general"));
      byPlacement[placement] = (byPlacement[placement] || 0) + 1;

      var destination = String(getProp(e, "destination_host", "unknown"));
      byDestination[destination] = (byDestination[destination] || 0) + 1;

      if (getProp(e, "return_visitor", false) === true) {
        returnVisitorEvents += 1;
      }

      if (LEAD_EVENT_SET[e.name]) {
        var wk = weekKey(e.ts);
        leadsByWeek[wk] = (leadsByWeek[wk] || 0) + 1;
      }
    });

    var topPages = Object.keys(byPage)
      .map(function (p) { return { page: p, count: byPage[p] }; })
      .sort(function (a, b) { return b.count - a.count; })
      .slice(0, 8);

    var topCategory = topN(byCategory, 1);
    var topPage = topPages[0] ? topPages[0].page : "-";

    fillKpi("kpiAffiliateClicks", affiliate);
    fillKpi("kpiTotalLeads", leads);
    fillKpi("kpiStickyCtr", pct(stickyClicks, stickyImpressions));
    fillKpi("kpiPopupRate", pct(popupSubmits, popupViews));
    fillKpi("kpiPricingCtr", pct(pricingClicks, pricingImpressions));
    fillKpi("kpiReturnRate", pct(returnVisitorEvents, events.length));
    fillKpi("kpiTopCategory", topCategory.length ? topCategory[0].label : "-");
    fillKpi("kpiTopPage", topPage);

    renderMiniBars("chartClicksByCategory", topN(byCategory, 8));
    renderMiniBars("chartLeadsByWeek", topN(leadsByWeek, 8));
    renderMiniBars("chartTopPlacements", topN(byPlacement, 6));
    renderMiniBars("chartTopDestinations", topN(byDestination, 6));

    var topHtml = "<ol>";
    topPages.forEach(function (p) {
      topHtml += "<li><strong>" + p.page + "</strong> - " + p.count + " events</li>";
    });
    topHtml += "</ol>";

    host.innerHTML =
      "<p><strong>Total tracked events:</strong> " + events.length + "</p>" +
      "<p><strong>Outbound clicks:</strong> " + outbound + "</p>" +
      "<p><strong>Affiliate clicks:</strong> " + affiliate + "</p>" +
      "<p><strong>CTA clicks:</strong> " + cta + "</p>" +
      "<p><strong>Lead captures:</strong> " + leads + "</p>" +
      "<h3 style=\"margin-top:0.8rem;\">Top converting pages</h3>" + topHtml;
  }

  function parseCsv(text) {
    var lines = (text || "").split(/\r?\n/).filter(Boolean);
    if (lines.length < 2) return [];

    var headers = lines[0].split(",").map(function (h) { return h.trim().replace(/^\"|\"$/g, ""); });
    var rows = [];
    for (var i = 1; i < lines.length; i++) {
      var cells = lines[i].split(",");
      if (cells.length !== headers.length) continue;
      var row = {};
      for (var j = 0; j < headers.length; j++) {
        row[headers[j]] = (cells[j] || "").trim().replace(/^\"|\"$/g, "");
      }
      rows.push(row);
    }
    return rows;
  }

  function renderGa4(rows) {
    var summary = document.getElementById("ga4Summary");
    var tableHost = document.getElementById("ga4TableHost");
    if (!summary || !tableHost) return;

    if (!rows.length) {
      summary.innerHTML = "<p>No rows parsed from CSV.</p>";
      tableHost.innerHTML = "";
      return;
    }

    summary.innerHTML = "<p><strong>Rows parsed:</strong> " + rows.length + "</p>";

    var totals = rows.reduce(function (acc, row) {
      var ec = toNumber(row.eventCount || row.EventCount || row.count);
      acc.events += ec;
      return acc;
    }, { events: 0 });
    summary.innerHTML += "<p><strong>Total event count column sum:</strong> " + totals.events + "</p>";

    var cols = Object.keys(rows[0]);
    var html = "<table><thead><tr>";
    cols.forEach(function (c) { html += "<th>" + c + "</th>"; });
    html += "</tr></thead><tbody>";

    rows.slice(0, 100).forEach(function (row) {
      html += "<tr>";
      cols.forEach(function (c) {
        html += "<td>" + (row[c] || "") + "</td>";
      });
      html += "</tr>";
    });

    html += "</tbody></table>";
    tableHost.innerHTML = html;
  }

  function bind() {
    var refreshBtn = document.getElementById("refreshLocalMetrics");
    var clearBtn = document.getElementById("clearLocalMetrics");
    var parseBtn = document.getElementById("parseGa4Csv");
    var fileInput = document.getElementById("ga4CsvFile");

    if (refreshBtn) {
      refreshBtn.addEventListener("click", renderLocalMetrics);
    }

    if (clearBtn) {
      clearBtn.addEventListener("click", function () {
        setEvents([]);
        renderLocalMetrics();
      });
    }

    if (parseBtn && fileInput) {
      parseBtn.addEventListener("click", function () {
        var file = fileInput.files && fileInput.files[0];
        if (!file) {
          renderGa4([]);
          return;
        }

        var reader = new FileReader();
        reader.onload = function () {
          var rows = parseCsv(String(reader.result || ""));
          renderGa4(rows);
        };
        reader.readAsText(file);
      });
    }

    renderLocalMetrics();
  }

  bind();
})();
