import 'jsr:@supabase/functions-js/edge-runtime.d.ts'

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const OPENAI_API_KEY = Deno.env.get('OPENAI_API_KEY')!
const ALLOWED_ORIGINS = new Set([
  'https://vladimirlevitin.github.io',
  'http://localhost:8000',
  'http://127.0.0.1:8000',
])

function parseNamedKeys(name: string): Record<string, string> {
  try { return JSON.parse(Deno.env.get(name) || '{}') } catch { return {} }
}

const publishableKeys = Object.values(parseNamedKeys('SUPABASE_PUBLISHABLE_KEYS'))
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ||
  Object.values(parseNamedKeys('SUPABASE_SECRET_KEYS'))[0]

function cors(origin: string | null) {
  return {
    'Access-Control-Allow-Origin': origin && ALLOWED_ORIGINS.has(origin) ? origin : 'https://vladimirlevitin.github.io',
    'Access-Control-Allow-Headers': 'apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Vary': 'Origin',
  }
}

function json(body: unknown, status = 200, origin: string | null = null) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors(origin), 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store' },
  })
}

function serviceHeaders() {
  const headers: Record<string, string> = { apikey: serviceKey!, 'Content-Type': 'application/json' }
  if (serviceKey?.startsWith('eyJ')) headers.Authorization = `Bearer ${serviceKey}`
  return headers
}

async function db(path: string, options: RequestInit = {}) {
  const response = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    ...options,
    headers: { ...serviceHeaders(), ...(options.headers || {}) },
  })
  if (!response.ok) throw new Error(`database request failed: ${response.status}`)
  const text = await response.text()
  return text ? JSON.parse(text) : null
}

async function embed(inputs: string[]) {
  const response = await fetch('https://api.openai.com/v1/embeddings', {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${OPENAI_API_KEY}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ model: 'text-embedding-3-small', input: inputs, encoding_format: 'float' }),
  })
  if (!response.ok) throw new Error(`embedding request failed: ${response.status}`)
  const payload = await response.json()
  return payload.data.sort((a: { index: number }, b: { index: number }) => a.index - b.index)
    .map((item: { embedding: number[] }) => item.embedding)
}

function mergeResults(semantic: any[], lexical: any[]) {
  const merged = new Map<string, any>()
  const lexicalMax = Math.max(...lexical.map(item => Number(item.score) || 0), 0.001)

  semantic.forEach(item => merged.set(item.slug, {
    ...item,
    semantic_score: Number(item.score) || 0,
    lexical_score: 0,
  }))
  lexical.forEach(item => {
    const existing = merged.get(item.slug) || { ...item, semantic_score: 0 }
    existing.lexical_score = (Number(item.score) || 0) / lexicalMax
    merged.set(item.slug, existing)
  })

  return [...merged.values()]
    .map(item => ({ ...item, score: item.semantic_score * 0.76 + item.lexical_score * 0.24 }))
    .sort((a, b) => b.score - a.score)
    .slice(0, 5)
}

Deno.serve(async (req: Request) => {
  const origin = req.headers.get('origin')
  if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors(origin) })
  if (req.method !== 'POST') return json({ error: 'method_not_allowed' }, 405, origin)
  if (origin && !ALLOWED_ORIGINS.has(origin)) return json({ error: 'origin_not_allowed' }, 403, origin)

  const suppliedKey = req.headers.get('apikey') || ''
  if (!publishableKeys.includes(suppliedKey)) return json({ error: 'unauthorized' }, 401, origin)
  if (!OPENAI_API_KEY || !serviceKey) return json({ error: 'service_not_configured' }, 503, origin)

  try {
    const body = await req.json()
    const question = String(body.question || '').trim()
    const clientId = String(body.client_id || '')
    if (question.length < 2 || question.length > 800) return json({ error: 'invalid_question' }, 400, origin)
    if (!/^[a-zA-Z0-9-]{16,100}$/.test(clientId)) return json({ error: 'invalid_client' }, 400, origin)

    const quota = await db('rpc/consume_navigator_quota', {
      method: 'POST', body: JSON.stringify({ p_client_key: clientId, p_limit: 30 }),
    })
    if (quota !== true) return json({ error: 'rate_limit', message: 'Лимит: 30 вопросов в час.' }, 429, origin)

    const missing = await db('knowledge_cards?select=id,title,short_answer,search_text&is_published=eq.true&ai_embedding_allowed=eq.true&embedding=is.null')
    const cardInputs = missing.map((card: any) => `${card.title}\n${card.short_answer}\n${card.search_text}`)
    const vectors = await embed([question, ...cardInputs])
    const queryEmbedding = vectors[0]

    if (missing.length) {
      await Promise.all(missing.map((card: any, index: number) => db(`knowledge_cards?id=eq.${card.id}`, {
        method: 'PATCH',
        headers: { Prefer: 'return=minimal' },
        body: JSON.stringify({ embedding: vectors[index + 1] }),
      })))
    }

    const [semantic, lexical] = await Promise.all([
      db('rpc/match_knowledge_semantic', {
        method: 'POST', body: JSON.stringify({ query_embedding: queryEmbedding, match_count: 5 }),
      }),
      db('rpc/search_knowledge', {
        method: 'POST', body: JSON.stringify({ query_text: question, match_count: 5 }),
      }),
    ])

    const topSemantic = Number(semantic[0]?.score) || 0
    if (!lexical.length && topSemantic < 0.38) return json({ search_mode: 'hybrid', results: [] }, 200, origin)
    return json({ search_mode: 'hybrid', results: mergeResults(semantic, lexical) }, 200, origin)
  } catch (error) {
    console.error(error instanceof Error ? error.message : 'semantic search failed')
    return json({ error: 'search_failed' }, 500, origin)
  }
})
