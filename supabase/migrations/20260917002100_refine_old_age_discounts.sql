-- Keep arnona and electricity account-holder rules separately grounded.

update public.knowledge_cards k
set title = 'Арнона: кто должен быть зарегистрирован держателем жилья',
    short_answer = 'Для реализации скидки на арнону получатель должен быть зарегистрирован в муниципалитете как держатель объекта, в котором он фактически живёт.',
    answer = 'Скидка на арнону оформляется в муниципалитете по месту проживания. Для её реализации важно, чтобы получатель льготы был зарегистрирован как держатель (מחזיק) объекта. Сам факт, что другие бытовые счета оформлены на супруга или родственника, не означает, что нужно заранее переписывать все счета.',
    steps = array['Проверьте, кто зарегистрирован держателем объекта в муниципалитете.','Если скидка положена, подайте заявление в отдел арноны и приложите требуемые подтверждения.'],
    documents = array['Счёт арноны','Подтверждение права на льготу, если требуется'],
    follow_up_questions = array['Кто сейчас зарегистрирован держателем квартиры по арноне?'],
    caveats = array['Условия и размер скидки зависят от вида права и дохода.'],
    keywords = array['арнона','держатель объекта','махзик','пенсионер','скидка'],
    search_text = 'арнона скидка пенсионер гражданин пожилой держатель объекта махзик מחזיק квартира съемная зарегистрирован проживает на чье имя счет',
    embedding = null,
    reviewed_on = '2026-09-17',
    updated_at = now()
where k.slug = 'old-age-discount-account-holder';

insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'old-age-arnona-senior-2026',
  'Скидка на арнону для пожилых граждан в 2026 году',
  'Пожилой гражданин может иметь право на скидку на арнону даже без доплаты до прожиточного минимума; размер зависит от пособия, дохода и правил муниципалитета.',
  'В 2026 году для пожилых граждан есть несколько оснований. Получатели пособия по старости могут получить скидку до 25% на первые 100 м², если муниципалитет применяет эту льготу. При общем доходе не выше установленного порога может предоставляться обязательная скидка 30%; для одного пожилого гражданина ориентир по среднему заработку на январь 2026 года — 13 623 шекеля. Получатели доплаты до прожиточного минимума при выполнении условий могут иметь право на скидку 100% на первые 100 м². Конкретное право оформляется в муниципалитете.',
  array['Проверьте свой статус пожилого гражданина и вид получаемого пособия.','Сверьте доходы с актуальным порогом муниципальной льготы.','Подайте заявление в отдел арноны муниципалитета, где вы фактически проживаете.'],
  array['Подтверждение возраста/статуса','Подтверждение доходов','Подтверждение пособия, если оно назначено'],
  array['Получаете ли вы пособие по старости или доплату до прожиточного минимума?'],
  array['Скидка до 25% является муниципальной и может зависеть от местных правил.','Доходные пороги ежегодно меняются.'],
  '[]'::jsonb,
  array['арнона','75 лет','пожилой гражданин','25%','30%','100%','съемная квартира','скидка'],
  'мне 75 лет съемная квартира скидки арнона пожилой гражданин пособие пока не получаю 2026 25 30 100 процентов доход прожиточный минимум',
  true, '2026-09-17', true
from public.topics t join public.sources s on s.slug='kz-old-age-arnona'
where t.slug='old_age'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();

insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'old-age-electricity-account-holder',
  'Скидка на электричество: договор должен быть на имя получателя льготы',
  'Для автоматической скидки на электричество данные получателя должны совпадать с именем и номером удостоверения личности клиента в договоре с электрокомпанией.',
  'Получатели пособия по старости с доплатой до прожиточного минимума имеют право на скидку 50% на потребление до 400 кВт⋅ч в месяц. Битуах Леуми передаёт список получателей электрокомпании, а скидка применяется автоматически только при совпадении имени и номера удостоверения личности с данными клиента по договору. Если договор зарегистрирован на другого человека, его нужно перевести на имя получателя льготы.',
  array['Сначала убедитесь, что право на скидку действительно назначено.','Проверьте имя и номер удостоверения личности клиента в договоре на электричество.','Если договор оформлен на другого человека, запросите перевод договора на имя получателя льготы.'],
  array['Решение о пособии по старости с доплатой','Счёт за электричество/номер договора'],
  array['Назначена ли уже доплата до прожиточного минимума?'],
  array['Это правило относится именно к скидке на электричество; для других счетов требования могут отличаться.'],
  '[]'::jsonb,
  array['электричество','счет на имя','договор','50%','400 кВт','социальная надбавка'],
  'супруг выходит на пенсию счета на жену переписать счет электричество скидка 50 процентов 400 квт договор на имя получателя социальная надбавка доплата прожиточный минимум',
  true, '2026-09-17', true
from public.topics t join public.sources s on s.slug='kz-old-age-electricity'
where t.slug='old_age'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();