-- Operational playbooks derived from tatiana_2026-09-17_182605.
-- Real Facebook cases are discovery signals only. Substantive rules below are grounded in official sources.

insert into public.topics (slug, title, description, is_published)
values ('tax', 'Налоги и возвраты', 'Возврат переплаченного налога и налоговые правила при отдельных выплатах и снятии накоплений.', true)
on conflict (slug) do update set
  title=excluded.title, description=excluded.description, is_published=true, updated_at=now();

insert into public.sources (slug, publisher, title, url, language, is_official, is_published, checked_on) values
  ('law-severance-health-section6', 'Кнессет Израиля', 'Закон о выходном пособии — увольнение по состоянию здоровья, статья 6', 'https://fs.knesset.gov.il/5/law/5_lsr_209275.pdf', 'he', true, true, '2026-09-17'),
  ('tax-refund-form135-current', 'Налоговое управление Израиля', 'Заявление на возврат подоходного налога — форма 135', 'https://www.gov.il/he/service/itc135', 'he', true, true, '2026-09-17'),
  ('tax-provident-withdrawal-form159-current', 'Налоговое управление Израиля', 'Снятие средств из пенсионной кассы без удержания налога — форма 159', 'https://www.gov.il/he/service/itc-financial-compensation-without-deduction-tax', 'he', true, true, '2026-09-17'),
  ('housing-aliyah-public-refusals-5084', 'Министерство алии и интеграции', 'Порядок определения права и распределения социального жилья для репатриантов — 5.084', 'https://www.gov.il/BlobFolder/policy/housing_procedures/he/5.084.pdf', 'he', true, true, '2026-09-17'),
  ('housing-public-refusals-0805', 'Министерство строительства и жилищного хозяйства', 'Порядок распределения квартир социального жилья — 08/05', 'https://www.gov.il/BlobFolder/policy/nohal_0805_moch/he/documents_nohal_0805_moch.pdf', 'he', true, true, '2026-09-17'),
  ('housing-single-parent-rent-current', 'Министерство строительства и жилищного хозяйства', 'Помощь на аренду для семей с одним родителем', 'https://www.gov.il/he/service/rent_support_for_single_parent', 'he', true, true, '2026-09-17'),
  ('housing-rent-procedure-0804', 'Министерство строительства и жилищного хозяйства', 'Порядок участия в оплате аренды — 08/04', 'https://www.gov.il/BlobFolder/policy/nohal_0804_moch/he/documents_nohal_0804.pdf', 'he', true, true, '2026-09-17'),
  ('btl-disability-old-age-transition-current', 'Битуах Леуми', 'Переход с других пособий на пособие по старости', 'https://www.btl.gov.il/benefits/old_age/Pages/%D7%9E%D7%A2%D7%91%D7%A8%20%D7%9E%D7%A7%D7%91%D7%9C%D7%AA%20%D7%A7%D7%A6%D7%91%D7%90%D7%95%D7%AA%20%D7%90%D7%97%D7%A8%D7%95%D7%AA%20%D7%9C%D7%A7%D7%91%D7%9C%D7%AA%20%D7%A7%D7%A6%D7%91%D7%AA%20%D7%96%D7%A7%D7%A0%D7%94.aspx', 'he', true, true, '2026-09-17'),
  ('btl-retirement-age-current', 'Битуах Леуми', 'Возраст выхода на пенсию', 'https://www.btl.gov.il/benefits/old_age/Conditions_of_eligibility/gilMezake/Pages/gilPrisha.aspx', 'he', true, true, '2026-09-17'),
  ('btl-long-term-care-worsening-current', 'Битуах Леуми', 'Повторная проверка пособия по уходу при ухудшении состояния', 'https://www.btl.gov.il/benefits/Long_Term_Care/Pages/adltest.aspx', 'he', true, true, '2026-09-17')
on conflict (slug) do update set
  publisher=excluded.publisher, title=excluded.title, url=excluded.url,
  language=excluded.language, is_official=excluded.is_official,
  is_published=true, checked_on=excluded.checked_on;

