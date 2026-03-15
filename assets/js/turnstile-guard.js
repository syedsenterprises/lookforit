(function () {
  'use strict';

  function getProxyConfig() {
    return window.LookforitFormProxy || null;
  }

  function applyProxyAction(form) {
    var config = getProxyConfig();
    var directAction = form.getAttribute('data-direct-action');
    var workerAction = form.getAttribute('data-worker-action');

    if (!directAction) {
      directAction = form.getAttribute('action') || '';
      form.setAttribute('data-direct-action', directAction);
    }

    if (config && config.enabled && workerAction && workerAction !== config.placeholder) {
      form.setAttribute('action', workerAction);
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
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
