-- Benchmark-driven expansion based on verified BTL / Tax Authority / Kol Zchut sources.
-- Generated 2026-09-16. IDs are resolved by slug; no generated IDs are hard-coded.

insert into public.topics (slug, title, description, is_published) values
  ('employment_rights', 'Трудовые права и расчёты', 'Отпуск, больничные, окончательный расчёт и существенное изменение условий труда.', true),
  ('old_age', 'Пособие по старости', 'Сроки и отдельные правила выплаты пособия по старости.', true),
  ('insurance_contributions', 'Страховые взносы Битуах Леуми', 'Взносы по национальному и медицинскому страхованию при разных видах дохода.', true)
on conflict (slug) do update set
  title = excluded.title,
  description = excluded.description,
  is_published = excluded.is_published,
  updated_at = now();

insert into public.sources (slug, publisher, title, url, language, is_official, is_published, checked_on) values
  ('btl-disability-apply', 'Битуах Леуми', 'Как подавать заявление — пособие по общей инвалидности', 'https://www.btl.gov.il/RussianHomePage/Benefits_ru/Nehut_ru/Pages/ofenHagashanHatvia_ruf.aspx', 'ru', true, true, '2026-09-16'),
  ('btl-disability-process', 'Битуах Леуми', 'Процесс рассмотрения заявления — пособие по общей инвалидности', 'https://www.btl.gov.il/RussianHomePage/Benefits_ru/Nehut_ru/Pages/mahuTahalichTipulBaTviya_ru.aspx', 'ru', true, true, '2026-09-16'),
  ('btl-special-services-mobility', 'Битуах Леуми', 'Условия получения пособия по особым услугам', 'https://www.btl.gov.il/RussianHomePage/Benefits_ru/sherutimMeyuhadimLenehim_ru/Pages/tnaeZakaut_ru.aspx', 'ru', true, true, '2026-09-16'),
  ('btl-mobility-standing-loan', 'Битуах Леуми', 'Размер условной ссуды на транспортное средство', 'https://www.btl.gov.il/RussianHomePage/Benefits_ru/nayadut_ru/halvaaOmedetLekoneRehevRishon_ru/Pages/shiurHalvaa.aspx', 'ru', true, true, '2026-09-16'),
  ('tax-form-161', 'Налоговое управление Израиля', 'Уведомление о прекращении работы — новая форма 161', 'https://www.gov.il/he/service/notice-of-retirement', 'he', true, true, '2026-09-16'),
  ('btl-old-age-payment', 'Битуах Леуми', 'Даты выплаты пособия по старости', 'https://www.btl.gov.il/RussianHomePage/Benefits_ru/Vatikim_ru/Pages/moedHaTashlum.aspx', 'ru', true, true, '2026-09-16'),
  ('btl-september-2026-payment', 'Битуах Леуми', 'Досрочная выплата пособий за сентябрь 2026', 'https://www.btl.gov.il/About/news/Pages/September-pencion-early.aspx', 'he', true, true, '2026-09-16'),
  ('btl-old-age-deductions', 'Битуах Леуми', 'Вычеты из пособия по старости', 'https://www.btl.gov.il/RussianHomePage/Benefits_ru/Vatikim_ru/Shum/Pages/Nicuyim.aspx', 'ru', true, true, '2026-09-16'),
  ('btl-nonwork-contributions', 'Битуах Леуми', 'Страховые взносы для неработающих и имеющих доход не от работы', 'https://www.btl.gov.il/RussianHomePage/Gvia_ru/shiurDmeHabituhachVehaschumim_ru/Pages/lemiSheenamOvdim_ru.aspx', 'ru', true, true, '2026-09-16'),
  ('kz-holiday-leave', 'Коль Зхут', 'Права работников в праздничные дни', 'https://www.kolzchut.org.il/ru/Права_работников_в_праздничные_дни', 'ru', false, true, '2026-09-16'),
  ('kz-unused-leave', 'Коль Зхут', 'Оплата за неиспользованные дни отпуска', 'https://www.kolzchut.org.il/ru/Оплата_за_неиспользованные_дни_отпуска_(выкуп_ежегодного_отпуска)', 'ru', false, true, '2026-09-16'),
  ('kz-wage-payment', 'Коль Зхут', 'Дата выплаты заработной платы', 'https://www.kolzchut.org.il/ru/Дата_выплаты_заработной_платы', 'ru', false, true, '2026-09-16'),
  ('kz-sick-monthly', 'Коль Зхут', 'Расчет больничных работнику с месячным окладом', 'https://www.kolzchut.org.il/ru/Расчет_больничных_работнику_с_месячным_окладом', 'ru', false, true, '2026-09-16'),
  ('kz-sick-hourly', 'Коль Зхут', 'Расчет больничного для почасового/поденного работника', 'https://www.kolzchut.org.il/ru/Расчет_больничного_для_почасового/поденного_работника,_работающего_все_дни_рабочей_недели_у_одного_и_того_же_работодателя', 'ru', false, true, '2026-09-16'),
  ('kz-vacation-pay', 'Коль Зхут', 'Оплата отпускных дней', 'https://www.kolzchut.org.il/ru/Оплата_отпускных_дней', 'ru', false, true, '2026-09-16'),
  ('kz-material-worsening', 'Коль Зхут', 'Выходное пособие при заметном ухудшении условий труда', 'https://www.kolzchut.org.il/ru/Выходное_пособие_работнику,_уволившемуся_в_связи_с_заметным_ухудшением_условий_труда', 'ru', false, true, '2026-09-16'),
  ('kz-retirement-severance', 'Коль Зхут', 'Выходное пособие работнику, уволившемуся после достижения пенсионного возраста', 'https://www.kolzchut.org.il/ru/Выходное_пособие_работнику,_уволившемуся_после_достижения_пенсионного_возраста', 'ru', false, true, '2026-09-16')