-- Health-related resignation: turn the rule into an action sequence.
insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id,
  'severance-health-resignation',
  'Пицуим при увольнении по состоянию здоровья',
  'Если работник увольняется из-за своего состояния здоровья и медицинские данные, условия работы и остальные обстоятельства дают достаточное основание для ухода, такое увольнение рассматривается как увольнение работодателем для целей пицуим.',
  'Статья 6 Закона о выходном пособии устанавливает специальное правило для увольнения из-за состояния здоровья самого работника или члена семьи. Решающий вопрос — не процент инвалидности сам по себе, а подтверждённая связь состояния здоровья с решением прекратить конкретную работу и то, оправдывают ли медицинские данные, условия труда и прочие обстоятельства увольнение.',
  array['До увольнения зафиксируйте медицинскую причину и получите актуальный медицинский документ.','В письменном уведомлении работодателю прямо укажите, что прекращение работы связано с состоянием здоровья.','Сохраните уведомление, медицинское подтверждение и ответ работодателя; после прекращения работы проверьте форму 161 и фактические перечисления компонента пицуим.'],
  array['Актуальное медицинское подтверждение','Письменное уведомление об увольнении с указанием причины','Ответ работодателя','Форма 161 и отчёт пенсионного фонда'],
  array['Есть ли медицинский документ, который подтверждает, почему состояние здоровья требует прекратить именно эту работу?'],
  array['Сам диагноз или процент инвалидности без связи с причиной увольнения не даёт автоматического права.','Размер фактической доплаты работодателя зависит от стажа и уже произведённых пенсионных отчислений.'],
  '[]'::jsonb,
  array['пицуим','по состоянию здоровья','уволиться самому','болезнь','медицинские документы','статья 6'],
  'пицуим увольнение по собственному состоянию здоровья болезнь медицинская причина после пенсионного возраста начал работать после пенсии статья 6 документы работодателю полное выходное пособие'
from public.topics t join public.sources s on s.slug='law-severance-health-section6'
where t.slug='severance'
on conflict (slug) do update set
  topic_id=excluded.topic_id, source_id=excluded.source_id, title=excluded.title,
  short_answer=excluded.short_answer, answer=excluded.answer, steps=excluded.steps,
  documents=excluded.documents, follow_up_questions=excluded.follow_up_questions,
  caveats=excluded.caveats, keywords=excluded.keywords, search_text=excluded.search_text,
  is_published=true, reviewed_on='2026-09-17', ai_embedding_allowed=true, embedding=null;

-- Tax refund window.
insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id,
  'tax-refund-six-years',
  'Возврат переплаченного подоходного налога за прошлые годы',
  'Физическое лицо, которое не обязано подавать обычный годовой отчёт, может подать сокращённый отчёт формы 135 и попросить возврат переплаченного налога за период до шести лет назад.',
  'Налоговое управление указывает, что заявление о возврате излишне уплаченного подоходного налога можно подать за шесть предыдущих налоговых лет. В 2026 году это 2020–2025 годы. Проверять нужно каждый налоговый год отдельно и исходить из права, существовавшего в год удержания налога.',
  array['Определите налоговый год, в котором был удержан налог.','Проверьте, попадает ли этот год в шестилетний срок возврата.','Соберите подтверждения удержанного налога и документы на льготу, существовавшую в том году.','Подайте форму 135 либо соответствующий годовой отчёт, если вы обязаны отчитываться в другой форме.'],
  array['Подтверждение удержанного налога','Годовые справки о доходах/удержаниях','Документы, подтверждающие заявляемую налоговую льготу'],
  array['В каком налоговом году был удержан налог?'],
  array['Шестилетний срок не означает автоматический возврат: нужно доказать переплату по правилам конкретного налогового года.','Форма 135 предназначена не для всех налогоплательщиков; тем, кто обязан подавать полный годовой отчёт, применяется соответствующая форма отчётности.'],
  '[]'::jsonb,
  array['возврат налога','6 лет','шесть лет','форма 135','переплата','ретроактивно'],
  'вернуть налог удержали 35 процентов пенсионный фонд кופת גמל возврат подоходного налога шесть лет 6 лет форма 135 ретроактивно прошлые годы'
