(function () {
  "use strict";

  var adapterRegistry = {};
  var autoSlugEnabled = true;
  var draftStoreKey = "lookforit.dashboard.v1";
  var snapshotStoreKey = "lookforit.dashboard.snapshots.v1";
  var dashboardAnalyticsKey = "lookforit.dashboard.analytics.v1";
  var exportChecklistThreshold = 10;

  function byId(id) {
    return document.getElementById(id);
  }

  function clampThreshold(value) {
    var n = parseInt(value, 10);
    if (isNaN(n)) {
      return 10;
    }
    if (n < 8) {
      return 8;
    }
    if (n > 12) {
      return 12;
    }
    return n;
  }

  function normalizeLine(text) {
    return (text || "").replace(/\r?\n/g, " ").replace(/\s+/g, " ").trim();
  }

  function splitLines(text) {
    return (text || "")
      .split(/\r?\n/)
      .map(function (line) {
        return line.trim();
      })
      .filter(function (line) {
        return line.length > 0;
      });
  }

  function splitCsv(text) {
    return (text || "")
      .split(",")
      .map(function (item) {
        return item.trim();
      })
      .filter(function (item) {
        return item.length > 0;
      });
  }

  function debounce(fn, wait) {
    var timer = null;
    return function () {
      var args = arguments;
      clearTimeout(timer);
      timer = setTimeout(function () {
        fn.apply(null, args);
      }, wait);
    };
  }

  function escapeHtml(text) {
    return (text || "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/\"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function slugify(title) {
    return (title || "")
      .toLowerCase()
      .replace(/[^a-z0-9\s-]/g, "")
      .trim()
      .replace(/\s+/g, "-")
      .replace(/-+/g, "-");
  }

  function toImagePath(imageFilename) {
    var clean = normalizeLine(imageFilename);
    if (!clean) {
      return "";
    }

    if (/^(\.\.\/|\/|https?:\/\/)/i.test(clean)) {
      return clean;
    }

    return "../Images/" + clean;
  }

  function parseLinkEntries(rawText) {
    return splitLines(rawText)
      .map(function (line) {
        var parts = line.split("|");
        if (parts.length < 2) {
          return null;
        }

        var label = normalizeLine(parts[0]);
        var href = normalizeLine(parts.slice(1).join("|"));
        if (!label || !href) {
          return null;
        }

        return {
          label: label,
          href: href
        };
      })
      .filter(function (entry) {
        return entry !== null;
      });
  }

  function convertInlineLinks(text) {
    var safe = escapeHtml(text);
    return safe.replace(/\[([^\]]+)\]\(([^\)]+)\)/g, function (_m, label, href) {
      return '<a href="' + href + '" target="_blank" rel="noopener noreferrer">' + label + "</a>";
    });
  }

  function buildSectionBlock(heading, body, bullets) {
    var lines = [];
    var cleanHeading = normalizeLine(heading);
    var cleanBody = normalizeLine(body);

    if (cleanHeading) {
      lines.push("## " + cleanHeading);
    }

    if (cleanBody) {
      lines.push(cleanBody);
    }

    splitLines(bullets).forEach(function (item) {
      lines.push("- " + item);
    });

    return lines.join("\n").trim();
  }

  function buildFaqBlock(faqItems) {
    var lines = ["## Frequently Asked Questions"];

    faqItems.forEach(function (item) {
      var q = normalizeLine(item.q);
      var a = normalizeLine(item.a);
      if (!q || !a) {
        return;
      }

      lines.push("### " + q);
      lines.push(a);
    });

    return lines.length > 1 ? lines.join("\n") : "";
  }

  function buildLinksBlock(title, rawLinks) {
    var entries = parseLinkEntries(rawLinks);
    if (entries.length === 0) {
      return "";
    }

    var lines = ["## " + normalizeLine(title)];
    entries.forEach(function (entry) {
      lines.push("- [" + entry.label + "](" + entry.href + ")");
    });

    return lines.join("\n");
  }

  function buildImageBlock(imageFilename, imageAlt) {
    var cleanFilename = normalizeLine(imageFilename);
    var cleanAlt = normalizeLine(imageAlt);

    if (!cleanFilename && !cleanAlt) {
      return "";
    }

    var lines = ["## Featured Image"];

    if (cleanFilename) {
      lines.push("- File: " + cleanFilename);
    }

    if (cleanAlt) {
      lines.push("- Alt text: " + cleanAlt);
    }

    return lines.join("\n");
  }

  function buildTagsBlock(tags, category) {
    var tagList = Array.isArray(tags) ? tags : splitCsv(tags);
    var cleanCategory = normalizeLine(category);

    if (tagList.length === 0 && !cleanCategory) {
      return "";
    }

    var lines = ["## SEO Metadata"];

    if (cleanCategory) {
      lines.push("- Category: " + cleanCategory);
    }

    if (tagList.length > 0) {
      lines.push("- Tags: " + tagList.join(", "));
    }

    return lines.join("\n");
  }

  function buildRelatedBlock(relatedLines) {
    return buildLinksBlock("Related Articles", relatedLines);
  }

  function readSection(number) {
    return {
      heading: byId("s" + number + "Heading").value,
      body: byId("s" + number + "Body").value,
      bullets: byId("s" + number + "Bullets").value
    };
  }

  function readDashboardState() {
    var title = normalizeLine(byId("title").value);
    var slugInput = normalizeLine(byId("slug").value);
    var imageFilename = normalizeLine(byId("imageFilename").value);

    return {
      title: title,
      slug: slugInput || slugify(title),
      description: normalizeLine(byId("description").value),
      publishedText: normalizeLine(byId("publishedText").value) || "Published March 2026",
      category: normalizeLine(byId("category").value),
      tags: splitCsv(byId("tags").value),
      imageFilename: imageFilename,
      imagePath: toImagePath(imageFilename),
      imageAlt: normalizeLine(byId("imageAlt").value),
      intro: normalizeLine(byId("intro").value),
      sections: [readSection(1), readSection(2), readSection(3), readSection(4), readSection(5)],
      faqItems: [
        { q: byId("faq1q").value, a: byId("faq1a").value },
        { q: byId("faq2q").value, a: byId("faq2a").value },
        { q: byId("faq3q").value, a: byId("faq3a").value }
      ],
      toolLinksRaw: byId("toolLinks").value,
      internalArticleLinksRaw: byId("internalArticleLinks").value,
      externalLinksRaw: byId("externalLinks").value,
      relatedLines: byId("relatedLinks").value
    };
  }

  function buildDraftText(state) {
    var blocks = [];

    var imageBlock = buildImageBlock(state.imageFilename, state.imageAlt);
    if (imageBlock) {
      blocks.push(imageBlock);
    }

    var tagsBlock = buildTagsBlock(state.tags, state.category);
    if (tagsBlock) {
      blocks.push(tagsBlock);
    }

    if (state.intro) {
      blocks.push(state.intro);
    }

    state.sections.forEach(function (section) {
      var sectionText = buildSectionBlock(section.heading, section.body, section.bullets);
      if (sectionText) {
        blocks.push(sectionText);
      }
    });

    var toolLinksBlock = buildLinksBlock("Tool Links", state.toolLinksRaw);
    if (toolLinksBlock) {
      blocks.push(toolLinksBlock);
    }

    var internalLinksBlock = buildLinksBlock("Internal Article Links", state.internalArticleLinksRaw);
    if (internalLinksBlock) {
      blocks.push(internalLinksBlock);
    }

    var externalLinksBlock = buildLinksBlock("External References", state.externalLinksRaw);
    if (externalLinksBlock) {
      blocks.push(externalLinksBlock);
    }

    var faqBlock = buildFaqBlock(state.faqItems);
    if (faqBlock) {
      blocks.push(faqBlock);
    }

    var relatedBlock = buildRelatedBlock(state.relatedLines);
    if (relatedBlock) {
      blocks.push(relatedBlock);
    }

    return blocks.join("\n\n").trim();
  }

  function buildScriptPayload(state, draftText) {
    var imagePath = state.imagePath || "../Images/pic07.svg";
    var imageAlt = state.imageAlt || "Article cover image";

    return {
      title: state.title,
      slug: state.slug,
      description: state.description,
      publishedText: state.publishedText,
      category: state.category,
      tags: state.tags,
      imageFilename: state.imageFilename,
      imagePath: imagePath,
      imageAlt: imageAlt,
      sections: state.sections,
      faqItems: state.faqItems,
      toolLinks: parseLinkEntries(state.toolLinksRaw),
      internalArticleLinks: parseLinkEntries(state.internalArticleLinksRaw),
      externalLinks: parseLinkEntries(state.externalLinksRaw),
      relatedLinks: parseLinkEntries(state.relatedLines),
      bodyText: draftText,
      commands: {
        generate: "powershell -ExecutionPolicy Bypass -File .\\create-article.ps1",
        suggestedArgs: [
          "-Title",
          state.title,
          "-Slug",
          state.slug,
          "-Description",
          state.description,
          "-BodyFile",
          ".\\article-draft-template.txt",
          "-ImagePath",
          imagePath,
          "-ImageAlt",
          imageAlt,
          "-PublishedText",
          state.publishedText
        ]
      }
    };
  }

  function quoteArg(value) {
    var text = String(value || "");
    return "'" + text.replace(/'/g, "''") + "'";
  }

  function buildGenerateCommand(payload) {
    var cmd = payload.commands.generate;
    var args = payload.commands.suggestedArgs || [];
    var parts = [cmd];

    for (var i = 0; i < args.length; i += 2) {
      var key = args[i];
      var value = args[i + 1];
      if (typeof key === "undefined") {
        continue;
      }

      if (typeof value === "undefined") {
        parts.push(key);
      } else {
        parts.push(key + " " + quoteArg(value));
      }
    }

    return parts.join(" ");
  }

  function validateLinks(rawText, expectedPrefix) {
    var invalid = [];
    splitLines(rawText).forEach(function (line) {
      var parts = line.split("|");
      if (parts.length < 2) {
        invalid.push(line);
        return;
      }

      var href = normalizeLine(parts.slice(1).join("|"));
      if (!href) {
        invalid.push(line);
        return;
      }

      if (expectedPrefix && href.indexOf(expectedPrefix) !== 0) {
        invalid.push(line);
      }
    });

    return invalid;
  }

  function getFilledSectionsCount(sections) {
    var count = 0;
    sections.forEach(function (section) {
      var hasHeading = normalizeLine(section.heading).length > 0;
      var hasBody = normalizeLine(section.body).length > 0;
      var hasBullets = splitLines(section.bullets).length > 0;
      if (hasHeading || hasBody || hasBullets) {
        count += 1;
      }
    });
    return count;
  }

  function buildValidationChecklist(state, draftText) {
    var checks = [];
    var slugOk = /^[a-z0-9-]+$/.test(state.slug || "");
    var descriptionLen = (state.description || "").length;
    var filledSections = getFilledSectionsCount(state.sections);
    var toolInvalid = validateLinks(state.toolLinksRaw, "../tools/");
    var internalInvalid = validateLinks(state.internalArticleLinksRaw, "../articles/");
    var externalInvalid = validateLinks(state.externalLinksRaw, "http");

    checks.push({ ok: state.title.length > 5, label: "Title is present and meaningful" });
    checks.push({ ok: slugOk, label: "Slug is valid (lowercase, numbers, hyphens)" });
    checks.push({ ok: descriptionLen >= 120, label: "Description length is SEO-friendly (120+ chars)" });
    checks.push({ ok: normalizeLine(state.intro).length > 80, label: "Intro paragraph is detailed" });
    checks.push({ ok: filledSections >= 3, label: "At least 3 sections are filled" });
    checks.push({ ok: normalizeLine(state.imageFilename).length > 0, label: "Image filename is provided" });
    checks.push({ ok: normalizeLine(state.imageAlt).length > 10, label: "Image alt text is descriptive" });
    checks.push({ ok: toolInvalid.length === 0, label: "Tool links match Label|../tools/slug.html" });
    checks.push({ ok: internalInvalid.length === 0, label: "Internal links match Label|../articles/slug.html" });
    checks.push({ ok: externalInvalid.length === 0, label: "External links match Label|https://example.com" });
    checks.push({ ok: splitCsv(state.tags.join(",")).length >= 3, label: "At least 3 tags/keywords are set" });
    checks.push({ ok: draftText.length >= 900, label: "Draft text has substantial length (900+ chars)" });

    return checks;
  }

  function getChecklistScore(checks) {
    var score = 0;
    checks.forEach(function (check) {
      if (check.ok) {
        score += 1;
      }
    });
    return {
      score: score,
      total: checks.length,
      pass: score >= exportChecklistThreshold
    };
  }

  function renderValidationChecklist(checks, container) {
    if (!container) {
      return;
    }

    var status = getChecklistScore(checks);
    var html = ["<p><strong>Pre-publish checks</strong></p>"];

    checks.forEach(function (check) {
      var marker = check.ok ? "PASS" : "FIX";
      html.push("<p>[" + marker + "] " + escapeHtml(check.label) + "</p>");
    });

    html.unshift(
      "<p><strong>Score: " + status.score + "/" + status.total +
        " (Need " + exportChecklistThreshold + "+ to Export All)</strong></p>"
    );
    if (!status.pass) {
      html.unshift("<p><strong>Status: Improve checklist items before export.</strong></p>");
    }
    container.innerHTML = html.join("\n");
  }

  function saveDashboardState(state) {
    try {
      localStorage.setItem(draftStoreKey, JSON.stringify(state));
    } catch (_e) {
    }
  }

  function restoreDashboardState() {
    try {
      var raw = localStorage.getItem(draftStoreKey);
      if (!raw) {
        return;
      }

      var state = JSON.parse(raw);
      var map = {
        title: "title",
        slug: "slug",
        description: "description",
        publishedText: "publishedText",
        category: "category",
        imageFilename: "imageFilename",
        imageAlt: "imageAlt",
        intro: "intro",
        toolLinksRaw: "toolLinks",
        internalArticleLinksRaw: "internalArticleLinks",
        externalLinksRaw: "externalLinks",
        relatedLines: "relatedLinks"
      };

      Object.keys(map).forEach(function (key) {
        var el = byId(map[key]);
        if (el && typeof state[key] === "string") {
          el.value = state[key];
        }
      });

      if (Array.isArray(state.tags)) {
        byId("tags").value = state.tags.join(", ");
      }

      if (Array.isArray(state.sections)) {
        for (var i = 0; i < 5; i += 1) {
          var section = state.sections[i] || {};
          byId("s" + (i + 1) + "Heading").value = section.heading || "";
          byId("s" + (i + 1) + "Body").value = section.body || "";
          byId("s" + (i + 1) + "Bullets").value = section.bullets || "";
        }
      }

      if (Array.isArray(state.faqItems)) {
        byId("faq1q").value = (state.faqItems[0] && state.faqItems[0].q) || "";
        byId("faq1a").value = (state.faqItems[0] && state.faqItems[0].a) || "";
        byId("faq2q").value = (state.faqItems[1] && state.faqItems[1].q) || "";
        byId("faq2a").value = (state.faqItems[1] && state.faqItems[1].a) || "";
        byId("faq3q").value = (state.faqItems[2] && state.faqItems[2].q) || "";
        byId("faq3a").value = (state.faqItems[2] && state.faqItems[2].a) || "";
      }

      exportChecklistThreshold = clampThreshold(state.exportChecklistThreshold);
      var thresholdInput = byId("checklistThreshold");
      if (thresholdInput) {
        thresholdInput.value = String(exportChecklistThreshold);
      }
    } catch (_e2) {
    }
  }

  function clearDashboardState() {
    var form = byId("draft-form");
    if (form) {
      form.reset();
    }

    localStorage.removeItem(draftStoreKey);
    byId("draftOutput").value = "";
    byId("payloadOutput").value = "";
    var commandOut = byId("commandOutput");
    if (commandOut) {
      commandOut.value = "";
    }
    var preview = byId("draftPreview");
    if (preview) {
      preview.innerHTML = "";
    }
    var checklist = byId("validationChecklist");
    if (checklist) {
      checklist.innerHTML = "";
    }
    autoSlugEnabled = true;
    exportChecklistThreshold = 10;
    var thresholdInput = byId("checklistThreshold");
    if (thresholdInput) {
      thresholdInput.value = "10";
    }
  }

  function applyQualityPreset(value) {
    exportChecklistThreshold = clampThreshold(value);
    var thresholdInput = byId("checklistThreshold");
    if (thresholdInput) {
      thresholdInput.value = String(exportChecklistThreshold);
    }
    return exportChecklistThreshold;
  }

  function getQualityModeLabel(value) {
    var threshold = clampThreshold(value);
    if (threshold === 8) {
      return "Easy";
    }
    if (threshold === 10) {
      return "Balanced";
    }
    if (threshold === 12) {
      return "Strict";
    }
    return "Custom";
  }

  function renderQualityModeLabel(value) {
    var labelEl = byId("qualityModeLabel");
    if (!labelEl) {
      return;
    }

    labelEl.innerHTML = "<strong>Current Mode:</strong> " + getQualityModeLabel(value);
  }

  function renderDraftPreview(draftText, container) {
    if (!container) {
      return;
    }

    var lines = (draftText || "").split(/\r?\n/);
    var html = [];
    var inList = false;

    function closeListIfOpen() {
      if (inList) {
        html.push("</ul>");
        inList = false;
      }
    }

    lines.forEach(function (line) {
      var trimmed = line.trim();

      if (!trimmed) {
        closeListIfOpen();
        return;
      }

      if (trimmed.indexOf("### ") === 0) {
        closeListIfOpen();
        html.push("<h3>" + convertInlineLinks(trimmed.substring(4)) + "</h3>");
        return;
      }

      if (trimmed.indexOf("## ") === 0) {
        closeListIfOpen();
        html.push("<h2>" + convertInlineLinks(trimmed.substring(3)) + "</h2>");
        return;
      }

      if (trimmed.indexOf("- ") === 0) {
        if (!inList) {
          html.push("<ul>");
          inList = true;
        }
        html.push("<li>" + convertInlineLinks(trimmed.substring(2)) + "</li>");
        return;
      }

      closeListIfOpen();
      html.push("<p>" + convertInlineLinks(trimmed) + "</p>");
    });

    closeListIfOpen();
    container.innerHTML = html.join("\n");
  }

  function emitDashboardEvent(eventName, detail) {
    trackDashboardEvent(eventName, detail);
    window.dispatchEvent(new CustomEvent("lookforit:" + eventName, { detail: detail }));
  }

  function trackDashboardEvent(eventName, detail) {
    try {
      var raw = localStorage.getItem(dashboardAnalyticsKey);
      var events = raw ? JSON.parse(raw) : [];
      events.push({
        at: new Date().toISOString(),
        event: eventName,
        detail: detail || {}
      });

      if (events.length > 300) {
        events = events.slice(events.length - 300);
      }

      localStorage.setItem(dashboardAnalyticsKey, JSON.stringify(events));
    } catch (_e) {
    }
  }

  function getSnapshots() {
    try {
      return JSON.parse(localStorage.getItem(snapshotStoreKey) || "[]");
    } catch (_e) {
      return [];
    }
  }

  function saveSnapshot(state, payload, draftText, command) {
    try {
      var snapshots = getSnapshots();
      snapshots.push({
        at: new Date().toISOString(),
        slug: state.slug,
        title: state.title,
        threshold: exportChecklistThreshold,
        command: command,
        payload: payload,
        draftText: draftText
      });

      if (snapshots.length > 50) {
        snapshots = snapshots.slice(snapshots.length - 50);
      }

      localStorage.setItem(snapshotStoreKey, JSON.stringify(snapshots));
      return snapshots[snapshots.length - 1];
    } catch (_e) {
      return null;
    }
  }

  function buildPublishRequest(state, payload, command, draftText) {
    return {
      requestedAt: new Date().toISOString(),
      slug: state.slug,
      title: state.title,
      roleRequired: "admin",
      source: "dashboard",
      command: command,
      payload: payload,
      draftText: draftText
    };
  }

  function requestPublish(state, payload, command, draftText) {
    var request = buildPublishRequest(state, payload, command, draftText);

    if (
      window.LookforitPublishBridge &&
      typeof window.LookforitPublishBridge.submit === "function"
    ) {
      try {
        var bridgeResult = window.LookforitPublishBridge.submit(request);
        emitDashboardEvent("publish-bridge-submitted", {
          slug: state.slug,
          result: bridgeResult || null
        });
        return { ok: true, mode: "bridge", result: bridgeResult || null };
      } catch (error) {
        emitDashboardEvent("publish-bridge-failed", {
          slug: state.slug,
          error: error.message
        });
      }
    }

    downloadTextFile((state.slug || "article") + "-publish-request.json", JSON.stringify(request, null, 2));
    emitDashboardEvent("publish-request-downloaded", { slug: state.slug });
    return { ok: true, mode: "download" };
  }

  function prepareOutputs(state, draftText, draftOutput, payloadOutput, commandOutput, draftPreview) {
    var payload = buildScriptPayload(state, draftText);
    var command = buildGenerateCommand(payload);

    draftOutput.value = draftText;
    payloadOutput.value = JSON.stringify(payload, null, 2);
    if (commandOutput) {
      commandOutput.value = command;
    }
    renderDraftPreview(draftText, draftPreview);

    return {
      payload: payload,
      command: command
    };
  }

  function exportAllArtifacts(state, draftText, payload, command) {
    var baseName = state.slug || "article-draft";
    downloadTextFile(baseName + ".txt", draftText);
    downloadTextFile(baseName + "-payload.json", JSON.stringify(payload, null, 2));
    downloadTextFile(baseName + "-command.txt", command);
  }

  function registerScriptAdapter(name, handler) {
    if (!name || typeof handler !== "function") {
      throw new Error("registerScriptAdapter requires a name and handler function.");
    }

    adapterRegistry[name] = handler;
  }

  function invokeScriptAdapter(name, payload) {
    var handler = adapterRegistry[name];
    if (!handler) {
      return { ok: false, message: "Adapter not found: " + name };
    }

    try {
      var result = handler(payload);
      return { ok: true, result: result };
    } catch (error) {
      return { ok: false, message: error.message };
    }
  }

  function downloadTextFile(fileName, content) {
    var blob = new Blob([content], { type: "text/plain;charset=utf-8" });
    var url = URL.createObjectURL(blob);
    var link = document.createElement("a");
    link.href = url;
    link.download = fileName;
    document.body.appendChild(link);
    link.click();
    link.remove();
    URL.revokeObjectURL(url);
  }

  function copyToClipboard(text) {
    if (!navigator.clipboard) {
      return Promise.reject(new Error("Clipboard API is not available."));
    }
    return navigator.clipboard.writeText(text);
  }

  function refreshSlugFromTitle() {
    if (!autoSlugEnabled) {
      return;
    }

    byId("slug").value = slugify(byId("title").value);
  }

  function handleSlugInput() {
    var current = normalizeLine(byId("slug").value);
    var generated = slugify(byId("title").value);
    autoSlugEnabled = current.length === 0 || current === generated;
  }

  function init() {
    var titleInput = byId("title");
    var slugInput = byId("slug");
    var generateDraftButton = byId("generateDraft");
    var generatePayloadButton = byId("generatePayload");
    var downloadDraftButton = byId("downloadDraft");
    var exportAllButton = byId("exportAll");
    var publishNowButton = byId("publishNow");
    var clearDashboardButton = byId("clearDashboard");
    var thresholdInput = byId("checklistThreshold");
    var presetEasyButton = byId("presetEasy");
    var presetBalancedButton = byId("presetBalanced");
    var presetStrictButton = byId("presetStrict");
    var copyDraftButton = byId("copyDraft");
    var draftOutput = byId("draftOutput");
    var payloadOutput = byId("payloadOutput");
    var commandOutput = byId("commandOutput");
    var draftPreview = byId("draftPreview");
    var validationChecklist = byId("validationChecklist");

    function currentDraftAndState() {
      var state = readDashboardState();
      var draftText = buildDraftText(state);
      return { state: state, draftText: draftText };
    }

    function refreshLiveState() {
      var data = currentDraftAndState();
      data.state.exportChecklistThreshold = exportChecklistThreshold;
      prepareOutputs(data.state, data.draftText, draftOutput, payloadOutput, commandOutput, draftPreview);
      saveDashboardState(data.state);
      renderQualityModeLabel(exportChecklistThreshold);

      var checks = buildValidationChecklist(data.state, data.draftText);
      renderValidationChecklist(checks, validationChecklist);
    }

    var debouncedRefreshLiveState = debounce(refreshLiveState, 180);

    titleInput.addEventListener("input", refreshSlugFromTitle);
    slugInput.addEventListener("input", handleSlugInput);
    thresholdInput.addEventListener("input", function () {
      exportChecklistThreshold = clampThreshold(thresholdInput.value);
      thresholdInput.value = String(exportChecklistThreshold);
      refreshLiveState();
    });

    presetEasyButton.addEventListener("click", function () {
      applyQualityPreset(8);
      refreshLiveState();
    });

    presetBalancedButton.addEventListener("click", function () {
      applyQualityPreset(10);
      refreshLiveState();
    });

    presetStrictButton.addEventListener("click", function () {
      applyQualityPreset(12);
      refreshLiveState();
    });
    byId("draft-form").addEventListener("input", debouncedRefreshLiveState);

    generateDraftButton.addEventListener("click", function () {
      var data = currentDraftAndState();
      prepareOutputs(data.state, data.draftText, draftOutput, payloadOutput, commandOutput, draftPreview);
      renderValidationChecklist(buildValidationChecklist(data.state, data.draftText), validationChecklist);
      emitDashboardEvent("draft-generated", {
        state: data.state,
        draftText: data.draftText
      });
    });

    generatePayloadButton.addEventListener("click", function () {
      var data = currentDraftAndState();
      var prepared = prepareOutputs(
        data.state,
        data.draftText,
        draftOutput,
        payloadOutput,
        commandOutput,
        draftPreview
      );
      renderValidationChecklist(buildValidationChecklist(data.state, data.draftText), validationChecklist);

      var adapterResult = invokeScriptAdapter("payload-created", prepared.payload);
      emitDashboardEvent("payload-generated", {
        payload: prepared.payload,
        adapterResult: adapterResult
      });
    });

    downloadDraftButton.addEventListener("click", function () {
      var data = currentDraftAndState();
      if (!data.draftText) {
        return;
      }

      prepareOutputs(data.state, data.draftText, draftOutput, payloadOutput, commandOutput, draftPreview);
      renderValidationChecklist(buildValidationChecklist(data.state, data.draftText), validationChecklist);
      var fileName = (data.state.slug || "article-draft") + ".txt";
      downloadTextFile(fileName, data.draftText);
      emitDashboardEvent("draft-downloaded", {
        fileName: fileName,
        slug: data.state.slug
      });
    });

    exportAllButton.addEventListener("click", function () {
      var data = currentDraftAndState();
      if (!data.draftText) {
        return;
      }

      var checks = buildValidationChecklist(data.state, data.draftText);
      var status = getChecklistScore(checks);
      renderValidationChecklist(checks, validationChecklist);

      if (!status.pass) {
        emitDashboardEvent("export-blocked", {
          slug: data.state.slug,
          score: status.score,
          total: status.total,
          required: exportChecklistThreshold
        });
        if (typeof window !== "undefined" && typeof window.alert === "function") {
          window.alert(
            "Export blocked: checklist score is " +
              status.score +
              "/" +
              status.total +
              ". You need at least " +
              exportChecklistThreshold +
              " checks passing."
          );
        }
        return;
      }

      var prepared = prepareOutputs(
        data.state,
        data.draftText,
        draftOutput,
        payloadOutput,
        commandOutput,
        draftPreview
      );
      renderValidationChecklist(buildValidationChecklist(data.state, data.draftText), validationChecklist);
      saveSnapshot(data.state, prepared.payload, data.draftText, prepared.command);

      exportAllArtifacts(data.state, data.draftText, prepared.payload, prepared.command);
      emitDashboardEvent("export-all", {
        slug: data.state.slug,
        command: prepared.command
      });
    });

    if (publishNowButton) {
      publishNowButton.addEventListener("click", function () {
        var data = currentDraftAndState();
        if (!data.draftText) {
          return;
        }

        var checks = buildValidationChecklist(data.state, data.draftText);
        var status = getChecklistScore(checks);
        renderValidationChecklist(checks, validationChecklist);
        if (!status.pass) {
          emitDashboardEvent("publish-blocked", {
            slug: data.state.slug,
            score: status.score,
            total: status.total,
            required: exportChecklistThreshold
          });
          return;
        }

        var prepared = prepareOutputs(
          data.state,
          data.draftText,
          draftOutput,
          payloadOutput,
          commandOutput,
          draftPreview
        );

        saveSnapshot(data.state, prepared.payload, data.draftText, prepared.command);
        requestPublish(data.state, prepared.payload, prepared.command, data.draftText);
      });
    }

    clearDashboardButton.addEventListener("click", function () {
      clearDashboardState();
      emitDashboardEvent("dashboard-cleared", {});
    });

    copyDraftButton.addEventListener("click", function () {
      var data = currentDraftAndState();
      var text = data.draftText || draftOutput.value;
      if (!text.trim()) {
        return;
      }

      copyToClipboard(text)
        .then(function () {
          emitDashboardEvent("draft-copied", { slug: data.state.slug });
        })
        .catch(function () {
          emitDashboardEvent("draft-copy-failed", { slug: data.state.slug });
        });
    });

    restoreDashboardState();
    handleSlugInput();
    refreshLiveState();
  }

  window.LookforitDashboard = {
    registerScriptAdapter: registerScriptAdapter,
    invokeScriptAdapter: invokeScriptAdapter,
    readDashboardState: readDashboardState,
    buildDraftText: buildDraftText,
    buildSectionBlock: buildSectionBlock,
    buildFaqBlock: buildFaqBlock,
    buildRelatedBlock: buildRelatedBlock,
    buildLinksBlock: buildLinksBlock,
    buildImageBlock: buildImageBlock,
    buildTagsBlock: buildTagsBlock,
    buildValidationChecklist: buildValidationChecklist,
    getChecklistScore: getChecklistScore,
    setExportChecklistThreshold: function (value) {
      applyQualityPreset(value);
      renderQualityModeLabel(exportChecklistThreshold);
      return exportChecklistThreshold;
    },
    getExportChecklistThreshold: function () {
      return exportChecklistThreshold;
    },
    getSnapshots: getSnapshots,
    clearSnapshots: function () {
      localStorage.removeItem(snapshotStoreKey);
    },
    getAnalyticsEvents: function () {
      try {
        return JSON.parse(localStorage.getItem(dashboardAnalyticsKey) || "[]");
      } catch (_e) {
        return [];
      }
    },
    clearAnalyticsEvents: function () {
      localStorage.removeItem(dashboardAnalyticsKey);
    },
    applyQualityPreset: applyQualityPreset,
    getQualityModeLabel: getQualityModeLabel,
    buildPublishRequest: buildPublishRequest,
    buildGenerateCommand: buildGenerateCommand,
    buildScriptPayload: buildScriptPayload
  };

  document.addEventListener("DOMContentLoaded", init);
})();
