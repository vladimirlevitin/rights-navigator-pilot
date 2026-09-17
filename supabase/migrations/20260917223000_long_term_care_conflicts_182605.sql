-- Case 9: distinguish general disability from benefits that require choosing instead of long-term care.

insert into public.sources (slug, publisher, title, url, language, is_official, is_published, checked_on) values
  ('btl-long-term-care-benefit-choice-current', 'Битуах Леуми', 'Условия права на пособие по уходу — сочетание с другими пособиями', 'https://www.btl.gov.il/benefits/Long_Term_Care/Pages/zakaut.aspx', 'he', true, true, '2026-09-17'),
  ('btl-long-term-care-income-current', 'Битуах Леуми', 'Доходы, учитываемые при проверке права на пособие по уходу', 'https://www.btl.gov.il/benefits/Long_Term_Care/Pages/income.aspx', 'he', true, true, '2026-09-17')
on conflict (slug) do update set publisher=excluded.publisher, title=excluded.title, url=excluded.url, language=excluded.language, is_official=excluded.is_official, is_published=true, checked_on=excluded.checked_on;

insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id,
  'long-term-care-benefit-interactions',
  'Пособие по уходу: с какими выплатами нужно выбирать, а какие влияют через доход',
  'Битуах Леуми требует выбрать между пособием по уходу и некоторыми другими выплатами по уходу, в частности пособием по особым услугам (שר״מ). Общая инвалидность сама по себе не указана в этом перечне как выплата, требующая выбора, но её сумма учитывается как доход при проверке размера/права на пособие по уходу.',
  'Для практического ответа важно сначала назвать точную выплату. «Общая инвалидность» и «особые услуги» — не одно и то же. Если человек получает или оформляет именно общую инвалидность, нельзя автоматически говорить, что метапелет отменят из-за несовместимости. Но сумма общей инвалидности входит в доход, учитываемый при проверке пособия по уходу. Если речь о пособии по особым услугам, Битуах Леуми прямо требует выбрать между ним и пособием по уходу.',
  array['Уточните точное название пособия: общая инвалидность или особые услуги.','Если речь об общей инвалидности, проверьте совокупный доход, потому что эта выплата учитывается в доходном тесте пособия по уходу.','Если речь об особых услугах, до подачи/перехода уточните в Битуах Леуми, какую выплату выгоднее сохранить, поскольку одновременно эти две выплаты не предоставляются по обычному правилу.','После любого изменения выплаты проверьте новое решение по пособию по уходу и количество часов/услуг.'],
  array['Решение о текущем пособии по уходу','Решение/заявление по общей инвалидности или особым услугам','Сведения о доходах, учитываемых для пособия по уходу'],
  array['Речь именно об общей инвалидности или о пособии по особым услугам (שר״מ)?'],
  array['Общая инвалидность не указана на странице Битуах Леуми среди выплат, с которыми требуется обязательный выбор вместо пособия по уходу; это не означает, что она никогда не повлияет на размер пособия — она учитывается в доходе.','Для заявления на общую инвалидность дополнительно действует возрастной срок подачи, связанный с пенсионным возрастом.'],
  '[]'::jsonb,
  array['метапелет','союд','сיעוד','общая инвалидность','особые услуги','шарам','שרמ','одновременно','доход'],
  'пособие по уходу метапелет общая инвалидность одновременно отменят уход особые услуги שרמ выбор доход учитывается онкология пенсионный возраст'
from public.topics t join public.sources s on s.slug='btl-long-term-care-benefit-choice-current'
where t.slug='old_age'
on conflict (slug) do update set
  topic_id=excluded.topic_id, source_id=excluded.source_id, title=excluded.title,
  short_answer=excluded.short_answer, answer=excluded.answer, steps=excluded.steps,
  documents=excluded.documents, follow_up_questions=excluded.follow_up_questions,
  caveats=excluded.caveats, keywords=excluded.keywords, search_text=excluded.search_text,
  is_published=true, reviewed_on='2026-09-17', ai_embedding_allowed=true, embedding=null;