on conflict (slug) do update set
  title = excluded.title,
  url = excluded.url,
  language = excluded.language,
  is_official = excluded.is_official,
  is_published = true,
  checked_on = excluded.checked_on;

-- First application for general disability.
insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'disability-first-application',
  'Первичное заявление на общую инвалидность',
  'При первом обращении нужно подать заявление в Битуах Леуми и приложить актуальные медицинские документы; затем ведомство проверяет документы и при необходимости направляет на медицинскую комиссию.',
  'Заявление на общую инвалидность можно подать с 18 лет и не позднее 12 месяцев после достижения пенсионного возраста. К заявлению прикладывают медицинские документы, описывающие заболевания, лечение и лекарства. Для наёмного работника могут потребоваться сведения о зарплате и больничных. После проверки заявления врач Битуах Леуми решает, нужна ли медицинская комиссия; комиссия устанавливает медицинскую инвалидность, а затем отдельно оценивается влияние состояния на способность работать и зарабатывать.',
  array['Соберите выписки после госпитализаций и операций, заключения профильных врачей и результаты обследований.','Подайте заявление на общую инвалидность через сайт Битуах Леуми или другим доступным способом.','Если вы работаете по найму, подготовьте сведения о зарплате и периодах оплаты больничных.'],
  array['Медицинские выписки и заключения','Результаты обследований','Список лекарств','Сведения о зарплате для наёмного работника'],
  array['Это первое заявление на общую инвалидность или у вас уже есть решение Битуах Леуми?'],
  array['Навигатор не устанавливает медицинский процент и не заменяет решение комиссии.'],
  '[]'::jsonb,
  array['оформить инвалидность','первое заявление','медицинские документы','медкомиссия','нехут клали'],
  'как оформить инвалидность с чего начать заявление общая инвалидность нехут клали медицинские документы операция сердце кардиолог медкомиссия Битуах Леуми впервые подаю'
from public.topics t join public.sources s on s.slug='btl-disability-apply'
where t.slug='disability'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();

insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'disability-special-services-mobility',
  'Совмещение пособия по особым услугам и пособия по мобильности',
  'Одновременно получать пособие по мобильности и пособие по особым услугам можно только при выполнении одного из специальных условий.',
  'Получатель пособия по мобильности может одновременно получать пособие по особым услугам, если право на особые услуги установлено в размере 112% и выше, либо ограничение мобильности составляет 100%, либо медицинская комиссия Министерства здравоохранения установила необходимость инвалидной коляски и фактическое пользование ею. Если ни одно условие не выполнено, одновременная выплата может быть невозможна.',
  array['Сверьте процент пособия по особым услугам и процент ограничения мобильности с решением Битуах Леуми.','Проверьте, есть ли решение о необходимости инвалидной коляски.'],
  array['Решение по особым услугам','Решение комиссии по мобильности'],
  array['Какой процент пособия по особым услугам установлен?','Какой процент ограничения мобильности установлен?','Есть ли решение о необходимости инвалидной коляски?'],
  array['Право зависит от официальных решений, а не только от медицинского процента общей инвалидности.'],
  '[]'::jsonb,
  array['особые услуги','мобильность','ниядут','112%','100%','инвалидная коляска'],
  'особые услуги шарм שירותים מיוחדים мобильность ниядут ניידות одновременно два пособия 112 процентов 100 процентов коляска'
