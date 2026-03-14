(function () {
  "use strict";

  var CONFIG = {
    loginPath: "/admin/login.html",
    legacyLoginPaths: ["/admin-login.html"],
    protectedPaths: ["/admin/dashboard.html", "/dashboard.html"],
    rolePermissions: {
      admin: ["/admin/dashboard.html", "/dashboard.html"],
      editor: ["/admin/dashboard.html"],
      viewer: []
    },
    sessionKey: "lookforit_admin_session",
    analyticsKey: "lookforit_admin_analytics",
    sessionHours: 12,
    passwordHash: "5916382234b7710c8637c7ac9bcefa76c944dc626418db735907178e1875bd8a"
  };

  function nowMs() {
    return Date.now();
  }

  function normalizePath(path) {
    if (!path) {
      return "/";
    }

    var clean = path.trim();
    if (!clean.startsWith("/")) {
      clean = "/" + clean;
    }

    if (clean.length > 1 && clean.endsWith("/")) {
      clean = clean.substring(0, clean.length - 1);
    }

    return clean.toLowerCase();
  }

  function currentPath() {
    return normalizePath(window.location.pathname);
  }

  function isProtectedPage() {
    var path = currentPath();
    return CONFIG.protectedPaths.indexOf(path) >= 0;
  }

  function isLoginPage() {
    var path = currentPath();
    if (path === normalizePath(CONFIG.loginPath)) {
      return true;
    }

    return CONFIG.legacyLoginPaths.some(function (p) {
      return path === normalizePath(p);
    });
  }

  function trackAdminEvent(eventName, detail) {
    try {
      var raw = localStorage.getItem(CONFIG.analyticsKey);
      var events = raw ? JSON.parse(raw) : [];
      events.push({
        at: new Date().toISOString(),
        event: eventName,
        path: currentPath(),
        detail: detail || {}
      });

      if (events.length > 200) {
        events = events.slice(events.length - 200);
      }

      localStorage.setItem(CONFIG.analyticsKey, JSON.stringify(events));
    } catch (_e) {
    }
  }

  function getSession() {
    try {
      var raw = localStorage.getItem(CONFIG.sessionKey);
      if (!raw) {
        return null;
      }

      return JSON.parse(raw);
    } catch (_e) {
      return null;
    }
  }

  function isSessionValid(session) {
    if (!session || typeof session.expiresAt !== "number") {
      return false;
    }

    return session.expiresAt > nowMs();
  }

  function setSession(role) {
    var issuedAt = nowMs();
    var expiresAt = issuedAt + CONFIG.sessionHours * 60 * 60 * 1000;
    var safeRole = role || "admin";
    localStorage.setItem(
      CONFIG.sessionKey,
      JSON.stringify({ issuedAt: issuedAt, expiresAt: expiresAt, role: safeRole })
    );
    trackAdminEvent("login_success", { role: safeRole });
  }

  function clearSession() {
    localStorage.removeItem(CONFIG.sessionKey);
    trackAdminEvent("logout", {});
  }

  function getNextPath() {
    try {
      var next = new URLSearchParams(window.location.search).get("next") || "/dashboard.html";
      return normalizePath(next);
    } catch (_e) {
      return "/dashboard.html";
    }
  }

  function redirectToLogin() {
    var next = encodeURIComponent(currentPath());
    window.location.replace(CONFIG.loginPath + "?next=" + next);
  }

  function hasPermission(session) {
    var role = (session && session.role) || "viewer";
    var allow = CONFIG.rolePermissions[role] || [];
    var path = currentPath();
    return allow.some(function (p) {
      return normalizePath(p) === path;
    });
  }

  function toHex(buffer) {
    var bytes = new Uint8Array(buffer);
    var hex = [];

    for (var i = 0; i < bytes.length; i += 1) {
      var h = bytes[i].toString(16);
      hex.push(h.length === 1 ? "0" + h : h);
    }

    return hex.join("");
  }

  function hashPassword(password) {
    var encoder = new TextEncoder();
    var bytes = encoder.encode(password || "");
    return window.crypto.subtle.digest("SHA-256", bytes).then(toHex);
  }

  function bindLogoutButton() {
    var logout = document.getElementById("adminLogout");
    if (!logout) {
      return;
    }

    logout.addEventListener("click", function () {
      clearSession();
      redirectToLogin();
    });
  }

  function showLoginMessage(message, ok) {
    var status = document.getElementById("loginStatus");
    if (!status) {
      return;
    }

    status.textContent = message;
    status.style.color = ok ? "#0f5132" : "#842029";
  }

  function bindLoginForm() {
    var form = document.getElementById("adminLoginForm");
    var input = document.getElementById("adminPassword");

    if (!form || !input) {
      return;
    }

    form.addEventListener("submit", function (event) {
      event.preventDefault();

      hashPassword(input.value)
        .then(function (hash) {
          if (hash === CONFIG.passwordHash) {
            setSession("admin");
            showLoginMessage("Login successful. Redirecting...", true);
            window.location.replace(getNextPath());
            return;
          }

          trackAdminEvent("login_failed", {});
          showLoginMessage("Invalid password. Please try again.", false);
        })
        .catch(function () {
          trackAdminEvent("login_error", {});
          showLoginMessage("Unable to validate password in this browser.", false);
        });
    });
  }

  function init() {
    var session = getSession();
    var valid = isSessionValid(session);

    if (isLoginPage()) {
      if (valid) {
        trackAdminEvent("login_bypass_existing_session", {});
        window.location.replace(getNextPath());
        return;
      }

      bindLoginForm();
      return;
    }

    if (isProtectedPage()) {
      if (!valid) {
        trackAdminEvent("blocked_no_session", {});
        redirectToLogin();
        return;
      }

      if (!hasPermission(session)) {
        trackAdminEvent("blocked_role", { role: session.role || "viewer" });
        redirectToLogin();
        return;
      }

      bindLogoutButton();
    }
  }

  window.LookforitAdminAccess = {
    clearSession: clearSession,
    isSessionValid: function () {
      return isSessionValid(getSession());
    },
    getAnalyticsEvents: function () {
      try {
        return JSON.parse(localStorage.getItem(CONFIG.analyticsKey) || "[]");
      } catch (_e) {
        return [];
      }
    },
    clearAnalyticsEvents: function () {
      localStorage.removeItem(CONFIG.analyticsKey);
    }
  };

  document.addEventListener("DOMContentLoaded", init);
})();
