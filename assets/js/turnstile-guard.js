(function () {
  'use strict';

  var proxyHealth = {
    checked: false,
    healthy: true
  };

  function getProxyConfig() {
    return window.LookforitFormProxy || null;
  }

  function isProxyUsable(config) {
    if (!config || !config.enabled) {
      return false;
    }

    if (!config.enforceHealthCheck) {
      return true;
    }

    return proxyHealth.checked && proxyHealth.healthy;
  }

  function runProxyHealthCheck(done) {
    var config = getProxyConfig();

    if (!config || !config.enabled || !config.enforceHealthCheck) {
      proxyHealth.checked = true;
      proxyHealth.healthy = true;
      done();
      return;
    }

    fetch(config.endpoint, {
      method: 'GET',
      credentials: 'same-origin'
    }).then(function (res) {
      return res.text().then(function (txt) {
        var blockText = (config.healthBlockText || '').toLowerCase();
        var body = (txt || '').toLowerCase();
        var blockedByText = blockText && body.indexOf(blockText) !== -1;
        proxyHealth.checked = true;
        proxyHealth.healthy = !blockedByText;
        done();
      });
    }).catch(function () {
      proxyHealth.checked = true;
      proxyHealth.healthy = false;
      done();
    });
  }

  function applyProxyAction(form) {
    var config = getProxyConfig();
    var directAction = form.getAttribute('data-direct-action');
    var workerAction = form.getAttribute('data-worker-action');
    var resolvedWorkerAction = workerAction;

    if (!directAction) {
      directAction = form.getAttribute('action') || '';
      form.setAttribute('data-direct-action', directAction);
    }

    if (config && config.endpoint) {
      if (!resolvedWorkerAction || resolvedWorkerAction === config.placeholder) {
        resolvedWorkerAction = config.endpoint;
      }
    }

    if (config && isProxyUsable(config) && resolvedWorkerAction) {
      form.setAttribute('action', resolvedWorkerAction);
      form.setAttribute('data-active-endpoint', 'worker');
      return;
    }

    form.setAttribute('action', directAction);
    form.setAttribute('data-active-endpoint', 'direct');
  }

  function getTurnstileToken(form) {
    var tokenField = form.querySelector('input[name="cf-turnstile-response"]');
    return tokenField && tokenField.value ? tokenField.value.trim() : '';
  }

  function ensureMessageBox(form) {
    var box = form.querySelector('[data-turnstile-status]');
    if (box) {
      return box;
    }

    box = document.createElement('p');
    box.setAttribute('data-turnstile-status', '');
    box.style.cssText = 'display:none;margin:0.75rem 0 0;color:#fca5a5;font-size:0.9rem;';

    var actions = form.querySelector('.actions');
    if (actions && actions.parentNode) {
      actions.parentNode.appendChild(box);
    } else {
      form.appendChild(box);
    }

    return box;
  }

  function setSubmittingState(form, isSubmitting) {
    var submit = form.querySelector('input[type="submit"], button[type="submit"]');
    if (submit) {
      submit.disabled = isSubmitting;
      if (submit.tagName === 'INPUT') {
        submit.value = isSubmitting ? 'Verifying...' : (submit.getAttribute('data-default-label') || submit.value);
      } else {
        submit.textContent = isSubmitting ? 'Verifying...' : (submit.getAttribute('data-default-label') || submit.textContent);
      }
    }
  }

  function attachGuard(form) {
    var submit = form.querySelector('input[type="submit"], button[type="submit"]');
    if (submit && !submit.getAttribute('data-default-label')) {
      submit.setAttribute('data-default-label', submit.tagName === 'INPUT' ? submit.value : submit.textContent);
    }

    var messageBox = ensureMessageBox(form);
    applyProxyAction(form);

    form.addEventListener('submit', function (event) {
      var token = getTurnstileToken(form);
      if (!token) {
        event.preventDefault();
        messageBox.style.display = '';
        messageBox.textContent = 'Please complete the human verification check before submitting.';
        return;
      }

      messageBox.style.display = 'none';
      setSubmittingState(form, true);
    });
  }

  function init() {
    var forms = document.querySelectorAll('form');
    Array.prototype.forEach.call(forms, function (form) {
      if (form.querySelector('.cf-turnstile')) {
        attachGuard(form);
      }
    });

    runProxyHealthCheck(function () {
      Array.prototype.forEach.call(forms, function (form) {
        if (form.querySelector('.cf-turnstile')) {
          applyProxyAction(form);
        }
      });
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
