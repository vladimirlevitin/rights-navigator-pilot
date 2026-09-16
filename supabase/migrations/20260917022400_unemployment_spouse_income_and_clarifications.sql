insert into public.sources (slug, publisher, title, url, language, is_official, is_published, checked_on) values
  ('btl-unemployment-income-current', 'Битуах Леуми', 'Доходы в период безработицы', 'https://www.btl.gov.il/benefits/Unemployment/Pages/incomes.aspx', 'he', true, true, '2026-09-17'),
  ('btl-unemployment-eligibility-current', 'Битуах Леуми', 'Условия права на пособие по безработице', 'https://www.btl.gov.il/benefits/Unemployment/Pages/zakaut.aspx', 'he', true, true, '2026-09-17')
on conflict (slug) do update set
  publisher=excluded.publisher, title=excluded.title, url=excluded.url,
  language=excluded.language, is_official=excluded.is_official,
  is_published=true, checked_on=excluded.checked_on;

insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id,
  'unemployment-spouse-income',
  'Влияет ли доход супруга на пособие по безработице',
  'Пособие по безработице не является семейным пособием с проверкой общего дохода пары: Битуах Леуми уменьшает выплату из-за доходов самого безработного от работы, самостоятельной деятельности или пенсии. Доход супруга может иметь значение только для признания супруга иждивенцем в тех возрастных категориях, где число иждивенцев влияет на максимальное число дней.',
  'На официальной странице условий права Битуах Леуми перечислены индивидуальные условия получателя — резидентство, возраст, прекращение работы, регистрация и страховой период — без проверки общего дохода семьи. На странице о доходах во время безработицы перечислены доходы самого получателя, которые уменьшают пособие: работа по найму, самостоятельная деятельность и пенсия. Отдельно в таблице максимального периода доход супруга используется для определения, считается ли супруг иждивенцем. Для специального правила 300 дней для женщин 57–67 лет максимальный период установлен отдельно и не зависит от числа иждивенцев.',
  array['Проверьте собственные доходы получателя во время безработицы: работа, самостоятельная деятельность или пенсия.','Если применяете обычную таблицу максимальных дней, отдельно проверьте, считается ли супруг иждивенцем.','Для женщины 57–67 лет, подпадающей под специальное правило, используйте карточку 300 дней/18 месяцев.'],
  array['Данные о собственных доходах получателя в период безработицы'],
  array[]::text[],
  array['Доход супруга может влиять на статус иждивенца в обычной таблице длительности, но это не означает семейную проверку дохода для самого права на пособие.'],
  '[]'::jsonb,
  array['доход супруга','доход мужа','доход жены','автала','пособие по безработице','300 дней'],
  'пособие по безработице автала доход супруга мужа жены влияет ли семейный доход проверка доходов 300 дней женщины 57 67 иждивенец собственный доход безработного'
from public.topics t join public.sources s on s.slug='btl-unemployment-income-current'
where t.slug='unemployment'
on conflict (slug) do update set
  topic_id=excluded.topic_id, source_id=excluded.source_id, title=excluded.title,
  short_answer=excluded.short_answer, answer=excluded.answer, steps=excluded.steps,
  documents=excluded.documents, follow_up_questions=excluded.follow_up_questions,
  caveats=excluded.caveats, keywords=excluded.keywords, search_text=excluded.search_text,
  embedding=null, is_published=true, reviewed_on=excluded.reviewed_on,
  ai_embedding_allowed=true, updated_at=now();

update public.knowledge_cards
set follow_up_questions=array[]::text[],
    caveats=array['Карточка описывает право по статусу пособия; техническое применение зависит от совпадения данных получателя и адреса у поставщика воды.'],
    embedding=null,
    updated_at=now()
where slug='old-age-water-benefit';

update public.knowledge_cards
set follow_up_questions=array['На какие точные даты работодатель оформляет ХАЛАТ?','Сколько оплачиваемых отпускных дней осталось?'],
    embedding=null,
    updated_at=now()
where slug='unpaid-leave';

update public.knowledge_cards
set follow_up_questions=array['Когда планируется новая регистрация в Службе занятости?','Сколько дней было фактически выплачено по предыдущей заявке?'],
    embedding=null,
    updated_at=now()
where slug='unemployment-women-57-67-300';
