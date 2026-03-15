window.LookforitFormProxy = {
  /* Enable only after worker-side Turnstile verification is confirmed. */
  enabled: true,
  endpoint: "/form-proxy",
  placeholder: "/form-proxy",
  /* Guardrail: if the endpoint returns this health string, treat worker as not ready. */
  healthBlockText: "Form proxy working",
  enforceHealthCheck: true
};