from public.topics t join public.sources s on s.slug='tax-refund-form135-current'
where t.slug='tax'
on conflict (slug) do update set
  topic_id=excluded.topic_id, source_id=excluded.source_id, title=excluded.title,
  short_answer=excluded.short_answer, answer=excluded.answer, steps=excluded.steps,
  documents=excluded.documents, follow_up_questions=excluded.follow_up_questions,
  caveats=excluded.caveats, keywords=excluded.keywords, search_text=excluded.search_text,
  is_published=true, reviewed_on='2026-09-17', ai_embedding_allowed=true, embedding=null;

-- Provident fund withdrawal because applicant/relative has 75%+ permanent medical disability.
insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id,
  'provident-withdrawal-relative-disability-75',
  'Снятие пенсионных накоплений без удержания налога при инвалидности близкого родственника',
  'Форма 159 позволяет просить снятие средств из пенсионной кассы без удержания налога, если у заявителя или его близкого родственника установлена постоянная медицинская инвалидность не менее 75%, начавшаяся после первого внесения средств в кассу. Ребёнок входит в определение близкого родственника.',
  'Налоговое управление относит к близким родственникам супруга/супругу, родителей, бабушек/дедушек, потомков и их супругов. Для основания по инвалидности требуется постоянная медицинская инвалидность не менее 75%, причём дата её начала должна быть после первой суммы, внесённой на счёт в пенсионной кассе. Это отдельное условие от процента пособия ребёнка-инвалида.',
  array['Проверьте точный медицинский процент и указание, что инвалидность постоянная.','Сравните дату начала инвалидности с датой первого взноса в пенсионную кассу.','Получите из кассы подтверждение суммы средств и номер дела удержаний.','Для будущего снятия подайте форму 159 с требуемыми медицинскими подтверждениями; если налог уже удержан в прошлом, отдельно проверьте шестилетний путь возврата налога.'],
  array['Подтверждение пенсионной кассы о сумме и номере дела удержаний','Медицинский протокол Битуах Леуми или Министерства обороны о постоянной медицинской инвалидности 75%+','Документы о дате первого взноса в кассу','Подтверждение уже удержанного налога — если речь о возврате'],
  array['Какой постоянный медицинский процент был установлен ребёнку в год снятия средств и когда началась инвалидность относительно первого взноса в кассу?'],
  array['Формулировка «100% инвалидность ребёнка» сама по себе не доказывает условие о постоянной медицинской инвалидности 75%+: нужно проверить вид решения.','Правило формы 159 относится к снятию без удержания; возврат уже удержанного налога требует отдельной процедуры возврата.'],
  '[]'::jsonb,
  array['пенсионный фонд','35%','ребёнок инвалид','75%','форма 159','снятие без налога','кופת גמל'],
  'пенсионные накопления сняли удержали 35 налог ребенок 100 инвалидность медицинская 75 постоянная форма 159 קופת גמל קרוב потомок вернуть налог'
from public.topics t join public.sources s on s.slug='tax-provident-withdrawal-form159-current'
where t.slug='tax'
on conflict (slug) do update set
  topic_id=excluded.topic_id, source_id=excluded.source_id, title=excluded.title,
  short_answer=excluded.short_answer, answer=excluded.answer, steps=excluded.steps,
  documents=excluded.documents, follow_up_questions=excluded.follow_up_questions,
  caveats=excluded.caveats, keywords=excluded.keywords, search_text=excluded.search_text,
  is_published=true, reviewed_on='2026-09-17', ai_embedding_allowed=true, embedding=null;