from public.topics t join public.sources s on s.slug='btl-special-services-mobility'
where t.slug='disability'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();

insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'disability-mobility-standing-loan',
  'Как процент мобильности влияет на условную ссуду на автомобиль',
  'Процент ограничения мобильности не равен скидке от цены автомобиля: условная ссуда покрывает налоги на определённое транспортное средство и её процент зависит также от наличия водительских прав.',
  'Для имеющего водительские права при ограничении мобильности 40–79% процент условной ссуды соответствует проценту ограничения мобильности. Для не имеющего водительских прав при ограничении 60–79% процент ссуды составляет 75% от процента ограничения мобильности. Полная условная ссуда связана с налогами на определённую категорию автомобиля и ограничена фактической суммой налогов; это не скидка на цену автомобиля в том же проценте.',
  array['Проверьте процент ограничения мобильности в решении комиссии.','Уточните, является ли получатель водителем с действующими правами.','Сравните расчёт с таблицей Битуах Леуми для условной ссуды.'],
  array['Решение по мобильности','Водительское удостоверение при наличии','Расчёт условной ссуды Битуах Леуми'],
  array['Есть ли у получателя водительские права?'],
  array['Точная сумма зависит от категории определяющего автомобиля и налогов на него.'],
  '[]'::jsonb,
  array['условная ссуда','алваа омедет','мобильность','автомобиль','водительские права'],
  'условная ссуда алваа омедет הלוואה עומדת автомобиль машина мобильность ниядут 60 процентов водительские права налоги на автомобиль'
from public.topics t join public.sources s on s.slug='btl-mobility-standing-loan'
where t.slug='disability'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();

-- Severance subtopics.
insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'severance-form-161-tax',
  'Форма 161 и обращение в Налоговое управление',
  'Наличие формы 161 не означает, что всегда нужно лично обращаться в Налоговое управление: необходимость зависит от того, как заполнена часть C и какие инструкции нужны фонду.',
  'С 1 января 2024 года используется новая форма 161. Работодатель заполняет сведения о прекращении работы, работник — свои выборы по средствам выходного пособия, а часть C содержит инструкции работодателю и пенсионным кассам. Если работодатель заполнил часть C2, работнику нужно обратиться к налоговому инспектору за инструкциями и затем передать их работодателю и кассам. В других вариантах форма может содержать достаточные инструкции без отдельного обращения работника.',
  array['Проверьте, какая часть C заполнена работодателем.','Передайте полностью заполненную форму 161 пенсионному фонду/кассе в соответствии с указанными инструкциями.','Если заполнена часть C2 или фонд просит налоговые инструкции, обратитесь в Налоговое управление.'],
  array['Полностью заполненная форма 161','При необходимости последние расчётные листки и актуальная справка о балансе фонда'],
  array['Работодатель заполнил часть C2 формы 161?'],
  array['Налоговые последствия зависят от выбранного способа распоряжения средствами; навигатор не рассчитывает индивидуальный налог.'],
  '[{"he":"טופס 161","ru":"тофес 161","meaning":"форма 161"}]'::jsonb,
  array['форма 161','тофес 161','налог','пицуим','пенсионный фонд'],
  'форма 161 тофес 161 טופס 161 выходное пособие пицуим налог налоговое управление мас ахнаса пенсионный фонд удержать налог часть C C2'
from public.topics t join public.sources s on s.slug='tax-form-161'
where t.slug='severance'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,hebrew_terms=excluded.hebrew_terms,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();

insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'severance-retirement-resignation',
  'Пицуим при увольнении после достижения пенсионного возраста',
  'Увольнение по собственному желанию после достижения пенсионного возраста может давать право на пицуим, но нужно учитывать стаж и пенсионное соглашение/уже произведённые отчисления.',
  'Работник, который проработал не менее года у работодателя или на рабочем месте и увольняется по собственному желанию после достижения пенсионного возраста, может иметь право на выходное пособие. При этом накопленные пенсионные отчисления на компонент пицуим и условия пенсионного соглашения могут влиять на то, должен ли работодатель доплачивать что-либо сверх уже накопленных средств. Требуется предварительное уведомление об увольнении.',
  array['Проверьте стаж именно у текущего работодателя и непрерывность работы на месте.','Получите данные о пенсионных отчислениях компонента пицуим.','Передайте работодателю предварительное уведомление об увольнении.'],
  array['Расчётные листки','Отчёт пенсионного фонда','Форма 161','Документы о стаже'],
  array['Вы начали работать у этого работодателя до или после достижения пенсионного возраста?','Какие отчисления на пицуим уже сделаны?'],
  array['Размер доплаты нельзя определить без данных о пенсионном соглашении и отчислениях.'],
  '[]'::jsonb,
  array['пенсионный возраст','уволиться на пенсию','пицуим','71 год','выходное пособие'],
  'пицуим выходное пособие пенсионный возраст пенсия уволиться в связи с выходом на пенсию 67 71 стаж новый работодатель отчисления пенсионный фонд'
from public.topics t join public.sources s on s.slug='kz-retirement-severance'
where t.slug='severance'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();

-- Employment rights.
insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'annual-leave-employer-initiated',
  'Принудительный и коллективный ежегодный отпуск',
  'Работодатель может определять даты ежегодного отпуска, но не может без согласия загнать работника в отрицательный баланс отпускных дней.',
  'Работодатель может закрыть рабочее место и отправить работников в ежегодный отпуск. Если отпуск вместе с еженедельным отдыхом длится 7 дней и более, работников нужно уведомить не менее чем за две недели. Работодатель не может обязать работника использовать больше дней, чем накоплено. При недостатке дней можно не отправлять работника в отпуск, оплатить дни без списания будущего отпуска либо оформить неоплачиваемый отпуск только с согласия работника.',
  array['Проверьте остаток накопленных отпускных дней.','Уточните даты и продолжительность коллективного отпуска и дату уведомления.','Если дней недостаточно, запросите у работодателя письменное объяснение, как будут оплачены недостающие дни.'],
  array['Расчётный лист с остатком отпуска','Уведомление работодателя об отпуске'],
  array['Сколько накопленных дней отпуска у вас осталось?','Когда работодатель сообщил о датах отпуска?'],
  array['Коллективные соглашения могут устанавливать дополнительные правила.'],
  '[]'::jsonb,
  array['принудительный отпуск','коллективный отпуск','Сукот','нет отпускных','отрицательный отпуск'],
  'работодатель отправляет отпуск Сукот праздник коллективный отпуск принудительный отпуск нет отпускных дней не хочу идти 7 дней 14 дней уведомление отрицательный баланс'
from public.topics t join public.sources s on s.slug='kz-holiday-leave'
where t.slug='employment_rights'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();

insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'final-settlement-unused-leave',
  'Оплата неиспользованных дней отпуска при завершении работы',
  'При прекращении трудовых отношений работник имеет право на денежную компенсацию за накопленные неиспользованные дни ежегодного отпуска.',
  'Право на оплату неиспользованных отпускных дней возникает при завершении трудовых отношений независимо от того, работник уволился сам, был уволен или вышел на пенсию. Размер зависит от количества накопленных дней и стоимости отпускного дня. Сам факт подачи заявления об увольнении не определяет дату окончательного расчёта: для проверки задержки важны дата фактического окончания работы и вид конкретной выплаты.',
  array['Установите фактическую дату последнего рабочего дня.','Сверьте остаток отпуска в последнем расчётном листке.','Попросите работодателя письменно указать дату и состав окончательного расчёта.'],
  array['Последний расчётный лист','Уведомление об увольнении','Расчёт остатка ежегодного отпуска'],
  array['Какова фактическая дата последнего рабочего дня?'],
  array['Сроки отдельных компонентов окончательного расчёта могут различаться; карточка не утверждает, что любая задержка до следующего месяца законна.'],
  '[]'::jsonb,
  array['окончательный расчет','неиспользованный отпуск','увольнение','компенсация отпуска'],
  'окончательный расчет после увольнения гмар хешбон неиспользованный отпуск компенсация отпускных дней деньги не пришли последний рабочий день'
from public.topics t join public.sources s on s.slug='kz-unused-leave'
where t.slug='employment_rights'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();

insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'wage-payment-timing',
  'Срок выплаты заработной платы',
  'Для работника с месячным окладом зарплата должна быть выплачена по окончании отработанного месяца; задержка более чем на 9 дней после установленной даты может считаться задержкой зарплаты.',
  'Для месячного оклада зарплата выплачивается по окончании отработанного месяца и должна быть перечислена не позднее 9-го числа следующего месяца. Для почасовой, поденной или сдельной оплаты правила могут зависеть от периода работы и соглашения. Эта карточка применяется только к зарплатным компонентам, а не автоматически ко всем выплатам при прекращении работы.',
  array['Определите, какой компонент не выплачен: зарплата, отпуск, пицуим или другое.','Проверьте установленную дату выплаты и трудовое соглашение.'],
  array['Расчётный лист','Трудовой договор или соглашение о дате выплаты'],
  array['Вы получаете месячный оклад или почасовую/поденную оплату?'],
  array['Не все компоненты окончательного расчёта имеют одинаковые сроки.'],
  '[]'::jsonb,
  array['задержка зарплаты','9 число','окончательный расчет','выплата'],
  'когда должны выплатить зарплату задержка 9 число месячный оклад почасовая оплата окончательный расчет'
from public.topics t join public.sources s on s.slug='kz-wage-payment'
where t.slug='employment_rights'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();

insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'sick-pay-monthly',
  'Расчёт больничных при месячном окладе',
  'Для работника с фиксированным месячным окладом стоимость дня болезни выводится из месячной зарплаты; существуют две используемые интерпретации деления — на 30 календарных или на фактическое число рабочих дней.',
  'Работник с месячным окладом при наличии накопленных больничных дней и больничного листа может иметь право на больничные. Для стоимости дня болезни используются две интерпретации: деление месячной зарплаты на 30 календарных дней либо на фактическое количество рабочих дней. Поэтому один процент в расчётном листке нельзя проверить без формулы работодателя и исходных данных.',
  array['Уточните, что зарплата действительно фиксированная месячная.','Попросите бухгалтерию показать формулу и исходную сумму зарплаты.','Сверьте число дней болезни и остаток больничных дней.'],
  array['Расчётный лист','Больничный лист','Данные о месячном окладе'],
  array['У вас фиксированный месячный оклад?'],
  array['Навигатор не подтверждает конкретный процент без расчётного листка и формулы.'],
  '[]'::jsonb,
  array['больничные','месячный оклад','расчет','30 дней','73.95'],
  'больничные расчет месячный оклад 73.95 процента расчетный лист стоимость дня болезни 30 календарных дней рабочие дни'
from public.topics t join public.sources s on s.slug='kz-sick-monthly'
where t.slug='employment_rights'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();

insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'sick-pay-hourly',
  'Расчёт больничных при почасовой или поденной оплате',
  'Для почасового/поденного работника больничные зависят от обычной оплаты за соответствующий день; при меняющемся числе часов используется средний показатель за несколько месяцев.',
  'Для почасового или поденного работника первый день болезни обычно не оплачивается, второй и третий оплачиваются в размере 50% причитающейся за день зарплаты, а последующие дни — по установленным правилам. При меняющемся количестве часов стоимость рабочего дня рассчитывают по среднему за последние месяцы; источник отмечает, что закон и судебная практика не установили единый период 3 или 12 месяцев для такого усреднения.',
  array['Уточните почасовую/поденную ставку и обычный график.','Попросите бухгалтерию показать период усреднения и формулу.'],
  array['Расчётный лист','Больничный лист','Учёт часов за предыдущие месяцы'],
  array['Оплата почасовая/поденная и меняется ли число часов по дням?'],
  array['Точный расчёт зависит от графика и числа дней болезни.'],
  '[]'::jsonb,
  array['больничные','почасовая оплата','поденная оплата','средние часы','73.95'],
  'больничные расчет почасовая поденная оплата склад 73.95 процента средние часы последние месяцы первый день второй третий'
from public.topics t join public.sources s on s.slug='kz-sick-hourly'
where t.slug='employment_rights'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();

insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'annual-leave-pay-calculation',
  'Как рассчитываются отпускные',
  'За дни ежегодного отпуска работник должен получить обычную зарплату; способ расчёта зависит от типа оплаты труда.',
  'Работник в ежегодном отпуске имеет право на отпускные в размере обычной зарплаты. Для работника с месячным окладом это связано с обычной месячной зарплатой. Для почасовых и поденных работников расчёт средней стоимости дня отличается и зависит от периода заработка. Поэтому для проверки процента в расчётном листке нужно сначала установить тип оплаты труда.',
  array['Уточните: месячный оклад или почасовая/поденная оплата.','Попросите бухгалтерию показать формулу отпускных отдельно от больничных.'],
  array['Расчётный лист','Данные о зарплате за расчётный период'],
  array['Какой у вас тип оплаты труда?'],
  array['Отпускные и больничные рассчитываются по разным правилам.'],
  '[]'::jsonb,
  array['отпускные','расчет отпускных','месячный оклад','почасовая оплата'],
  'отпускные расчет отпуск ежегодный отпуск обычная зарплата месячный оклад почасовая поденная 73.95 расчетный лист'
from public.topics t join public.sources s on s.slug='kz-vacation-pay'
where t.slug='employment_rights'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();

insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'employment-material-change',
  'Существенное ухудшение условий труда',
  'Значительное одностороннее изменение порядка или условий работы может при определённых обстоятельствах считаться существенным ухудшением, но не каждое изменение даёт такое право.',
  'Работник, отработавший не менее года и увольняющийся из-за заметного ухудшения условий труда, может при выполнении условий иметь право на пицуим. Изменение порядка работы или условий может быть одним из примеров, однако оценивается значимость изменения и связь с увольнением. Обычно работник должен письменно сообщить работодателю о проблеме и дать возможность её исправить, если исправление возможно.',
  array['Зафиксируйте прежний и новый график письменно.','Сообщите работодателю, почему изменение создаёт существенную проблему, и попросите восстановить прежние условия или предложить решение.','Не оформляйте увольнение как последствие ухудшения условий без сохранения переписки и проверки обстоятельств.'],
  array['Трудовой договор или уведомление об условиях труда','Переписка об изменении графика','Старый и новый график'],
  array['Был ли прежний график закреплён в договоре или устойчиво действовал длительное время?','Сообщали ли вы работодателю письменно о проблеме?'],
  array['Не каждое изменение рабочего графика признаётся существенным ухудшением.'],
  '[]'::jsonb,
  array['график работы','смена','ухудшение условий','работодатель изменил график'],
  'работодатель изменил график смена с 19 до 20 односторонне без согласия транспорт существенное ухудшение условий труда изменение порядка работы'
from public.topics t join public.sources s on s.slug='kz-material-worsening'
where t.slug='employment_rights'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();

-- Old-age payment timing.
insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'old-age-payment-date',
  'Когда выплачивается пособие по старости',
  'Обычно пособие по старости выплачивается 28-го числа текущего месяца; Битуах Леуми может переносить дату из-за праздников.',
  'Обычная дата выплаты пособия по старости — 28-е число текущего месяца. В отдельные месяцы Битуах Леуми публикует переносы. На сентябрь 2026 года долгосрочные пособия, включая пособие по старости, были перенесены на 22 сентября; пособие по безработице и обеспечение прожиточного минимума были перенесены на 8 сентября.',
  array['Проверьте календарь выплат Битуах Леуми на нужный месяц.','Если опубликованная дата прошла, а денег нет, проверьте личный кабинет и банковский счёт.'],
  array[],
  array['За какой месяц вы ожидаете выплату?'],
  array['Переносы дат зависят от конкретного месяца и должны проверяться по актуальному календарю.'],
  '[]'::jsonb,
  array['пособие по старости','дата выплаты','22 сентября','28 число','8 сентября'],
  'пособие по старости когда выплата 8 сентября 22 сентября 28 число пенсионное пособие долгосрочные выплаты сентябрь 2026'
from public.topics t join public.sources s on s.slug='btl-old-age-payment'
where t.slug='old_age'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();

