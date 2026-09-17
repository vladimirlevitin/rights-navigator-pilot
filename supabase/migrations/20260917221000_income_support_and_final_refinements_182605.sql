-- Final operational refinement for batch 182605: income support after disability benefit changes.

insert into public.topics (slug, title, description, is_published)
values ('income_support', 'Обеспечение прожиточного минимума', 'Пособие по обеспечению прожиточного минимума (הבטחת הכנסה), доходные условия, регистрация и освобождения.', true)
on conflict (slug) do update set title=excluded.title, description=excluded.description, is_published=true, updated_at=now();

insert into public.sources (slug, publisher, title, url, language, is_official, is_published, checked_on) values
  ('btl-income-support-eligibility-current', 'Битуах Леуми', 'Условия права на пособие по обеспечению прожиточного минимума', 'https://www.btl.gov.il/benefits/Income_support/Pages/zacautnew.aspx', 'he', true, true, '2026-09-17'),
  ('btl-income-support-employment-exemption-current', 'Битуах Леуми', 'Освобождение от регистрации в Службе занятости — обеспечение прожиточного минимума', 'https://www.btl.gov.il/benefits/Income_support/Pages/ptor.aspx', 'he', true, true, '2026-09-17')
on conflict (slug) do update set publisher=excluded.publisher, title=excluded.title, url=excluded.url, language=excluded.language, is_official=excluded.is_official, is_published=true, checked_on=excluded.checked_on;

insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id,
  'income-support-after-disability-end',
  'Что делать, если пособие по инвалидности прекращается и нужен прожиточный минимум',
  'Прекращение пособия по общей инвалидности не создаёт автоматического права на обеспечение прожиточного минимума. Это отдельное заявление: Битуах Леуми проверяет резидентство, возраст, доходы семьи, имущество/автомобиль и обычно регистрацию в Службе занятости или основание для освобождения.',
  'Пособие по обеспечению прожиточного минимума (הבטחת הכנסה) — не пособие по безработице. После прекращения инвалидности его нужно проверять отдельно. Если человек из-за состояния здоровья не способен работать более 30 дней подряд, он может просить освобождение от регистрации в Службе занятости на основании медицинских документов; такое освобождение по болезни может предоставляться максимум на шесть месяцев. При обычной проверке учитываются доходы заявителя и супруга/супруги, а также автомобиль, недвижимость и финансовые активы.',
  array['Не ждите автоматического перевода: отдельно проверьте право на обеспечение прожиточного минимума и подайте заявление, если условия подходят.','Подготовьте сведения о доходах всей семьи, автомобиле, недвижимости и финансовых активах.','Если вы способны работать — проверьте обязанность регистрации и отметок в Службе занятости.','Если по состоянию здоровья вы не способны работать более 30 дней подряд, приложите актуальные медицинские документы и попросите проверить освобождение от регистрации.','После решения проверьте дату начала права и письменный расчёт выплаты.'],
  array['Документы о доходах заявителя и супруга/супруги','Сведения об автомобиле и имуществе','Банковские/финансовые сведения по требованию','Медицинские документы — если просите освобождение от регистрации','Решение о прекращении/изменении пособия по инвалидности'],
  array['Можете ли вы сейчас работать и регистрироваться в Службе занятости, или врач подтверждает неспособность работать более 30 дней подряд?'],
  array['Это не автала: у обеспечения прожиточного минимума свои условия и семейная проверка доходов/имущества.','Само снижение степени инвалидности не гарантирует и не исключает это пособие.','Если человек просит медицинское освобождение от регистрации, нужны подтверждающие документы; освобождение по болезни ограничено по сроку.'],
  '[]'::jsonb,
  array['прожиточный минимум','обеспечение прожиточного минимума','автала не то же','הבטחת הכנסה','инвалидность прекратилась','55%','Служба занятости'],
  'после прекращения пособия инвалидность снизили 55 прожиточный минимум обеспечение дохода הבטחת הכנסה отдельное заявление доход семья автомобиль имущество служба занятости болезнь 30 дней освобождение'
from public.topics t join public.sources s on s.slug='btl-income-support-eligibility-current'
where t.slug='income_support'
on conflict (slug) do update set
  topic_id=excluded.topic_id, source_id=excluded.source_id, title=excluded.title,
  short_answer=excluded.short_answer, answer=excluded.answer, steps=excluded.steps,
  documents=excluded.documents, follow_up_questions=excluded.follow_up_questions,
  caveats=excluded.caveats, keywords=excluded.keywords, search_text=excluded.search_text,
  is_published=true, reviewed_on='2026-09-17', ai_embedding_allowed=true, embedding=null;
