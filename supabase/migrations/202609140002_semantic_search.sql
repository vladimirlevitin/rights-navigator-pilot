create table public.navigator_rate_limits (
  client_key text primary key,
  window_start timestamptz not null default now(),
  request_count integer not null default 0,
  constraint navigator_rate_limits_nonnegative check (request_count >= 0)
);

alter table public.knowledge_cards
add column ai_embedding_allowed boolean not null default false;

-- Only the clean-room cards shipped with this pilot are approved for external embedding.
update public.knowledge_cards set ai_embedding_allowed = true
where slug in (
  'eligibility-basics','register-employment-service','qualifying-period',
  'voluntary-resignation','fired-contract-end','unpaid-leave',
  'entitlement-days','payment-timing','missed-appointment',
  'travel-abroad','age-retirement','self-employed'
);

alter table public.navigator_rate_limits enable row level security;
revoke all on public.navigator_rate_limits from anon, authenticated;

create index knowledge_cards_embedding_hnsw_idx
on public.knowledge_cards
using hnsw (embedding vector_cosine_ops);

create or replace function public.match_knowledge_semantic(
  query_embedding extensions.vector(1536),
  match_count integer default 5
)
returns table (
  slug text,
  title text,
  short_answer text,
  answer text,
  steps text[],
  documents text[],
  follow_up_questions text[],
  caveats text[],
  hebrew_terms jsonb,
  source_title text,
  source_url text,
  reviewed_on date,
  score real
)
language sql
stable
security invoker
set search_path = pg_catalog, public, extensions
as $$
  select
    k.slug,
    k.title,
    k.short_answer,
    k.answer,
    k.steps,
    k.documents,
    k.follow_up_questions,
    k.caveats,
    k.hebrew_terms,
    s.title,
    s.url,
    k.reviewed_on,
    (1 - (k.embedding <=> query_embedding))::real as score
  from public.knowledge_cards k
  join public.sources s on s.id = k.source_id
  where k.is_published and s.is_published and k.ai_embedding_allowed and k.embedding is not null
  order by k.embedding <=> query_embedding
  limit least(greatest(match_count, 1), 10);
$$;

revoke all on function public.match_knowledge_semantic(extensions.vector, integer) from public, anon, authenticated;
grant execute on function public.match_knowledge_semantic(extensions.vector, integer) to service_role;

create or replace function public.consume_navigator_quota(
  p_client_key text,
  p_limit integer default 30
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_count integer;
  safe_limit integer := least(greatest(p_limit, 1), 60);
begin
  if p_client_key is null or length(p_client_key) < 16 or length(p_client_key) > 100 then
    return false;
  end if;

  insert into public.navigator_rate_limits(client_key, window_start, request_count)
  values (p_client_key, pg_catalog.now(), 1)
  on conflict (client_key) do update set
    window_start = case
      when public.navigator_rate_limits.window_start < pg_catalog.now() - interval '1 hour'
      then pg_catalog.now()
      else public.navigator_rate_limits.window_start
    end,
    request_count = case
      when public.navigator_rate_limits.window_start < pg_catalog.now() - interval '1 hour'
      then 1
      else public.navigator_rate_limits.request_count + 1
    end
  returning request_count into current_count;

  return current_count <= safe_limit;
end;
$$;

revoke all on function public.consume_navigator_quota(text, integer) from public, anon, authenticated;
grant execute on function public.consume_navigator_quota(text, integer) to service_role;

comment on table public.navigator_rate_limits is 'Anonymous hourly request counters. Stores no questions, IP addresses, or user details.';
comment on function public.match_knowledge_semantic(extensions.vector, integer) is 'Server-only cosine similarity search over published knowledge cards.';