-- Public-housing refusal playbook: Ministry of Aliyah and Integration.
insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id,
  'housing-aliyah-refusal-three',
  'Отказы от социального жилья в очереди Министерства алии',
  'Для очереди Министерства алии и интеграции после трёх учитываемых отказов от подходящих предложений новые предложения прекращаются и повышенная помощь на аренду для ожидающих больше не положена; повторную проверку права можно просить через три года.',
  'Процедура 5.084 отдельно определяет последствия отказов для репатриантов. Не каждый отказ должен засчитываться: например, предложение в другом населённом пункте или повтор того же решения не считается отказом по этому правилу. В отдельных обстоятельствах руководители округа могут разрешить четвёртое предложение по своему усмотрению.',
  array['До отказа установите, по какому ведомству ведётся ваша очередь — Министерство алии или Министерство строительства.','Попросите письменно зафиксировать, будет ли конкретный отказ засчитан в лимит.','Проверьте, не относится ли предложение к исключениям, которые не считаются отказом.','Если три отказа уже засчитаны, получите письменное решение о закрытии ожидания и дате, с которой можно заново просить проверку права; при особых обстоятельствах можно просить рассмотреть дополнительное предложение.'],
  array['Удостоверение права/решение об очереди','Письменное предложение квартиры','Документ или протокол отказа','Письменное решение о последствиях отказа'],
  array['Ваша очередь ведётся Министерством алии и интеграции или Министерством строительства?'],
  array['Эта карточка относится именно к очереди Министерства алии и интеграции.','Не подписывайте отказ, не проверив, считается ли конкретное предложение учитываемым отказом.'],
  '[]'::jsonb,
  array['социальное жильё','Министерство алии','Министерство абсорбции','три отказа','повышенная аренда','очередь'],
  'отказ от социальной квартиры три отказа 3 Министерство алии абсорбции קליטה очередь повышенная помощь аренда повторно через три года четвертое предложение'
from public.topics t join public.sources s on s.slug='housing-aliyah-public-refusals-5084'
where t.slug='housing_support'
on conflict (slug) do update set
  topic_id=excluded.topic_id, source_id=excluded.source_id, title=excluded.title,
  short_answer=excluded.short_answer, answer=excluded.answer, steps=excluded.steps,
  documents=excluded.documents, follow_up_questions=excluded.follow_up_questions,
  caveats=excluded.caveats, keywords=excluded.keywords, search_text=excluded.search_text,
  is_published=true, reviewed_on='2026-09-17', ai_embedding_allowed=true, embedding=null;

-- Public-housing refusal playbook: Ministry of Construction and Housing.
insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id,
  'housing-ministry-refusal-two',
  'Отказы от социального жилья в очереди Министерства строительства',
  'По процедуре Министерства строительства после двух учитываемых отказов от подходящих квартир новые предложения прекращаются до конца текущего периода права; повышенная помощь на аренду сохраняется только до конца уже одобренного периода повышенной помощи. Руководитель отдела заселения может мотивированно разрешить третье предложение.',
  'Процедура 08/05 устанавливает два учитываемых отказа для обычной очереди социального жилья. В ней также перечислены случаи, когда предложение не засчитывается как отказ, включая предложение в другом населённом пункте и некоторые иные ситуации. Решение об отказе должно фиксироваться компанией, обслуживающей жильё.',
  array['До отказа подтвердите, что очередь действительно ведётся Министерством строительства.','Проверьте, считается ли конкретное предложение учитываемым отказом по процедуре 08/05.','Если вы отказываетесь, получите копию документа об отказе или письменную фиксацию решения.','После второго учитываемого отказа запросите письменное подтверждение последствий для очереди и повышенной помощи; при особых причинах можно попросить руководителя отдела заселения рассмотреть третье предложение.'],
  array['Удостоверение права','Письменное предложение квартиры','Документ об отказе','Письменное решение о сохранении/окончании повышенной помощи'],
  array['Какое ведомство ведёт вашу очередь и сколько отказов уже официально засчитано?'],
  array['Эта карточка относится к очереди Министерства строительства и жилищного хозяйства, а не к очереди Министерства алии.','Конкретные исключения из подсчёта отказов нужно сверять с действующей процедурой и предложением.'],
  '[]'::jsonb,
  array['социальное жильё','Минстрой','два отказа','2 отказа','повышенная аренда','очередь'],
  'отказ от социальной квартиры два отказа 2 министерство строительства очередь повышенная помощь аренда третье предложение документ отказа'
