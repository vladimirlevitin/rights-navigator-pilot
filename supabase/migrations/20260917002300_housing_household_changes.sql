-- Public-housing household changes: avoid inferring a duty to report a boarding school unless household status actually changes.

insert into public.sources (slug, publisher, title, url, language, is_official, is_published, checked_on) values
  ('gov-public-housing-guide', 'Министерство строительства и жилищного хозяйства', 'Пошаговое руководство по социальному жилью', 'https://www.gov.il/he/pages/public_housing_guide_step_by_step?chapterIndex=3', 'he', true, true, '2026-09-17')
on conflict (slug) do update set
  title=excluded.title,
  url=excluded.url,
  language=excluded.language,
  is_official=excluded.is_official,
  is_published=true,
  checked_on=excluded.checked_on;

insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'housing-household-change',
  'Когда сообщать об изменении состава семьи при социальном жилье',
  'В период права на социальное жильё нужно сообщать компании регистрации об изменении личного статуса или числа детей; сам факт поступления ребёнка в школу-интернат ещё не доказывает, что состав семьи изменился.',
  'Руководство Министерства строительства и жилищного хозяйства требует в период действия права сообщать через компанию регистрации, если изменился личный статус или количество детей, и прикладывать подтверждающие документы. Поступление ребёнка в школу-интернат само по себе не названо отдельным основанием для уведомления. Поэтому сначала нужно установить, изменился ли официальный состав семьи/опека и считается ли ребёнок по-прежнему членом домохозяйства для жилищной программы.',
  array['Уточните официальный статус интерната и сохраняется ли ребёнок в составе семьи/под опекой по документам.','Если официально изменился личный статус или количество детей в составе семьи, сообщите об этом компании регистрации жилищной помощи и приложите документы.','Если состав семьи формально не изменился, не делайте вывод об обязанности уведомлять только из факта обучения в интернате; запросите письменное разъяснение компании при сомнении.'],
  array['Документ о статусе интерната, если он влияет на проживание','Документы об опеке/составе семьи, если они изменились'],
  array['Изменился ли официальный состав семьи или опека над ребёнком?'],
  array['Карточка не утверждает, что обычная школа-интернат автоматически меняет состав семьи для жилищной помощи.'],
  '[]'::jsonb,
  array['социальное жильё','Амигур','интернат','состав семьи','количество детей','сообщить об изменении'],
  'Амигур социальное жилье очередь помощь аренда ребенок интернат школа-интернат состав семьи количество детей личный статус опека сообщить изменение Министерство строительства'
from public.topics t join public.sources s on s.slug='gov-public-housing-guide'
where t.slug='housing_support'
on conflict (slug) do update set
  topic_id=excluded.topic_id,
  source_id=excluded.source_id,
  title=excluded.title,
  short_answer=excluded.short_answer,
  answer=excluded.answer,
  steps=excluded.steps,
  documents=excluded.documents,
  follow_up_questions=excluded.follow_up_questions,
  caveats=excluded.caveats,
  keywords=excluded.keywords,
  search_text=excluded.search_text,
  embedding=null,
  is_published=true,
  reviewed_on=excluded.reviewed_on,
  ai_embedding_allowed=true,
  updated_at=now();