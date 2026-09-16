insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id,
  'unemployment-voluntary-register-immediately',
  'После добровольного увольнения регистрируйтесь сразу, даже если выплата начнётся через 90 дней',
  'При добровольном увольнении без уважительной причины выплата авталы обычно начинается только через 90 дней, но Битуах Леуми прямо рекомендует зарегистрироваться в Службе занятости сразу после прекращения работы, чтобы не потерять страховой период и право.',
  'Первичная регистрация в Службе занятости влияет на право на пособие по безработице. Битуах Леуми отдельно подчёркивает: даже если человек уволился добровольно без уважительной причины и сможет получать деньги только после 90 дней, регистрироваться следует сразу после фактического прекращения работы. Не нужно ждать окончания трёхмесячного периода, чтобы начать процедуру.',
  array['Зарегистрируйтесь в Службе занятости сразу после прекращения работы.','Подайте заявление на пособие по безработице, не дожидаясь истечения 90 дней.','Если увольнение было по уважительной причине, приложите подтверждающие документы — это может убрать 90-дневное ожидание.'],
  array['Подтверждение даты и причины прекращения работы','Документы об уважительной причине — если она есть'],
  array[]::text[],
  array['Битуах Леуми указывает ограниченное послабление для регистрации в течение трёх месяцев при выполнении страхового периода, но безопасная рекомендация — регистрироваться сразу.'],
  '[]'::jsonb,
  array['добровольное увольнение','90 дней','регистрироваться сразу','Служба занятости','автала'],
  'хочу уволиться по собственному желанию пособие по безработице когда подавать документы сразу после увольнения или после трех месяцев 90 дней регистрация служба занятости автала зарегистрироваться сразу'
from public.topics t join public.sources s on s.slug='btl-unemployment-registration-current'
where t.slug='unemployment'
on conflict (slug) do update set
  topic_id=excluded.topic_id, source_id=excluded.source_id, title=excluded.title,
  short_answer=excluded.short_answer, answer=excluded.answer, steps=excluded.steps,
  documents=excluded.documents, follow_up_questions=excluded.follow_up_questions,
  caveats=excluded.caveats, keywords=excluded.keywords, search_text=excluded.search_text,
  is_published=true, reviewed_on='2026-09-17', ai_embedding_allowed=true, embedding=null;

update public.knowledge_cards
set search_text = 'с 1 сентября снижают степень инвалидности до 55 процентов пособие прекращается сохраняется ли скидка льгота на арнону инвалидность 55 75 90 степень потери трудоспособности медицинская инвалидность муниципалитет арнона',
    embedding = null,
    reviewed_on = '2026-09-17',
    updated_at = now()
where slug = 'disability-arnona-thresholds';

update public.knowledge_cards
set search_text = 'с 1 сентября снижают степень инвалидности до 55 процентов пособие прекращается сохраняется ли льгота на проезд общественный транспорт удостоверение инвалида срок действия rav kav 50 процентов',
    embedding = null,
    reviewed_on = '2026-09-17',
    updated_at = now()
where slug = 'disability-transport-card-validity';