from public.topics t join public.sources s on s.slug='housing-public-refusals-0805'
where t.slug='housing_support'
on conflict (slug) do update set
  topic_id=excluded.topic_id, source_id=excluded.source_id, title=excluded.title,
  short_answer=excluded.short_answer, answer=excluded.answer, steps=excluded.steps,
  documents=excluded.documents, follow_up_questions=excluded.follow_up_questions,
  caveats=excluded.caveats, keywords=excluded.keywords, search_text=excluded.search_text,
  is_published=true, reviewed_on='2026-09-17', ai_embedding_allowed=true, embedding=null;

-- Single-parent rent assistance: preserve the right by checking the actual income basis before business changes.
insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id,
  'housing-single-parent-income-test',
  'Доход и помощь на аренду для одинокого родителя',
  'Для одинокого родителя право на помощь на аренду может основываться либо на действующем пособии Битуах Леуми из перечисленных категорий, либо на проверке дохода; при доходном маршруте месячный брутто-доход от работы и алименты должны оставаться ниже обновляемого порога программы.',
  'Открытие самостоятельной деятельности не следует трактовать как автоматическую отмену помощи. Но оно может изменить доход и основание права, поэтому до изменения статуса важно проверить, на каком именно основании выдано действующее удостоверение права и какой доходный порог действует для состава семьи сейчас.',
  array['Найдите действующее удостоверение права на помощь и определите основание: пособие Битуах Леуми или доходный тест.','Перед открытием бизнеса уточните у компании регистрации текущий порог дохода именно для вашего состава семьи и как учитывать доход от самостоятельной деятельности.','После начала деятельности своевременно обновите сведения о доходе и сохраните подтверждение передачи данных.','Проверьте следующее начисление помощи; если сумма изменилась, запросите письменный расчёт основания и периода.'],
  array['Действующее удостоверение права на жилищную помощь','Подтверждения зарплаты','Документы о самостоятельной деятельности и доходе — после открытия','Подтверждение алиментов — если применимо'],
  array['На каком основании сейчас выдана помощь на аренду — по пособию Битуах Леуми или по проверке дохода?'],
  array['Официальная страница указывает порог для дохода от работы и алиментов, но не описывает на этой странице отдельную формулу учёта каждого вида дохода самостоятельного бизнеса.','Точный действующий порог зависит от состава семьи и обновляется.'],
  '[]'::jsonb,
  array['одинокий родитель','помощь на аренду','доход','бизнес','осек патур','самозанятый','порог'],
  'одинокий родитель мать отец помощь аренда повышенная доход бизнес осек патур עצמאי зарплата 20 часов прожиточный минимум Министерство алии порог дохода'
from public.topics t join public.sources s on s.slug='housing-single-parent-rent-current'
where t.slug='housing_support'
on conflict (slug) do update set
  topic_id=excluded.topic_id, source_id=excluded.source_id, title=excluded.title,
  short_answer=excluded.short_answer, answer=excluded.answer, steps=excluded.steps,
  documents=excluded.documents, follow_up_questions=excluded.follow_up_questions,
  caveats=excluded.caveats, keywords=excluded.keywords, search_text=excluded.search_text,
  is_published=true, reviewed_on='2026-09-17', ai_embedding_allowed=true, embedding=null;