-- Insurance contributions.
insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'insurance-old-age-recipient-employee',
  'Удержания с зарплаты работающего получателя пособия по старости',
  'Если получатель пособия по старости работает по найму, взносы по страхованию здоровья должны удерживаться из пособия по старости, а не из зарплаты; для остановки ошибочного удержания работодателю предъявляют справку Битуах Леуми.',
  'Битуах Леуми указывает, что работающий по найму получатель пособия по старости должен представить работодателю справку об освобождении от страховых взносов или о получении пособия по старости, если работодатель удерживает из зарплаты взносы по страхованию здоровья. Для получателей пособия по старости с надбавкой по инвалидности взнос по страхованию здоровья удерживается из самого пособия по специальной ставке. Подоходный налог — отдельный налог и не определяется этой карточкой.',
  array['Проверьте, что работодатель знает о получении вами пособия по старости.','При необходимости скачайте справку Битуах Леуми об освобождении/получении пособия и передайте работодателю.','Проверьте удержание медицинского страхования в выплате пособия по старости.'],
  array['Справка Битуах Леуми об освобождении или получении пособия по старости','Расчётный лист зарплаты','Расчёт выплаты пособия по старости'],
  array['Вы уже получаете именно пособие по старости от Битуах Леуми?'],
  array['Карточка не рассчитывает подоходный налог и не относится к досрочной частной пенсии.'],
  '[]'::jsonb,
  array['пособие по старости','работаю','взносы','медицинское страхование','не удерживают'],
  'получаю пособие по старости работаю зарплата не удерживают Битуах Леуми медицинское страхование взносы освобождение справка инвалидная надбавка налог'
from public.topics t join public.sources s on s.slug='btl-old-age-deductions'
where t.slug='insurance_contributions'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();

insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id, 'insurance-nonwork-income',
  'Страховые взносы при доходах не от работы',
  'Неработающие лица, имеющие доходы не от работы, в общем случае платят страховые взносы и взносы по страхованию здоровья в процентах от облагаемого дохода.',
  'Битуах Леуми публикует отдельные ставки для неработающих лиц, имеющих доходы не от работы. Точный расчёт зависит от статуса человека, вида и размера дохода и периода. Для супругов пенсионного возраста особенно важно отдельно установить, получают ли они пособие по старости и какой статус присвоен каждому из них, прежде чем делать расчёт.',
  array['Уточните статус каждого супруга в Битуах Леуми.','Уточните, получает ли каждый из супругов пособие по старости.','Соберите данные о видах и суммах дохода не от работы за нужный период.'],
  array['Решение о резидентстве','Сведения о доходах от аренды и процентов','Решение/справка о пособии по старости при наличии'],
  array['Получаете ли вы или супруг пособие по старости от Битуах Леуми?'],
  array['Карточка не выполняет окончательный расчёт по доходам из разных стран; для него нужны статус и суммы дохода.'],
  '[]'::jsonb,
  array['взносы Битуах Леуми','не работаю','доход от аренды','проценты','доход не от работы'],
  'как рассчитываются взносы Битуах Леуми не работаем доход от аренды Израиль за границей проценты банковские вклады доход не от работы резидентство 66 лет'
from public.topics t join public.sources s on s.slug='btl-nonwork-contributions'
where t.slug='insurance_contributions'
on conflict (slug) do update set title=excluded.title,short_answer=excluded.short_answer,answer=excluded.answer,steps=excluded.steps,documents=excluded.documents,follow_up_questions=excluded.follow_up_questions,caveats=excluded.caveats,keywords=excluded.keywords,search_text=excluded.search_text,source_id=excluded.source_id,topic_id=excluded.topic_id,embedding=null,is_published=true,reviewed_on=excluded.reviewed_on,ai_embedding_allowed=true,updated_at=now();

-- Strengthen the existing unemployment-payment card with the quota rule.
update public.knowledge_cards
set short_answer = 'Обычно пособие выплачивается за предыдущий месяц; первые пять дней каждого периода из четырёх последовательных месяцев регистрации не оплачиваются, но эти дни не уменьшают общее число положенных дней пособия.',
    answer = 'Первые пять дней каждого периода из четырёх последовательных месяцев регистрации в Службе занятости не оплачиваются. Эти неоплаченные дни не вычитаются из общего количества дней пособия, на которое человек имеет право. Отдельной последующей выплатой за эти пять дней они не становятся: право просто не уменьшается на эти дни.',
    keywords = array['17 число','первые 5 дней','пять дней без оплаты','4 месяца','не вычитаются','когда платят'],
    search_text = 'когда платят пособие автала первые 5 пять дней не оплатили удержали каждые четыре месяца 4 месяца три месяца без оплаты не вычитаются из количества дней право 300 дней',
    embedding = null,
    reviewed_on = '2026-09-16',
    updated_at = now()
where slug = 'payment-timing';
