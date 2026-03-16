(function () {
  "use strict";

  function byId(id) {
    return document.getElementById(id);
  }

  function copyText(text) {
    if (!text && text !== "") return;
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(String(text)).catch(function () {});
      return;
    }
    var tmp = document.createElement("textarea");
    tmp.value = String(text);
    document.body.appendChild(tmp);
    tmp.select();
    document.execCommand("copy");
    document.body.removeChild(tmp);
  }

  function escapeHtml(text) {
    return String(text)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function parseImageFile(inputEl, cb) {
    if (!inputEl || !inputEl.files || !inputEl.files[0]) return;
    var file = inputEl.files[0];
    var reader = new FileReader();
    reader.onload = function (e) {
      var img = new Image();
      img.onload = function () {
        cb(img, e.target.result, file);
      };
      img.src = e.target.result;
    };
    reader.readAsDataURL(file);
  }

  function downloadDataUrl(dataUrl, filename) {
    if (!dataUrl) return;
    var a = document.createElement("a");
    a.href = dataUrl;
    a.download = filename || "download";
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
  }

  var tool = document.body && document.body.getAttribute("data-web-tool");
  if (!tool) return;

  var imageState = {
    resizerDataUrl: "",
    cropperDataUrl: "",
    compressorDataUrl: "",
    cropperImage: null,
    resizerImage: null,
    compressorImage: null,
    pickerImage: null,
  };

  function initWordCounter() {
    var input = byId("wcInput");
    if (!input) return;

    function update() {
      var text = input.value || "";
      var words = text.trim() ? text.trim().split(/\s+/).length : 0;
      var chars = text.length;
      var lines = text ? text.split(/\r?\n/).length : 0;
      var read = Math.ceil(words / 200);
      byId("wcWords").textContent = String(words);
      byId("wcChars").textContent = String(chars);
      byId("wcLines").textContent = String(lines);
      byId("wcRead").textContent = String(read);
    }

    input.addEventListener("input", update);
    update();
  }

  function initCharacterCounter() {
    var input = byId("ccInput");
    if (!input) return;

    function update() {
      var text = input.value || "";
      var chars = text.length;
      var noSpace = text.replace(/\s/g, "").length;
      var words = text.trim() ? text.trim().split(/\s+/).length : 0;
      var paras = text.trim() ? text.trim().split(/\n\s*\n/).length : 0;
      byId("ccChars").textContent = String(chars);
      byId("ccNoSpace").textContent = String(noSpace);
      byId("ccWords").textContent = String(words);
      byId("ccParas").textContent = String(paras);
    }

    input.addEventListener("input", update);
    update();
  }

  function toTitleCase(text) {
    return text
      .toLowerCase()
      .replace(/\b\w/g, function (c) {
        return c.toUpperCase();
      });
  }

  function toSentenceCase(text) {
    return text
      .toLowerCase()
      .replace(/(^\s*\w|[.!?]\s*\w)/g, function (c) {
        return c.toUpperCase();
      });
  }

  function initTextCaseConverter() {
    var input = byId("tccInput");
    if (!input) return;
    byId("tccUpper").addEventListener("click", function () {
      input.value = input.value.toUpperCase();
    });
    byId("tccLower").addEventListener("click", function () {
      input.value = input.value.toLowerCase();
    });
    byId("tccTitle").addEventListener("click", function () {
      input.value = toTitleCase(input.value);
    });
    byId("tccSentence").addEventListener("click", function () {
      input.value = toSentenceCase(input.value);
    });
    byId("tccCopy").addEventListener("click", function () {
      copyText(input.value);
    });
  }

  function initRemoveDuplicateLines() {
    var input = byId("rdlInput");
    if (!input) return;
    var output = byId("rdlOutput");
    var stats = byId("rdlStats");

    byId("rdlRun").addEventListener("click", function () {
      var lines = (input.value || "").split(/\r?\n/);
      var seen = Object.create(null);
      var unique = [];
      for (var i = 0; i < lines.length; i++) {
        var line = lines[i];
        if (!seen[line]) {
          seen[line] = true;
          unique.push(line);
        }
      }
      output.value = unique.join("\n");
      stats.className = "wt-status ok";
      stats.textContent =
        "Removed " + String(lines.length - unique.length) + " duplicate lines.";
    });

    byId("rdlCopy").addEventListener("click", function () {
      copyText(output.value);
    });

    byId("rdlClear").addEventListener("click", function () {
      input.value = "";
      output.value = "";
      stats.textContent = "";
    });
  }

  function initTextSorter() {
    var input = byId("tsInput");
    if (!input) return;
    var output = byId("tsOutput");

    byId("tsSort").addEventListener("click", function () {
      var order = byId("tsOrder").value;
      var caseMode = byId("tsCase").value;
      var lines = (input.value || "")
        .split(/\r?\n/)
        .filter(function (x) {
          return x.trim().length > 0;
        });

      lines.sort(function (a, b) {
        var aa = caseMode === "insensitive" ? a.toLowerCase() : a;
        var bb = caseMode === "insensitive" ? b.toLowerCase() : b;
        if (aa < bb) return -1;
        if (aa > bb) return 1;
        return 0;
      });

      if (order === "desc") lines.reverse();
      output.value = lines.join("\n");
    });

    byId("tsCopy").addEventListener("click", function () {
      copyText(output.value);
    });
  }

  function initTextCompare() {
    var a = byId("tcA");
    if (!a) return;
    var b = byId("tcB");
    var out = byId("tcOut");

    byId("tcCompare").addEventListener("click", function () {
      var left = (a.value || "").split(/\r?\n/);
      var right = (b.value || "").split(/\r?\n/);
      var max = Math.max(left.length, right.length);
      var html = [];
      for (var i = 0; i < max; i++) {
        var l = left[i] || "";
        var r = right[i] || "";
        if (l === r) {
          html.push('<div class="diff-same">' + escapeHtml(l) + "</div>");
        } else {
          if (l) {
            html.push('<div class="diff-removed">- ' + escapeHtml(l) + "</div>");
          }
          if (r) {
            html.push('<div class="diff-added">+ ' + escapeHtml(r) + "</div>");
          }
        }
      }
      out.innerHTML = html.join("");
    });
  }

  function initJsonFormatter() {
    var input = byId("jfInput");
    if (!input) return;
    var output = byId("jfOutput");
    var status = byId("jfStatus");

    function setStatus(ok, msg) {
      status.className = "wt-status " + (ok ? "ok" : "err");
      status.textContent = msg;
    }

    byId("jfFormat").addEventListener("click", function () {
      try {
        var data = JSON.parse(input.value || "{}");
        output.value = JSON.stringify(data, null, 2);
        setStatus(true, "Valid JSON formatted successfully.");
      } catch (e) {
        setStatus(false, "Invalid JSON: " + e.message);
      }
    });

    byId("jfMinify").addEventListener("click", function () {
      try {
        var data = JSON.parse(input.value || "{}");
        output.value = JSON.stringify(data);
        setStatus(true, "JSON minified successfully.");
      } catch (e) {
        setStatus(false, "Invalid JSON: " + e.message);
      }
    });

    byId("jfCopy").addEventListener("click", function () {
      copyText(output.value);
    });
  }

  function initBase64() {
    var input = byId("b64Input");
    if (!input) return;
    var output = byId("b64Output");
    var status = byId("b64Status");

    function setStatus(ok, msg) {
      status.className = "wt-status " + (ok ? "ok" : "err");
      status.textContent = msg;
    }

    byId("b64Encode").addEventListener("click", function () {
      try {
        output.value = btoa(unescape(encodeURIComponent(input.value || "")));
        setStatus(true, "Encoded successfully.");
      } catch (e) {
        setStatus(false, "Could not encode text.");
      }
    });

    byId("b64Decode").addEventListener("click", function () {
      try {
        output.value = decodeURIComponent(escape(atob(input.value || "")));
        setStatus(true, "Decoded successfully.");
      } catch (e) {
        setStatus(false, "Invalid Base64 input.");
      }
    });

    byId("b64Copy").addEventListener("click", function () {
      copyText(output.value);
    });
  }

  function initUrlEncoderDecoder() {
    var input = byId("uedInput");
    if (!input) return;
    var output = byId("uedOutput");
    var status = byId("uedStatus");

    function setStatus(ok, msg) {
      status.className = "wt-status " + (ok ? "ok" : "err");
      status.textContent = msg;
    }

    byId("uedEncode").addEventListener("click", function () {
      output.value = encodeURIComponent(input.value || "");
      setStatus(true, "Encoded successfully.");
    });

    byId("uedDecode").addEventListener("click", function () {
      try {
        output.value = decodeURIComponent(input.value || "");
        setStatus(true, "Decoded successfully.");
      } catch (e) {
        setStatus(false, "Invalid encoded input.");
      }
    });
  }

  function rgbToHsl(r, g, b) {
    r /= 255;
    g /= 255;
    b /= 255;
    var max = Math.max(r, g, b),
      min = Math.min(r, g, b);
    var h,
      s,
      l = (max + min) / 2;

    if (max === min) {
      h = s = 0;
    } else {
      var d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
      switch (max) {
        case r:
          h = (g - b) / d + (g < b ? 6 : 0);
          break;
        case g:
          h = (b - r) / d + 2;
          break;
        default:
          h = (r - g) / d + 4;
          break;
      }
      h /= 6;
    }
    return [Math.round(h * 360), Math.round(s * 100), Math.round(l * 100)];
  }

  function hslToRgb(h, s, l) {
    h /= 360;
    s /= 100;
    l /= 100;
    var r, g, b;

    if (s === 0) {
      r = g = b = l;
    } else {
      var hue2rgb = function (p, q, t) {
        if (t < 0) t += 1;
        if (t > 1) t -= 1;
        if (t < 1 / 6) return p + (q - p) * 6 * t;
        if (t < 1 / 2) return q;
        if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
        return p;
      };
      var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      var p = 2 * l - q;
      r = hue2rgb(p, q, h + 1 / 3);
      g = hue2rgb(p, q, h);
      b = hue2rgb(p, q, h - 1 / 3);
    }
    return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
  }

  function rgbToHex(r, g, b) {
    function toHex(n) {
      var h = Number(n).toString(16);
      return h.length === 1 ? "0" + h : h;
    }
    return "#" + toHex(r) + toHex(g) + toHex(b);
  }

  function initColorConverter() {
    var input = byId("ccvInput");
    if (!input) return;
    var swatch = byId("ccvSwatch");
    var hexEl = byId("ccvHex");
    var rgbEl = byId("ccvRgb");
    var hslEl = byId("ccvHsl");
    var status = byId("ccvStatus");

    function setStatus(ok, msg) {
      status.className = "wt-status " + (ok ? "ok" : "err");
      status.textContent = msg;
    }

    byId("ccvConvert").addEventListener("click", function () {
      var val = (input.value || "").trim();
      var r, g, b;
      var m;

      if (/^#[0-9a-fA-F]{6}$/.test(val)) {
        r = parseInt(val.slice(1, 3), 16);
        g = parseInt(val.slice(3, 5), 16);
        b = parseInt(val.slice(5, 7), 16);
      } else if ((m = val.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/i))) {
        r = Number(m[1]);
        g = Number(m[2]);
        b = Number(m[3]);
      } else if ((m = val.match(/^hsl\((\d+),\s*(\d+)%?,\s*(\d+)%?\)$/i))) {
        var rgb = hslToRgb(Number(m[1]), Number(m[2]), Number(m[3]));
        r = rgb[0];
        g = rgb[1];
        b = rgb[2];
      } else {
        setStatus(false, "Invalid format. Use HEX, RGB, or HSL.");
        return;
      }

      if (
        [r, g, b].some(function (n) {
          return n < 0 || n > 255 || Number.isNaN(n);
        })
      ) {
        setStatus(false, "Color values are out of range.");
        return;
      }

      var hsl = rgbToHsl(r, g, b);
      var hex = rgbToHex(r, g, b);
      swatch.style.background = hex;
      hexEl.textContent = "HEX: " + hex;
      rgbEl.textContent = "RGB: rgb(" + r + ", " + g + ", " + b + ")";
      hslEl.textContent = "HSL: hsl(" + hsl[0] + ", " + hsl[1] + "%, " + hsl[2] + "%)";
      setStatus(true, "Converted successfully.");
    });
  }

  function initUnitConverter() {
    var typeEl = byId("ucType");
    if (!typeEl) return;
    var fromEl = byId("ucFrom");
    var toEl = byId("ucTo");
    var valueEl = byId("ucValue");
    var resultEl = byId("ucResult");

    var definitions = {
      length: ["m", "km", "cm", "mi", "ft"],
      weight: ["kg", "g", "lb"],
      temperature: ["C", "F", "K"],
    };

    function fillUnits() {
      var t = typeEl.value;
      var items = definitions[t] || [];
      fromEl.innerHTML = "";
      toEl.innerHTML = "";
      items.forEach(function (u) {
        var o1 = document.createElement("option");
        o1.value = u;
        o1.textContent = u;
        var o2 = document.createElement("option");
        o2.value = u;
        o2.textContent = u;
        fromEl.appendChild(o1);
        toEl.appendChild(o2);
      });
      if (items.length > 1) toEl.value = items[1];
    }

    function convertLength(v, from, to) {
      var inM = v;
      if (from === "km") inM = v * 1000;
      if (from === "cm") inM = v / 100;
      if (from === "mi") inM = v * 1609.344;
      if (from === "ft") inM = v * 0.3048;

      if (to === "km") return inM / 1000;
      if (to === "cm") return inM * 100;
      if (to === "mi") return inM / 1609.344;
      if (to === "ft") return inM / 0.3048;
      return inM;
    }

    function convertWeight(v, from, to) {
      var inKg = v;
      if (from === "g") inKg = v / 1000;
      if (from === "lb") inKg = v * 0.45359237;

      if (to === "g") return inKg * 1000;
      if (to === "lb") return inKg / 0.45359237;
      return inKg;
    }

    function convertTemp(v, from, to) {
      var c = v;
      if (from === "F") c = (v - 32) * (5 / 9);
      if (from === "K") c = v - 273.15;

      if (to === "F") return c * (9 / 5) + 32;
      if (to === "K") return c + 273.15;
      return c;
    }

    typeEl.addEventListener("change", fillUnits);
    byId("ucConvert").addEventListener("click", function () {
      var t = typeEl.value;
      var from = fromEl.value;
      var to = toEl.value;
      var v = Number(valueEl.value);
      if (Number.isNaN(v)) {
        resultEl.textContent = "Please enter a valid number.";
        return;
      }
      var result = v;
      if (t === "length") result = convertLength(v, from, to);
      if (t === "weight") result = convertWeight(v, from, to);
      if (t === "temperature") result = convertTemp(v, from, to);
      resultEl.textContent =
        String(v) + " " + from + " = " + result.toFixed(6).replace(/\.0+$/, "") + " " + to;
    });

    fillUnits();
  }

  function initPasswordGenerator() {
    var out = byId("pgOutput");
    if (!out) return;
    var status = byId("pgStatus");

    byId("pgGenerate").addEventListener("click", function () {
      var len = Number(byId("pgLength").value);
      if (Number.isNaN(len) || len < 6) len = 16;
      if (len > 64) len = 64;

      var pool = "";
      if (byId("pgUpper").checked) pool += "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
      if (byId("pgLower").checked) pool += "abcdefghijklmnopqrstuvwxyz";
      if (byId("pgNumber").checked) pool += "0123456789";
      if (byId("pgSymbol").checked) pool += "!@#$%^&*()_+-=[]{}|;:,.<>?";

      if (!pool) {
        status.className = "wt-status err";
        status.textContent = "Please enable at least one character set.";
        return;
      }

      var bytes = new Uint32Array(len);
      if (window.crypto && window.crypto.getRandomValues) {
        window.crypto.getRandomValues(bytes);
      } else {
        for (var i = 0; i < len; i++) bytes[i] = Math.floor(Math.random() * 100000);
      }

      var pwd = "";
      for (var j = 0; j < len; j++) {
        pwd += pool[bytes[j] % pool.length];
      }
      out.value = pwd;
      status.className = "wt-status ok";
      status.textContent = "Password generated.";
    });

    byId("pgCopy").addEventListener("click", function () {
      copyText(out.value);
    });
  }

  function initUuidGenerator() {
    var out = byId("ugOutput");
    if (!out) return;

    function makeUuid() {
      if (window.crypto && window.crypto.randomUUID) {
        return window.crypto.randomUUID();
      }
      var t = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx";
      return t.replace(/[xy]/g, function (c) {
        var r = (Math.random() * 16) | 0;
        var v = c === "x" ? r : (r & 0x3) | 0x8;
        return v.toString(16);
      });
    }

    byId("ugGenerate").addEventListener("click", function () {
      var count = Number(byId("ugCount").value);
      if (Number.isNaN(count) || count < 1) count = 1;
      if (count > 100) count = 100;
      var items = [];
      for (var i = 0; i < count; i++) items.push(makeUuid());
      out.value = items.join("\n");
    });

    byId("ugCopy").addEventListener("click", function () {
      copyText(out.value);
    });
  }

  function initHashGenerator() {
    var input = byId("hgInput");
    if (!input) return;
    var out = byId("hgOutput");
    var status = byId("hgStatus");

    function toHex(buffer) {
      var bytes = new Uint8Array(buffer);
      var parts = [];
      for (var i = 0; i < bytes.length; i++) {
        parts.push(bytes[i].toString(16).padStart(2, "0"));
      }
      return parts.join("");
    }

    byId("hgGenerate").addEventListener("click", function () {
      if (!(window.crypto && window.crypto.subtle)) {
        status.className = "wt-status err";
        status.textContent = "Web Crypto API not available in this browser.";
        return;
      }
      var data = new TextEncoder().encode(input.value || "");
      window.crypto.subtle
        .digest("SHA-256", data)
        .then(function (hash) {
          out.value = toHex(hash);
          status.className = "wt-status ok";
          status.textContent = "SHA-256 hash generated.";
        })
        .catch(function () {
          status.className = "wt-status err";
          status.textContent = "Could not generate hash.";
        });
    });

    byId("hgCopy").addEventListener("click", function () {
      copyText(out.value);
    });
  }

  function initRegexTester() {
    var patternEl = byId("rtPattern");
    if (!patternEl) return;
    var flagsEl = byId("rtFlags");
    var inputEl = byId("rtInput");
    var outEl = byId("rtOutput");
    var countEl = byId("rtCount");

    byId("rtRun").addEventListener("click", function () {
      try {
        var pattern = patternEl.value || "";
        var flags = flagsEl.value || "g";
        var re = new RegExp(pattern, flags);
        var text = inputEl.value || "";

        var hits = 0;
        var html = escapeHtml(text).replace(re, function (m) {
          hits += 1;
          return "<mark>" + escapeHtml(m) + "</mark>";
        });

        outEl.innerHTML = html || "<em>No input text.</em>";
        countEl.className = "wt-status ok";
        countEl.textContent = "Matches found: " + String(hits);
      } catch (e) {
        outEl.textContent = "";
        countEl.className = "wt-status err";
        countEl.textContent = "Regex error: " + e.message;
      }
    });
  }

  function initTimestampConverter() {
    var tsInput = byId("tcTsInput");
    if (!tsInput) return;
    var dateInput = byId("tcDateInput");
    var result = byId("tcResult");

    byId("tcToDate").addEventListener("click", function () {
      var ts = Number(tsInput.value);
      if (Number.isNaN(ts)) {
        result.textContent = "Invalid timestamp.";
        return;
      }
      var d = new Date(ts * 1000);
      result.textContent =
        "Local: " + d.toLocaleString() + " | UTC: " + d.toUTCString();
    });

    byId("tcToTs").addEventListener("click", function () {
      var dateVal = dateInput.value;
      if (!dateVal) {
        result.textContent = "Select a date and time first.";
        return;
      }
      var d = new Date(dateVal);
      result.textContent = "Unix timestamp: " + String(Math.floor(d.getTime() / 1000));
    });

    byId("tcNow").addEventListener("click", function () {
      var now = new Date();
      tsInput.value = String(Math.floor(now.getTime() / 1000));
      var local = new Date(now.getTime() - now.getTimezoneOffset() * 60000);
      dateInput.value = local.toISOString().slice(0, 16);
      result.textContent = "Loaded current local date and timestamp.";
    });
  }

  function initImageResizer() {
    var file = byId("irFile");
    if (!file) return;
    var width = byId("irWidth");
    var height = byId("irHeight");
    var canvas = byId("irCanvas");
    var status = byId("irStatus");
    var ctx = canvas.getContext("2d");

    file.addEventListener("change", function () {
      parseImageFile(file, function (img) {
        imageState.resizerImage = img;
        width.value = img.width;
        height.value = img.height;
        canvas.width = img.width;
        canvas.height = img.height;
        ctx.drawImage(img, 0, 0);
        status.className = "wt-status ok";
        status.textContent = "Image loaded: " + img.width + "x" + img.height;
      });
    });

    byId("irResize").addEventListener("click", function () {
      if (!imageState.resizerImage) {
        status.className = "wt-status err";
        status.textContent = "Upload an image first.";
        return;
      }
      var w = Number(width.value);
      var h = Number(height.value);
      if (Number.isNaN(w) || Number.isNaN(h) || w < 1 || h < 1) {
        status.className = "wt-status err";
        status.textContent = "Width and height must be valid numbers.";
        return;
      }
      canvas.width = w;
      canvas.height = h;
      ctx.drawImage(imageState.resizerImage, 0, 0, w, h);
      imageState.resizerDataUrl = canvas.toDataURL("image/png");
      status.className = "wt-status ok";
      status.textContent = "Image resized to " + w + "x" + h;
    });

    byId("irDownload").addEventListener("click", function () {
      var data = imageState.resizerDataUrl || canvas.toDataURL("image/png");
      downloadDataUrl(data, "resized-image.png");
    });
  }

  function initImageCropper() {
    var file = byId("icFile");
    if (!file) return;
    var xEl = byId("icX");
    var yEl = byId("icY");
    var wEl = byId("icW");
    var hEl = byId("icH");
    var canvas = byId("icCanvas");
    var status = byId("icStatus");
    var ctx = canvas.getContext("2d");

    file.addEventListener("change", function () {
      parseImageFile(file, function (img) {
        imageState.cropperImage = img;
        canvas.width = img.width;
        canvas.height = img.height;
        ctx.drawImage(img, 0, 0);
        wEl.value = Math.min(200, img.width);
        hEl.value = Math.min(200, img.height);
        status.className = "wt-status ok";
        status.textContent = "Image loaded. Set crop area and click Crop.";
      });
    });

    byId("icCrop").addEventListener("click", function () {
      if (!imageState.cropperImage) {
        status.className = "wt-status err";
        status.textContent = "Upload an image first.";
        return;
      }

      var x = Number(xEl.value);
      var y = Number(yEl.value);
      var w = Number(wEl.value);
      var h = Number(hEl.value);
      if (
        Number.isNaN(x) ||
        Number.isNaN(y) ||
        Number.isNaN(w) ||
        Number.isNaN(h) ||
        w < 1 ||
        h < 1
      ) {
        status.className = "wt-status err";
        status.textContent = "Invalid crop values.";
        return;
      }

      var src = imageState.cropperImage;
      x = Math.max(0, Math.min(x, src.width - 1));
      y = Math.max(0, Math.min(y, src.height - 1));
      w = Math.min(w, src.width - x);
      h = Math.min(h, src.height - y);

      canvas.width = w;
      canvas.height = h;
      ctx.drawImage(src, x, y, w, h, 0, 0, w, h);
      imageState.cropperDataUrl = canvas.toDataURL("image/png");
      status.className = "wt-status ok";
      status.textContent = "Cropped image to " + w + "x" + h;
    });

    byId("icDownload").addEventListener("click", function () {
      var data = imageState.cropperDataUrl || canvas.toDataURL("image/png");
      downloadDataUrl(data, "cropped-image.png");
    });
  }

  function initImageToBase64() {
    var file = byId("ibFile");
    if (!file) return;
    var output = byId("ibOutput");
    var preview = byId("ibPreview");
    var status = byId("ibStatus");

    file.addEventListener("change", function () {
      if (!file.files || !file.files[0]) return;
      var reader = new FileReader();
      reader.onload = function (e) {
        output.value = e.target.result;
        preview.src = e.target.result;
        status.className = "wt-status ok";
        status.textContent = "Converted image to Base64.";
      };
      reader.readAsDataURL(file.files[0]);
    });

    byId("ibCopy").addEventListener("click", function () {
      copyText(output.value);
    });
  }

  function initImageCompressor() {
    var file = byId("imcFile");
    if (!file) return;
    var qualityEl = byId("imcQuality");
    var canvas = byId("imcCanvas");
    var status = byId("imcStatus");
    var ctx = canvas.getContext("2d");

    file.addEventListener("change", function () {
      parseImageFile(file, function (img) {
        imageState.compressorImage = img;
        canvas.width = img.width;
        canvas.height = img.height;
        ctx.drawImage(img, 0, 0);
        status.className = "wt-status ok";
        status.textContent = "Image loaded. Select quality and compress.";
      });
    });

    byId("imcCompress").addEventListener("click", function () {
      if (!imageState.compressorImage) {
        status.className = "wt-status err";
        status.textContent = "Upload an image first.";
        return;
      }
      var quality = Number(qualityEl.value);
      if (Number.isNaN(quality) || quality < 0.1 || quality > 1) quality = 0.7;
      canvas.width = imageState.compressorImage.width;
      canvas.height = imageState.compressorImage.height;
      ctx.drawImage(imageState.compressorImage, 0, 0);
      imageState.compressorDataUrl = canvas.toDataURL("image/jpeg", quality);
      status.className = "wt-status ok";
      status.textContent = "Compressed with quality " + quality.toFixed(2);
    });

    byId("imcDownload").addEventListener("click", function () {
      if (!imageState.compressorDataUrl) {
        imageState.compressorDataUrl = canvas.toDataURL("image/jpeg", 0.7);
      }
      downloadDataUrl(imageState.compressorDataUrl, "compressed-image.jpg");
    });
  }

  function initColorPicker() {
    var file = byId("cpFile");
    if (!file) return;
    var canvas = byId("cpCanvas");
    var swatch = byId("cpSwatch");
    var hexEl = byId("cpHex");
    var rgbEl = byId("cpRgb");
    var ctx = canvas.getContext("2d");

    file.addEventListener("change", function () {
      parseImageFile(file, function (img) {
        imageState.pickerImage = img;
        canvas.width = img.width;
        canvas.height = img.height;
        ctx.drawImage(img, 0, 0);
      });
    });

    canvas.addEventListener("click", function (e) {
      if (!imageState.pickerImage) return;
      var rect = canvas.getBoundingClientRect();
      var scaleX = canvas.width / rect.width;
      var scaleY = canvas.height / rect.height;
      var x = Math.floor((e.clientX - rect.left) * scaleX);
      var y = Math.floor((e.clientY - rect.top) * scaleY);
      var pixel = ctx.getImageData(x, y, 1, 1).data;
      var r = pixel[0],
        g = pixel[1],
        b = pixel[2];
      var hex = rgbToHex(r, g, b);
      swatch.style.background = hex;
      hexEl.textContent = "HEX: " + hex;
      rgbEl.textContent = "RGB: rgb(" + r + ", " + g + ", " + b + ")";
    });
  }

  function initCalculator() {
    var display = byId("calcDisplay");
    if (!display) return;

    function safeEval(expr) {
      if (!/^[0-9+\-*/().\s]+$/.test(expr)) return "Error";
      try {
        var result = Function('"use strict"; return (' + expr + ')')();
        if (result === Infinity || result === -Infinity || Number.isNaN(result)) return "Error";
        return String(result);
      } catch (e) {
        return "Error";
      }
    }

    document.querySelectorAll("[data-calc]").forEach(function (btn) {
      btn.addEventListener("click", function () {
        var v = btn.getAttribute("data-calc");
        if (v === "C") {
          display.value = "0";
          return;
        }
        if (v === "=") {
          display.value = safeEval(display.value);
          return;
        }
        if (display.value === "0" || display.value === "Error") {
          display.value = v;
        } else {
          display.value += v;
        }
      });
    });
  }

  function initPercentageCalculator() {
    var result = byId("pcResult");
    if (!result) return;

    byId("pcCalc").addEventListener("click", function () {
      var p = Number(byId("pcPercent").value);
      var v = Number(byId("pcValue").value);
      var from = Number(byId("pcFrom").value);
      var to = Number(byId("pcTo").value);

      var lines = [];
      if (!Number.isNaN(p) && !Number.isNaN(v)) {
        lines.push(p + "% of " + v + " = " + ((p / 100) * v).toFixed(4).replace(/\.0+$/, ""));
      }
      if (!Number.isNaN(from) && !Number.isNaN(to) && from !== 0) {
        var change = ((to - from) / from) * 100;
        lines.push("Change from " + from + " to " + to + " = " + change.toFixed(2) + "%");
      }
      result.textContent = lines.length ? lines.join(" | ") : "Enter valid values first.";
    });
  }

  function initAgeCalculator() {
    var birth = byId("acBirth");
    if (!birth) return;
    var result = byId("acResult");

    byId("acCalc").addEventListener("click", function () {
      if (!birth.value) {
        result.textContent = "Please select date of birth.";
        return;
      }
      var dob = new Date(birth.value);
      var now = new Date();
      if (dob > now) {
        result.textContent = "Date of birth cannot be in the future.";
        return;
      }

      var years = now.getFullYear() - dob.getFullYear();
      var months = now.getMonth() - dob.getMonth();
      var days = now.getDate() - dob.getDate();

      if (days < 0) {
        months -= 1;
        var prevMonth = new Date(now.getFullYear(), now.getMonth(), 0);
        days += prevMonth.getDate();
      }
      if (months < 0) {
        years -= 1;
        months += 12;
      }

      result.textContent =
        "Age: " + years + " years, " + months + " months, " + days + " days.";
    });
  }

  function initBmiCalculator() {
    var result = byId("bmiResult");
    if (!result) return;

    byId("bmiCalc").addEventListener("click", function () {
      var w = Number(byId("bmiWeight").value);
      var hCm = Number(byId("bmiHeight").value);
      if (Number.isNaN(w) || Number.isNaN(hCm) || w <= 0 || hCm <= 0) {
        result.textContent = "Enter valid weight and height.";
        return;
      }
      var h = hCm / 100;
      var bmi = w / (h * h);
      var label = "Normal";
      if (bmi < 18.5) label = "Underweight";
      else if (bmi >= 25 && bmi < 30) label = "Overweight";
      else if (bmi >= 30) label = "Obese";
      result.textContent = "BMI: " + bmi.toFixed(2) + " (" + label + ")";
    });
  }

  function initRandomNumberGenerator() {
    var result = byId("rngResult");
    if (!result) return;

    byId("rngGenerate").addEventListener("click", function () {
      var min = Number(byId("rngMin").value);
      var max = Number(byId("rngMax").value);
      if (Number.isNaN(min) || Number.isNaN(max)) {
        result.textContent = "Enter valid min and max values.";
        return;
      }
      if (min > max) {
        var t = min;
        min = max;
        max = t;
      }
      var n = Math.floor(Math.random() * (max - min + 1)) + min;
      result.textContent = String(n);
    });
  }

  function initTodoList() {
    var input = byId("tdInput");
    if (!input) return;
    var listEl = byId("tdList");
    var countEl = byId("tdCount");
    var key = "wt_todo_list";

    function getItems() {
      try {
        return JSON.parse(localStorage.getItem(key) || "[]");
      } catch (e) {
        return [];
      }
    }

    function saveItems(items) {
      localStorage.setItem(key, JSON.stringify(items));
    }

    function render() {
      var items = getItems();
      listEl.innerHTML = "";
      items.forEach(function (item, idx) {
        var row = document.createElement("div");
        row.className = "wt-todo-item" + (item.done ? " done" : "");

        var cb = document.createElement("input");
        cb.type = "checkbox";
        cb.checked = !!item.done;
        cb.addEventListener("change", function () {
          items[idx].done = cb.checked;
          saveItems(items);
          render();
        });

        var txt = document.createElement("span");
        txt.textContent = item.text;

        var del = document.createElement("button");
        del.className = "wt-todo-del";
        del.textContent = "x";
        del.addEventListener("click", function () {
          items.splice(idx, 1);
          saveItems(items);
          render();
        });

        row.appendChild(cb);
        row.appendChild(txt);
        row.appendChild(del);
        listEl.appendChild(row);
      });

      var done = items.filter(function (x) {
        return x.done;
      }).length;
      countEl.textContent = "Total: " + items.length + " | Completed: " + done;
    }

    byId("tdAdd").addEventListener("click", function () {
      var value = (input.value || "").trim();
      if (!value) return;
      var items = getItems();
      items.push({ text: value, done: false });
      saveItems(items);
      input.value = "";
      render();
    });

    input.addEventListener("keydown", function (e) {
      if (e.key === "Enter") {
        e.preventDefault();
        byId("tdAdd").click();
      }
    });

    render();
  }

  function initNotes() {
    var input = byId("ntInput");
    if (!input) return;
    var meta = byId("ntMeta");
    var key = "wt_notes";
    var keyMeta = "wt_notes_meta";

    function renderMeta() {
      var stamp = localStorage.getItem(keyMeta);
      meta.textContent = stamp ? "Last saved: " + stamp : "Not saved yet.";
    }

    input.value = localStorage.getItem(key) || "";
    renderMeta();

    input.addEventListener("input", function () {
      localStorage.setItem(key, input.value);
      var now = new Date().toLocaleString();
      localStorage.setItem(keyMeta, now);
      renderMeta();
    });

    byId("ntClear").addEventListener("click", function () {
      input.value = "";
      localStorage.removeItem(key);
      localStorage.removeItem(keyMeta);
      renderMeta();
    });
  }

  function initTimer() {
    var minEl = byId("tmMinutes");
    if (!minEl) return;
    var secEl = byId("tmSeconds");
    var display = byId("tmDisplay");
    var interval = null;
    var remaining = 0;

    function format(s) {
      var m = Math.floor(s / 60);
      var sec = s % 60;
      return String(m).padStart(2, "0") + ":" + String(sec).padStart(2, "0");
    }

    function updateDisplay() {
      display.textContent = format(remaining);
    }

    function readInput() {
      var m = Number(minEl.value) || 0;
      var s = Number(secEl.value) || 0;
      if (m < 0) m = 0;
      if (s < 0) s = 0;
      if (s > 59) s = 59;
      remaining = m * 60 + s;
      updateDisplay();
    }

    byId("tmStart").addEventListener("click", function () {
      if (interval) return;
      if (remaining <= 0) readInput();
      if (remaining <= 0) return;
      interval = setInterval(function () {
        remaining -= 1;
        updateDisplay();
        if (remaining <= 0) {
          clearInterval(interval);
          interval = null;
          display.textContent = "00:00";
          alert("Timer finished.");
        }
      }, 1000);
    });

    byId("tmPause").addEventListener("click", function () {
      if (interval) {
        clearInterval(interval);
        interval = null;
      }
    });

    byId("tmReset").addEventListener("click", function () {
      if (interval) {
        clearInterval(interval);
        interval = null;
      }
      readInput();
    });

    readInput();
  }

  function initStopwatch() {
    var display = byId("swDisplay");
    if (!display) return;
    var laps = byId("swLaps");
    var interval = null;
    var elapsed = 0;

    function format(ms) {
      var totalSec = Math.floor(ms / 1000);
      var min = Math.floor(totalSec / 60);
      var sec = totalSec % 60;
      var centi = Math.floor((ms % 1000) / 10);
      return (
        String(min).padStart(2, "0") +
        ":" +
        String(sec).padStart(2, "0") +
        ":" +
        String(centi).padStart(2, "0")
      );
    }

    function render() {
      display.textContent = format(elapsed);
    }

    byId("swStart").addEventListener("click", function () {
      if (interval) return;
      var last = Date.now();
      interval = setInterval(function () {
        var now = Date.now();
        elapsed += now - last;
        last = now;
        render();
      }, 30);
    });

    byId("swPause").addEventListener("click", function () {
      if (interval) {
        clearInterval(interval);
        interval = null;
      }
    });

    byId("swLap").addEventListener("click", function () {
      var row = document.createElement("div");
      row.className = "wt-todo-item";
      row.innerHTML = "<span>Lap: " + format(elapsed) + "</span>";
      laps.prepend(row);
    });

    byId("swReset").addEventListener("click", function () {
      if (interval) {
        clearInterval(interval);
        interval = null;
      }
      elapsed = 0;
      laps.innerHTML = "";
      render();
    });

    render();
  }

  function initRandomPicker() {
    var input = byId("rpInput");
    if (!input) return;
    var result = byId("rpResult");

    byId("rpPick").addEventListener("click", function () {
      var items = (input.value || "")
        .split(/\r?\n/)
        .map(function (x) {
          return x.trim();
        })
        .filter(function (x) {
          return x.length > 0;
        });

      if (!items.length) {
        result.textContent = "Add at least one item.";
        return;
      }
      var pick = items[Math.floor(Math.random() * items.length)];
      result.textContent = pick;
    });
  }

  var registry = {
    "word-counter": initWordCounter,
    "character-counter": initCharacterCounter,
    "text-case-converter": initTextCaseConverter,
    "remove-duplicate-lines": initRemoveDuplicateLines,
    "text-sorter": initTextSorter,
    "text-compare": initTextCompare,

    "json-formatter": initJsonFormatter,
    "base64-encode-decode": initBase64,
    "url-encoder-decoder": initUrlEncoderDecoder,
    "color-converter": initColorConverter,
    "unit-converter": initUnitConverter,

    "password-generator": initPasswordGenerator,
    "uuid-generator": initUuidGenerator,
    "hash-generator": initHashGenerator,
    "regex-tester": initRegexTester,
    "timestamp-converter": initTimestampConverter,

    "image-resizer": initImageResizer,
    "image-cropper": initImageCropper,
    "image-to-base64": initImageToBase64,
    "image-compressor": initImageCompressor,
    "color-picker": initColorPicker,

    calculator: initCalculator,
    "percentage-calculator": initPercentageCalculator,
    "age-calculator": initAgeCalculator,
    "bmi-calculator": initBmiCalculator,
    "random-number-generator": initRandomNumberGenerator,

    "todo-list": initTodoList,
    notes: initNotes,
    timer: initTimer,
    stopwatch: initStopwatch,
    "random-picker": initRandomPicker,
  };

  if (registry[tool]) registry[tool]();
})();