-- Retroactive rent-assistance differences: separate agency-calculation problem from ordinary eligibility.
insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id,
  'housing-rent-retroactive-differences',
  'Недополученная помощь на аренду и ретроактивный перерасчёт',
  'Процедура Минстроя предусматривает выплату разницы при изменении уровня помощи; для права, зависящего от решения Битуах Леуми или от проверки дохода, разница обычно ограничена тремя месяцами ретроактивно.',
  'Практический вопрос начинается с причины пропуска: было ли право подтверждено раньше, но данные не дошли/не были обработаны, или необходимые документы и заявление были поданы позже самим заявителем. Для обычного перерасчёта процедура 08/04 ограничивает разницу тремя месяцами по соответствующему основанию. Если заявитель считает, что потеря выплат возникла из-за ошибки ведомства или передачи данных, нужно сначала получить письменную хронологию и расчёт, а не ограничиваться устным ответом.',
  array['Соберите решение о праве, договор аренды и даты фактической подачи/приёма документов.','Письменно запросите у ведомства или компании регистрации дату начала права и расчёт месяцев, за которые помощь была или не была начислена.','Если данные должны были передать между ведомствами, отдельно попросите подтвердить дату передачи и получения.','Если расчёт не исправлен, подайте письменное требование о перерасчёте с приложенной хронологией и сохраните номер обращения.'],
  array['Решение/удостоверение права','Договор аренды за спорный период','Подтверждения подачи документов','История начислений/выплат','Переписка с ведомствами'],
  array['Право было подтверждено раньше, а выплата не пришла из-за обработки данных, или заявление/документы были поданы только позже?'],
  array['Правило о трёх месяцах относится к обычному перерасчёту по процедуре 08/04 и не решает автоматически спор о доказанной ошибке ведомства.','Для более раннего периода может потребоваться индивидуальное решение или обжалование.'],
  '[]'::jsonb,
  array['аренда','ретроактивно','три месяца','перерасчёт','ошибка ведомства','недоплата'],
  'помощь аренда недополучили ретроактивно 3 месяца три месяца ошибка министерства передача данных очередь социальное жилье перерасчет договор с февраля выплатили с августа'
from public.topics t join public.sources s on s.slug='housing-rent-procedure-0804'
where t.slug='housing_support'
on conflict (slug) do update set
  topic_id=excluded.topic_id, source_id=excluded.source_id, title=excluded.title,
  short_answer=excluded.short_answer, answer=excluded.answer, steps=excluded.steps,
  documents=excluded.documents, follow_up_questions=excluded.follow_up_questions,
  caveats=excluded.caveats, keywords=excluded.keywords, search_text=excluded.search_text,
  is_published=true, reviewed_on='2026-09-17', ai_embedding_allowed=true, embedding=null;

-- Disability -> old age is its own transition, not an ordinary first old-age claim.
insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id,
  'disability-to-old-age-transition',
  'Переход с общей инвалидности на пособие по старости',
  'Получатель общей инвалидности получает её до пенсионного возраста, а с пенсионного возраста переходит на пособие по старости. Пособие по старости при таком переходе не должно быть ниже последней месячной выплаты общей инвалидности; при необходимости добавляется доплата по инвалидности.',
  'Это отдельный переходный маршрут, поэтому вопрос человека, уже получающего общую инвалидность, нельзя автоматически рассматривать как обычное первичное заявление на пособие по старости. Сначала нужно определить пенсионный возраст по дате рождения и проверить именно переход с существующей выплаты.',
  array['Определите пенсионный возраст по дате рождения.','Проверьте последнее решение и размер общей инвалидности перед пенсионным возрастом.','После перехода сравните первую выплату по старости с последней месячной выплатой инвалидности.','Если новая сумма ниже, запросите проверку доплаты по инвалидности к пособию по старости.'],
  array['Решение о пособии по общей инвалидности','Последнее подтверждение размера выплаты','Решение о назначении пособия по старости'],
  array['Вы уже получаете общую инвалидность непрерывно до пенсионного возраста или речь о первом заявлении после пенсионного возраста?'],
  array['Эта карточка описывает переход уже получавшего общую инвалидность и не заменяет проверку отдельных надбавок, доходных тестов или семейных компонентов.'],
  '[]'::jsonb,
  array['инвалидность в старость','пенсионный возраст','доплата по инвалидности','переход','пособие по старости'],
  'постоянная инвалидность 100 нетрудоспособность переход на старость пенсия без стажа комиссия супруг зарплата автомобиль пособие вместо инвалидности'
