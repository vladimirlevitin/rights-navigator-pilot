create extension if not exists vector with schema extensions;
create extension if not exists pg_trgm with schema extensions;

create table public.topics (
  id bigint generated always as identity primary key,
  slug text not null unique,
  title text not null,
  description text not null default '',
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.sources (
  id bigint generated always as identity primary key,
  slug text not null unique,
  publisher text not null,
  title text not null,
  url text not null unique,
  language text not null default 'ru',
  is_official boolean not null default false,
  is_published boolean not null default false,
  checked_on date not null,
  created_at timestamptz not null default now()
);

create table public.knowledge_cards (
  id bigint generated always as identity primary key,
  topic_id bigint not null references public.topics(id) on delete restrict,
  source_id bigint not null references public.sources(id) on delete restrict,
  slug text not null unique,
  title text not null,
  short_answer text not null,
  answer text not null,
  steps text[] not null default '{}',
  documents text[] not null default '{}',
  follow_up_questions text[] not null default '{}',
  caveats text[] not null default '{}',
  hebrew_terms jsonb not null default '[]'::jsonb,
  keywords text[] not null default '{}',
  search_text text not null,
  search_vector tsvector generated always as (
    setweight(to_tsvector('simple', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('simple', coalesce(search_text, '')), 'B') ||
    setweight(to_tsvector('simple', coalesce(short_answer, '')), 'C')
  ) stored,
  embedding extensions.vector(1536),
  is_published boolean not null default false,
  reviewed_on date not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.demo_scenarios (
  id bigint generated always as identity primary key,
  topic_id bigint not null references public.topics(id) on delete cascade,
  question text not null unique,
  hint text not null default '',
  display_order integer not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now()
);

create index knowledge_cards_topic_id_idx on public.knowledge_cards(topic_id);
create index knowledge_cards_source_id_idx on public.knowledge_cards(source_id);
create index knowledge_cards_published_idx on public.knowledge_cards(is_published) where is_published;
create index knowledge_cards_search_vector_idx on public.knowledge_cards using gin(search_vector);
create index knowledge_cards_search_text_trgm_idx on public.knowledge_cards using gin(search_text extensions.gin_trgm_ops);
create index demo_scenarios_topic_id_idx on public.demo_scenarios(topic_id);

alter table public.topics enable row level security;
alter table public.sources enable row level security;
alter table public.knowledge_cards enable row level security;
alter table public.demo_scenarios enable row level security;

create policy "Published topics are public"
on public.topics for select to anon, authenticated
using (is_published);

create policy "Published sources are public"
on public.sources for select to anon, authenticated
using (is_published);

create policy "Published knowledge cards are public"
on public.knowledge_cards for select to anon, authenticated
using (is_published);

create policy "Published demo scenarios are public"
on public.demo_scenarios for select to anon, authenticated
using (is_published);

revoke all on public.topics, public.sources, public.knowledge_cards, public.demo_scenarios from anon, authenticated;
grant usage on schema public to anon, authenticated;
grant select on public.topics, public.sources, public.knowledge_cards, public.demo_scenarios to anon, authenticated;

create or replace function public.search_knowledge(
  query_text text,
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
  with input as (
    select
      trim(coalesce(query_text, '')) as q,
      websearch_to_tsquery('simple', trim(coalesce(query_text, ''))) as tsq
  )
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
    s.title as source_title,
    s.url as source_url,
    k.reviewed_on,
    greatest(
      ts_rank_cd(k.search_vector, input.tsq),
      similarity(k.search_text, input.q),
      case when k.search_text ilike '%' || input.q || '%' then 0.85 else 0 end
    )::real as score
  from public.knowledge_cards k
  join public.sources s on s.id = k.source_id
  cross join input
  where length(input.q) >= 2
    and k.is_published
    and s.is_published
    and (
      k.search_vector @@ input.tsq
      or similarity(k.search_text, input.q) > 0.06
      or k.search_text ilike '%' || input.q || '%'
    )
  order by score desc, k.reviewed_on desc
  limit least(greatest(match_count, 1), 10);
$$;

revoke all on function public.search_knowledge(text, integer) from public;
grant execute on function public.search_knowledge(text, integer) to anon, authenticated;

comment on table public.knowledge_cards is 'Curated, source-backed knowledge cards. No Facebook or personal data in the pilot.';
comment on function public.search_knowledge(text, integer) is 'Read-only keyword/fuzzy search. A nullable vector column is reserved for semantic search in the next phase.';
