-- Better coverage for common, non-legal formulations used in pilot queries.
update public.knowledge_cards
set search_text = case slug
  when 'fired-contract-end' then search_text ||
    ' фирма закрылась компания закрылась предприятие закрылось бизнес закрылся ликвидация'
  when 'voluntary-resignation' then search_text ||
    ' ушел ушла с работы врач запретил продолжать медицинская причина по состоянию здоровья'
  else search_text
end,
embedding = null,
updated_at = now()
where slug in ('fired-contract-end', 'voluntary-resignation');

-- The Edge Function regenerates the two invalidated embeddings lazily.