from public.topics t join public.sources s on s.slug='btl-disability-old-age-transition-current'
where t.slug='old_age'
on conflict (slug) do update set
  topic_id=excluded.topic_id, source_id=excluded.source_id, title=excluded.title,
  short_answer=excluded.short_answer, answer=excluded.answer, steps=excluded.steps,
  documents=excluded.documents, follow_up_questions=excluded.follow_up_questions,
  caveats=excluded.caveats, keywords=excluded.keywords, search_text=excluded.search_text,
  is_published=true, reviewed_on='2026-09-17', ai_embedding_allowed=true, embedding=null;

insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id,
  'old-age-retirement-age-woman-1966',
  'Пенсионный возраст женщины 1966 года рождения',
  'Для женщины, родившейся с января по декабрь 1966 года, пенсионный возраст по таблице Битуах Леуми составляет 64 года.',
  'Пенсионный возраст женщин в Израиле постепенно повышается и определяется месяцем и годом рождения. Для всего 1966 года таблица Битуах Леуми указывает 64 года.',
  array['Проверьте месяц и год рождения.','Сверьте их с актуальной таблицей пенсионного возраста Битуах Леуми.'],
  array['Удостоверение личности/дата рождения'],
  array[]::text[],
  array['Пенсионный возраст не следует определять по общему правилу без проверки года рождения женщины.'],
  '[]'::jsonb,
  array['1966','64 года','пенсионный возраст','женщина'],
  'женщина 1966 года рождения пенсионный возраст 64 пособие по старости переход инвалидность'
from public.topics t join public.sources s on s.slug='btl-retirement-age-current'
where t.slug='old_age'
on conflict (slug) do update set
  topic_id=excluded.topic_id, source_id=excluded.source_id, title=excluded.title,
  short_answer=excluded.short_answer, answer=excluded.answer, steps=excluded.steps,
  documents=excluded.documents, follow_up_questions=excluded.follow_up_questions,
  caveats=excluded.caveats, keywords=excluded.keywords, search_text=excluded.search_text,
  is_published=true, reviewed_on='2026-09-17', ai_embedding_allowed=true, embedding=null;

-- Long-term care worsening: the real action is reassessment, not a generic disability application.
insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id,
  'long-term-care-worsening-reassessment',
  'Как увеличить помощь по уходу при ухудшении состояния',
  'Если состояние получателя пособия по уходу ухудшилось, можно подать просьбу о повторной проверке. При такой проверке уровень права может повыситься или остаться прежним, но не должен быть снижен; более высокий уровень выплачивается с восьмого дня после подачи просьбы.',
  'Для человека, который уже получает помощь по уходу, ухудшение состояния — это отдельный процесс пересмотра существующего уровня. Битуах Леуми просит представить актуальные медицинские документы, подтверждающие ухудшение. Получатель максимального уровня 6 не может подать такую просьбу о повторной проверке.',
  array['Соберите свежие медицинские документы, где описано ухудшение и функциональные ограничения.','Подайте просьбу о повторной проверке права по уходу через службу отправки документов или отделение Битуах Леуми.','Сохраните дату подачи: при повышении уровня новая выплата начинается с восьмого дня после просьбы.','Проверьте новое решение и уровень часов/услуг после пересмотра.'],
  array['Актуальный подробный медицинский документ','Документы о функциональном ухудшении','Подтверждение даты подачи просьбы'],
  array['Какой уровень пособия по уходу установлен сейчас?'],
  array['Если уже установлен максимальный уровень 6, повторная проверка по ухудшению не подаётся по этому маршруту.','Вопрос о новом заявлении на общую инвалидность после пенсионного возраста — отдельная тема; его нельзя смешивать с пересмотром ухода.'],
  '[]'::jsonb,
  array['метапелет','уход','ухудшение','повторная проверка','часы ухода','союд','сיעוד'],
  'пожилая онкология метапелет увеличить часы уход ухудшение состояния повторная проверка пособие по уходу סיעוד восемь дней'
