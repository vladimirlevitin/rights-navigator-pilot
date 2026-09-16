insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'old-age-payment-september-2026',
  'Досрочная выплата пособия по старости в сентябре 2026',
  'В сентябре 2026 года долгосрочные пособия, включая пособие по старости, были перенесены на 22 сентября; пособие по безработице и обеспечение прожиточного минимума — на 8 сентября.',
  'Битуах Леуми официально сообщил 23 августа 2026 года, что в сентябре 2026 пособия по безработице и обеспечению прожиточного минимума будут выплачены 8 сентября, а долгосрочные пособия, включая пособие по старости, — 22 сентября.',
  array['Если вопрос относится к сентябрю 2026 года, ориентируйтесь на опубликованную дату 22 сентября для пособия по старости.'],
  array[]::text[],
  array['Речь идёт именно о выплате за сентябрь 2026 года?'],
  array['Это специальный календарь только для сентября 2026 года.'],
  '[]'::jsonb,
  array['сентябрь 2026','22 сентября','8 сентября','пособие по старости'],
  'сентябрь 2026 пособие по старости 22 сентября 8 сентября безработица прожиточный минимум досрочная выплата',
  true, '2026-09-16', true
from public.topics t join public.sources s on s.slug='btl-september-2026-payment'
where t.slug='old_age'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();

update public.knowledge_cards
set answer='Обычная дата выплаты пособия по старости — 28-е число текущего месяца. В отдельные месяцы Битуах Леуми может переносить дату из-за праздников; конкретный перенос нужно проверять по опубликованному календарю соответствующего месяца.',
    search_text='пособие по старости когда выплата 28 число пенсионное пособие дата выплаты календарь перенос праздники',
    embedding=null,
    updated_at=now()
where slug='old-age-payment-date';

insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'disability-application-process',
  'Как Битуах Леуми рассматривает первое заявление по инвалидности',
  'После подачи документов заявление проверяет сотрудник, затем врач Битуах Леуми; при необходимости назначается медицинская комиссия, которая устанавливает медицинский процент, а затем оценивается влияние состояния на трудоспособность.',
  'Сначала проверяются заявление, документы и базовые условия. Затем врач Битуах Леуми изучает декларацию о здоровье и медицинские материалы и решает, нужна ли комиссия. Медицинская комиссия устанавливает медицинский процент инвалидности. После этого отдельно оценивается влияние состояния на способность работать и обеспечивать себя.',
  array['Подайте полный комплект документов, чтобы сократить запросы на дополнение.','При приглашении на комиссию подготовьте краткое описание функциональных ограничений и все актуальные медицинские материалы.'],
  array['Медицинские документы','Приглашение на комиссию при наличии'],
  array['Уже назначена медицинская комиссия?'],
  array['Комиссия устанавливает медицинский процент; окончательное право на пособие зависит и от других условий.'],
  '[]'::jsonb,
  array['медкомиссия','процесс заявления','медицинский процент','трудоспособность'],
  'процесс заявления инвалидность медкомиссия медицинский процент врач Битуах Леуми трудоспособность первое заявление',
  true, '2026-09-16', true
from public.topics t join public.sources s on s.slug='btl-disability-process'
where t.slug='disability'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();

update public.knowledge_cards
set answer='Заявление на общую инвалидность можно подать с 18 лет и не позднее 12 месяцев после достижения пенсионного возраста. К заявлению прикладывают медицинские документы, описывающие заболевания, лечение и лекарства. Для наёмного работника могут потребоваться сведения о зарплате и больничных. Подать заявление можно онлайн или через доступные каналы Битуах Леуми.',
    search_text='как оформить инвалидность с чего начать заявление общая инвалидность нехут клали медицинские документы операция сердце кардиолог Битуах Леуми впервые подаю',
    embedding=null,
    updated_at=now()
where slug='disability-first-application';
