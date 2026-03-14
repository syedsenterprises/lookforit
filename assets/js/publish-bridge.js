/**
 * publish-bridge.js — LookforitPublishBridge
 *
 * Registers window.LookforitPublishBridge.submit(request) so the
 * "Publish Now" button in admin/dashboard.html can POST the content
 * request to a real webhook or local automation endpoint.
 *
 * SETUP:
 *   1. Set BRIDGE_ENDPOINT to your webhook URL (e.g. a Cloudflare Worker,
 *      n8n/Make webhook, or a local node/python server that runs create-article.ps1).
 *   2. Optionally set BRIDGE_SECRET to a shared secret header value.
 *   3. Load this file BEFORE content-dashboard.js in dashboard pages:
 *        <script src="../assets/js/publish-bridge.js"></script>
 *        <script src="../assets/js/content-dashboard.js"></script>
 *
 * REQUEST SHAPE (sent as JSON body):
 *   {
 *     requestedAt: ISO string,
 *     slug:        "my-article-slug",
 *     title:       "Article Title",
 *     roleRequired: "admin",
 *     source:      "dashboard",
 *     command:     "pwsh create-article.ps1 ...",
 *     payload:     { ...form fields... },
 *     draftText:   "Full draft HTML string"
 *   }
 *
 * RESPONSE expected from endpoint:
 *   { ok: true, message: "Published successfully" }   — success
 *   { ok: false, error: "reason" }                    — failure
 */

(function () {
  'use strict';

  /* -------------------------------------------------------------------------
   * CONFIGURATION — edit these to match your setup
   * ----------------------------------------------------------------------- */
  var CONFIG = {
    /** Webhook URL that receives the publish request as a POST with JSON body.
     *  Set to empty string "" to disable network posting (falls back to download). */
    endpoint: "",

    /** Optional shared-secret header value. Your endpoint should validate this.
     *  Leave empty to skip the header. */
    secret: "",

    /** Header name for the secret token */
    secretHeader: "X-Lookforit-Token",

    /** Request timeout in milliseconds */
    timeoutMs: 10000
  };

  /* -------------------------------------------------------------------------
   * Bridge implementation
   * ----------------------------------------------------------------------- */
  function submit(request) {
    return new Promise(function (resolve, reject) {
      if (!CONFIG.endpoint) {
        resolve({ ok: false, fallback: true, message: "No endpoint configured — falling back to download." });
        return;
      }

      var controller = typeof AbortController !== "undefined" ? new AbortController() : null;
      var timeoutId = null;
      if (controller) {
        timeoutId = setTimeout(function () { controller.abort(); }, CONFIG.timeoutMs);
      }

      var headers = { "Content-Type": "application/json" };
      if (CONFIG.secret && CONFIG.secretHeader) {
        headers[CONFIG.secretHeader] = CONFIG.secret;
      }

      var fetchOpts = {
        method: "POST",
        headers: headers,
        body: JSON.stringify(request)
      };
      if (controller) { fetchOpts.signal = controller.signal; }

      fetch(CONFIG.endpoint, fetchOpts)
        .then(function (res) {
          if (timeoutId) clearTimeout(timeoutId);
          return res.json();
        })
        .then(function (data) {
          if (data && data.ok) {
            resolve(data);
          } else {
            reject(new Error((data && data.error) || "Bridge endpoint returned ok:false"));
          }
        })
        .catch(function (err) {
          if (timeoutId) clearTimeout(timeoutId);
          var msg = (err && err.name === "AbortError")
            ? "Bridge request timed out after " + (CONFIG.timeoutMs / 1000) + "s"
            : (err && err.message) || "Bridge request failed";
          reject(new Error(msg));
        });
    });
  }

  /* -------------------------------------------------------------------------
   * Expose API — allows content-dashboard.js to call window.LookforitPublishBridge.submit()
   * ----------------------------------------------------------------------- */
  window.LookforitPublishBridge = {
    submit: submit,
    /** Call this from your own code to update endpoint/secret at runtime */
    configure: function (opts) {
      if (opts.endpoint !== undefined) CONFIG.endpoint = opts.endpoint;
      if (opts.secret !== undefined) CONFIG.secret = opts.secret;
      if (opts.secretHeader !== undefined) CONFIG.secretHeader = opts.secretHeader;
      if (opts.timeoutMs !== undefined) CONFIG.timeoutMs = opts.timeoutMs;
    },
    isConfigured: function () { return !!CONFIG.endpoint; }
  };

})();