from public.topics t join public.sources s on s.slug='btl-long-term-care-worsening-current'
where t.slug='old_age'
on conflict (slug) do update set
  topic_id=excluded.topic_id, source_id=excluded.source_id, title=excluded.title,
  short_answer=excluded.short_answer, answer=excluded.answer, steps=excluded.steps,
  documents=excluded.documents, follow_up_questions=excluded.follow_up_questions,
  caveats=excluded.caveats, keywords=excluded.keywords, search_text=excluded.search_text,
  is_published=true, reviewed_on='2026-09-17', ai_embedding_allowed=true, embedding=null;

-- Entitlement window vs bank of payable unemployment days.
insert into public.knowledge_cards (
  topic_id, source_id, slug, title, short_answer, answer, steps, documents,
  follow_up_questions, caveats, hebrew_terms, keywords, search_text,
  is_published, reviewed_on, ai_embedding_allowed
)
select t.id, s.id,
  'unemployment-entitlement-window-vs-days',
  'Срок реализации права на авталу и количество оплачиваемых дней — не одно и то же',
  'У пособия по безработице есть два разных ограничения: число оплачиваемых дней и календарный период, внутри которого эти дни можно использовать. Если все положенные дни закончились раньше календарной даты, дальнейших выплат в этом периоде уже нет; если выплаты прерывались, неиспользованные дни можно реализовать только пока календарный период ещё действует.',
  'Битуах Леуми определяет максимальное число дней и период их использования. Для женщин 57–67 лет, родившихся 1 января 1960 года или позже, специальное правило — до 300 оплачиваемых дней в течение 18 месяцев. Поэтому дата «право действует до…» не обещает выплаты до этой даты: это крайняя дата использования оставшегося банка дней.',
  array['В личном кабинете отдельно найдите дату начала/конца периода права и отдельно количество уже оплаченных/оставшихся дней.','Если выплаты временно прекращались из-за работы, проверьте, остались ли неиспользованные дни и не истёк ли календарный период.','Если все дни уже использованы, не ориентируйтесь на более позднюю календарную дату как на обещание дополнительных выплат.','Для нового самостоятельного периода права отдельно проверяйте выполнение нового страхового периода, а не только дату старого решения.'],
  array['Решение о праве на пособие','История оплаченных дней по месяцам','Данные о периодах работы между выплатами'],
  array['Сколько дней из назначенного лимита фактически осталось и когда заканчивается календарный период права?'],
  array['Для повторных требований могут действовать дополнительные правила учёта предыдущих выплат.','Карточка объясняет разницу между календарным окном и банком дней; она не создаёт новый лимит после исчерпания дней.'],
  '[]'::jsonb,
  array['300 дней','18 месяцев','срок права','до 31 мая','до 31 марта','вернулась на работу','остаток дней'],
  'автала 300 дней срок реализации право до 31 мая 31 марта период 18 месяцев закончились дни раньше вернулась на работу прерывается окно право банк дней'
from public.topics t join public.sources s on s.slug='btl-unemployment-duration-current'
where t.slug='unemployment'
on conflict (slug) do update set
  topic_id=excluded.topic_id, source_id=excluded.source_id, title=excluded.title,
  short_answer=excluded.short_answer, answer=excluded.answer, steps=excluded.steps,
  documents=excluded.documents, follow_up_questions=excluded.follow_up_questions,
  caveats=excluded.caveats, keywords=excluded.keywords, search_text=excluded.search_text,
  is_published=true, reviewed_on='2026-09-17', ai_embedding_allowed=true, embedding=null;

-- Make the existing old-age/unemployment card more operational for debt/recalculation questions.
update public.knowledge_cards
set steps = array[
      'Если Битуах Леуми проверяет совместимость выплат, не считайте это само по себе признаком, что две выплаты запрещены.',
      'Проверьте, изменился ли размер пособия по старости после учёта авталы как дохода.',
      'Если появился долг или приостановка, запросите письменный помесячный расчёт и проверьте, относится ли изменение к базовому пособию или к доходной надбавке.'
    ],
    search_text = search_text || ' проверка совместимости долг перерасчет помесячный расчет приостановили выплаты',
    embedding = null,
    reviewed_on = '2026-09-17'
where slug='unemployment-old-age-concurrent-woman';
