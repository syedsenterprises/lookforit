export default {
  async fetch(request, env) {
    if (request.method !== 'POST') {
      return new Response('Method Not Allowed', { status: 405 });
    }

    const contentType = request.headers.get('content-type') || '';
    if (!contentType.includes('application/x-www-form-urlencoded') && !contentType.includes('multipart/form-data')) {
      return new Response('Unsupported Media Type', { status: 415 });
    }

    const formData = await request.formData();
    const turnstileToken = formData.get('cf-turnstile-response');
    if (!turnstileToken) {
      return new Response('Missing Turnstile token', { status: 400 });
    }

    const verifyResponse = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        secret: env.TURNSTILE_SECRET_KEY,
        response: turnstileToken,
        remoteip: request.headers.get('CF-Connecting-IP') || ''
      })
    });

    const verifyData = await verifyResponse.json();
    if (!verifyData.success) {
      return new Response(JSON.stringify({ ok: false, error: 'Human verification failed', details: verifyData['error-codes'] || [] }), {
        status: 403,
        headers: { 'content-type': 'application/json; charset=utf-8' }
      });
    }

    formData.delete('cf-turnstile-response');

    const upstream = await fetch(env.FORMSPREE_ENDPOINT, {
      method: 'POST',
      body: formData,
      headers: {
        'Accept': 'application/json'
      }
    });

    const upstreamText = await upstream.text();
    return new Response(upstreamText, {
      status: upstream.status,
      headers: {
        'content-type': upstream.headers.get('content-type') || 'application/json; charset=utf-8',
        'cache-control': 'no-store'
      }
    });
  }
};
