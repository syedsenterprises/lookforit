export default {
  async fetch(request, env) {
    const origin = request.headers.get("Origin") || "";
    const allowedOrigin = (env.FEEDBACK_ALLOWED_ORIGIN || "*").trim();

    function corsHeaders() {
      const allowOrigin = allowedOrigin === "*" ? "*" : (origin === allowedOrigin ? origin : allowedOrigin);
      return {
        "Access-Control-Allow-Origin": allowOrigin,
        "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
        "Vary": "Origin"
      };
    }

    if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: corsHeaders()
      });
    }

    if (!env.FEEDBACK_STORE) {
      return json({ ok: false, error: "FEEDBACK_STORE KV binding is missing" }, 500, corsHeaders());
    }

    if (request.method === "GET") {
      return handleGet(request, env, corsHeaders());
    }

    if (request.method === "POST") {
      return handlePost(request, env, corsHeaders());
    }

    return json({ ok: false, error: "Method Not Allowed" }, 405, corsHeaders());
  }
};

async function handleGet(request, env, baseHeaders) {
  const url = new URL(request.url);
  const page = normalizePage(url.searchParams.get("page"));

  if (!page) {
    return json({ ok: false, error: "Missing page query param" }, 400, baseHeaders);
  }

  const reviews = await readArray(env.FEEDBACK_STORE, reviewsKey(page));
  const comments = await readArray(env.FEEDBACK_STORE, commentsKey(page));

  return json({
    ok: true,
    page: page,
    reviews: reviews,
    comments: comments,
    counts: {
      reviews: reviews.length,
      comments: comments.length
    }
  }, 200, baseHeaders);
}

async function handlePost(request, env, baseHeaders) {
  let payload;
  try {
    payload = await request.json();
  } catch (_err) {
    return json({ ok: false, error: "Invalid JSON body" }, 400, baseHeaders);
  }

  const page = normalizePage(payload && payload.page);
  const type = String((payload && payload.type) || "").toLowerCase();
  const item = payload && payload.item ? payload.item : {};

  if (!page) {
    return json({ ok: false, error: "Missing page" }, 400, baseHeaders);
  }

  if (type !== "review" && type !== "comment") {
    return json({ ok: false, error: "Invalid type" }, 400, baseHeaders);
  }

  const name = sanitizeText(item.name, 60) || "Anonymous";
  const text = sanitizeText(item.text, 800);
  const createdAt = new Date().toISOString();

  if (!text) {
    return json({ ok: false, error: "Text is required" }, 400, baseHeaders);
  }

  if (type === "review") {
    const rating = clampNumber(item.rating, 1, 5);
    if (rating < 1 || rating > 5) {
      return json({ ok: false, error: "Rating must be between 1 and 5" }, 400, baseHeaders);
    }

    const review = {
      name: name,
      text: text,
      rating: rating,
      createdAt: createdAt
    };

    const rows = await readArray(env.FEEDBACK_STORE, reviewsKey(page));
    rows.unshift(review);
    await env.FEEDBACK_STORE.put(reviewsKey(page), JSON.stringify(rows.slice(0, 200)));

    return json({ ok: true, type: "review", item: review }, 200, baseHeaders);
  }

  const comment = {
    name: name,
    text: text,
    createdAt: createdAt
  };

  const rows = await readArray(env.FEEDBACK_STORE, commentsKey(page));
  rows.unshift(comment);
  await env.FEEDBACK_STORE.put(commentsKey(page), JSON.stringify(rows.slice(0, 400)));

  return json({ ok: true, type: "comment", item: comment }, 200, baseHeaders);
}

async function readArray(kv, key) {
  try {
    const raw = await kv.get(key);
    if (!raw) {
      return [];
    }

    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : [];
  } catch (_err) {
    return [];
  }
}

function normalizePage(value) {
  const page = String(value || "").toLowerCase().trim().replace(/[^a-z0-9-]/g, "");
  if (!page) {
    return "";
  }

  return page.slice(0, 140);
}

function sanitizeText(value, maxLen) {
  return String(value || "").replace(/\s+/g, " ").trim().slice(0, maxLen);
}

function clampNumber(value, min, max) {
  const numeric = parseInt(value, 10);
  if (isNaN(numeric)) {
    return min - 1;
  }

  return Math.max(min, Math.min(max, numeric));
}

function reviewsKey(page) {
  return "feedback:v1:reviews:" + page;
}

function commentsKey(page) {
  return "feedback:v1:comments:" + page;
}

function json(body, status, extraHeaders) {
  const headers = Object.assign({
    "Content-Type": "application/json; charset=utf-8",
    "Cache-Control": "no-store"
  }, extraHeaders || {});

  return new Response(JSON.stringify(body), {
    status: status,
    headers: headers
  });
}
