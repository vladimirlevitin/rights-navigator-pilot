-- Expand verified pilot coverage from benchmark batch tatiana_2026-09-17_021119.
-- Tatiana's answers are benchmark signals only; cards below are grounded in cited official sources.

insert into public.sources (slug, publisher, title, url, language, is_official, is_published, checked_on) values
  ('tax-retirement-guide-2026', 'Налоговое управление Израиля', 'Налогообложение при прекращении работы и форма 161', 'https://www.gov.il/he/pages/retirement-from-work-2023?chapterindex=19', 'he', true, true, '2026-09-17'),
  ('tax-disability-exemption-1516', 'Налоговое управление Израиля', 'Освобождение от подоходного налога для людей с инвалидностью — форма 1516', 'https://www.gov.il/he/service/itc1516', 'he', true, true, '2026-09-17'),
  ('labor-severance-package', 'Министерство труда Израиля', 'Выплата выходного пособия', 'https://www.gov.il/he/pages/severance-package?chapterindex=1', 'he', true, true, '2026-09-17'),
  ('btl-unemployment-termination-current', 'Битуах Леуми', 'Причины прекращения работы и их влияние на пособие по безработице', 'https://www.btl.gov.il/benefits/Unemployment/Pages/nesibothafsakatavoda.aspx', 'he', true, true, '2026-09-17'),
  ('btl-unemployment-registration-current', 'Битуах Леуми', 'Регистрация и явка в Службе занятости', 'https://www.btl.gov.il/benefits/Unemployment/Pages/Avtala_att.aspx', 'he', true, true, '2026-09-17'),
  ('btl-unemployment-other-benefits-current', 'Битуах Леуми', 'Получатель других пособий и пособие по безработице', 'https://www.btl.gov.il/benefits/Unemployment/Pages/%D7%9C%D7%9E%D7%A7%D7%91%D7%9C%20%D7%A7%D7%A6%D7%91%D7%90%D7%95%D7%AA%20%D7%A0%D7%95%D7%A1%D7%A4%D7%95%D7%AA%20%D7%91%D7%9E%D7%95%D7%A1%D7%93.aspx', 'he', true, true, '2026-09-17'),
  ('btl-old-age-wage-differences', 'Битуах Леуми', 'Расчёт дополнительных выплат и разницы зарплаты при проверке дохода', 'https://www.btl.gov.il/benefits/old_age/Conditions_of_eligibility/Pages/HacnasaZikna.aspx', 'he', true, true, '2026-09-17'),
  ('btl-disability-nonwork-income', 'Битуах Леуми', 'Как доход не от работы влияет на пособие по общей инвалидности', 'https://www.btl.gov.il/About/faq/%D7%A0%D7%9B%D7%95%D7%AA%20%D7%9B%D7%9C%D7%9C%D7%99%D7%AA/Pages/hajnasotShelomeavoda.aspx', 'he', true, true, '2026-09-17'),
  ('btl-disability-payment-current', 'Битуах Леуми', 'Выплата пособия по общей инвалидности', 'https://www.btl.gov.il/benefits/Disability/Pages/%D7%AA%D7%A9%D7%9C%D7%95%D7%9D%20%D7%94%D7%A7%D7%A6%D7%91%D7%94.aspx', 'he', true, true, '2026-09-17'),
  ('btl-disability-card-current', 'Битуах Леуми', 'Удостоверение человека с инвалидностью', 'https://www.btl.gov.il/benefits/Disability/otherbenefits/Pages/teudatNehut.aspx', 'he', true, true, '2026-09-17'),
  ('btl-disability-other-rights-current', 'Битуах Леуми', 'Проверка прав получателей пособий в других учреждениях', 'https://www.btl.gov.il/AllRights/Pages/mosdot.aspx?n_id=4', 'he', true, true, '2026-09-17'),
  ('btl-shaagat-hari-halat-2026', 'Битуах Леуми', 'Компенсации за ХАЛАТ в рамках «Шаагат ха-Ари»', 'https://www.btl.gov.il/StateOfEmergency/ShaagatHari/Pages/halat-shaagatHari1.aspx', 'he', true, true, '2026-09-17')
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
  'severance-tax-exemption-2026',
  'Налог на пицуим при прекращении работы в 2026 году',
  'Удержание 35% не является автоматическим правилом для всей суммы пицуим. Налоговое освобождение для выходного/пенсионного гранта ограничено меньшей из величин: 150% последней месячной зарплаты за каждый год работы или 13 750 ₪ за каждый год работы; облагается только сумма сверх применимого освобождения.',
  'Налоговое управление рассматривает средства при прекращении работы как пенсионный/выходной грант. Освобождённая сумма определяется по правилам раздела 9(7а): до 150% последней месячной зарплаты за каждый год работы, но не выше установленного потолка 13 750 ₪ за год работы в 2026 году. Если фактический грант выше освобождённой суммы, превышение облагается подоходным налогом по применимым правилам и ставке конкретного человека. Поэтому нельзя считать, что со всей суммы автоматически удерживается 35%.',
  array['Получите полностью заполненную форму 161 и сведения о суммах пицуим.','Определите стаж и последнюю учитываемую зарплату.','Для облагаемой части проверьте налоговые инструкции и возможную координацию/распределение налога.'],
  array['Форма 161','Расчёт суммы пицуим','Данные о последней зарплате и стаже'],
  array[]::text[],
  array['Точный налог зависит от состава выплат, формы 161 и индивидуальной налоговой ситуации.','Эта карточка не определяет само право на пицуим — только налоговый режим выплаты при прекращении работы.'],
  '[]'::jsonb,
  array['35%','налог на пицуим','выходное пособие','13 750','13750','150%','форма 161'],
  'налог пицуим выходное пособие удержание 35 процентов 13750 13 750 150 процентов последняя зарплата стаж форма 161 освобождение превышение'
from public.topics t join public.sources s on s.slug='tax-retirement-guide-2026'
where t.slug='severance'
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
  'severance-tax-disability-exemption',
  'Инвалидность и освобождение от подоходного налога при выплате пицуим',
  'Высокий медицинский процент инвалидности не отменяет налог автоматически. Человек с установленной медицинской инвалидностью свыше 90% может подать заявление на освобождение от подоходного налога; для применения льготы плательщику нужно действующее подтверждение Налогового управления.',
  'Налоговое управление предоставляет процедуру заявления на освобождение от подоходного налога людям с установленной инвалидностью свыше 90% по правилам раздела 9(5). Наличие 100% степени утраты трудоспособности Битуах Леуми само по себе не заменяет медицинский процент и налоговое подтверждение. Если освобождение утверждено, его нужно представить работодателю, пенсионной кассе или иному плательщику; точный охват освобождения конкретной выплаты проверяется по налоговым инструкциям.',
  array['Проверьте, есть ли у вас действующее решение о медицинском проценте инвалидности.','Если освобождение ещё не оформлено, подайте заявление в Налоговое управление по форме 1516.','Перед выплатой передайте действующее подтверждение освобождения работодателю или кассе.'],
  array['Медицинский протокол','Подтверждение Налогового управления об освобождении от налога','Форма 161 — если речь о пицуим'],
  array[]::text[],
  array['Не смешивайте медицинский процент инвалидности и степень потери трудоспособности — это разные показатели.','Льгота требует отдельного налогового оформления и не означает автоматически, что любая выплата полностью освобождена.'],
  '[]'::jsonb,
  array['инвалидность','90%','100%','освобождение от налога','форма 1516','пицуим'],
  'инвалидность 90 100 медицинская освобождение подоходный налог форма 1516 пицуим выходное пособие налоговое управление'
from public.topics t join public.sources s on s.slug='tax-disability-exemption-1516'
where t.slug='severance'
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
  'termination-agreement-unemployment',
  'Соглашение сторон и пособие по безработице',
  'Само название «соглашение сторон» не даёт безопасного основания автоматически считать прекращение работы увольнением работодателем для авталы. Битуах Леуми различает увольнение работодателем и добровольное увольнение: при добровольном уходе без уважительной причины действует ожидание 90 дней.',
  'Официальные правила Битуах Леуми связывают начало выплаты с причиной прекращения работы. При увольнении работодателем или окончании договора право может начаться с первой регистрации, а при добровольном увольнении без уважительной причины — только через 90 дней. Поэтому в соглашении о прекращении важно, что фактически произошло и как это подтверждено документами; одна фраза «по соглашению сторон» не заменяет проверку причины прекращения.',
  array['До подписания проверьте, как в документе описаны инициатор и причина прекращения работы.','Сохраните соглашение и письмо работодателя о прекращении.','После фактического прекращения работы зарегистрируйтесь в Службе занятости без ожидания окончания 90 дней.'],
  array['Письменное соглашение о прекращении работы','Письмо работодателя/подтверждение даты и причины окончания работы'],
  array['Что написано в соглашении о том, кто инициировал прекращение работы?'],
  array['Навигатор не должен обещать немедленную авталу только потому, что стороны подписали соглашение.','Окончательную квалификацию прекращения работы делает Битуах Леуми по документам и обстоятельствам.'],
  '[]'::jsonb,
  array['соглашение сторон','автала','безработица','90 дней','увольнение работодателем'],
  'соглашение сторон прекращение работы увольнение работодатель добровольное увольнение автала пособие по безработице 90 дней причина прекращения документы'
from public.topics t join public.sources s on s.slug='btl-unemployment-termination-current'
where t.slug='unemployment'
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
  'termination-agreement-severance',
  'Соглашение сторон и право на пицуим',
  'Право на обязательные пицуим определяется обстоятельствами прекращения работы, а не одной надписью «по соглашению сторон». При увольнении работодателем право обычно проверяется по стажу и отчислениям; при уходе работника — только по предусмотренным законом основаниям. Стороны могут отдельно письменно договориться о выплате.',
  'Министерство труда указывает, что обязательное право на пицуим связано с минимальным стажем и прекращением трудовых отношений в признанных законом обстоятельствах. Увольнение работодателем и добровольный уход различаются; для добровольного ухода перечислены специальные случаи, когда он приравнивается к увольнению. Поэтому при «соглашении сторон» нужно отдельно читать условия выплаты и не считать сам ярлык автоматическим основанием для полного пицуим.',
  array['Проверьте, что именно соглашение обещает выплатить и кто указан инициатором прекращения.','Получите сведения о накопленном компоненте пицуим и форму 161.','Не подписывайте отказ от требований, не поняв, какие выплаты уже включены в соглашение.'],
  array['Соглашение о прекращении работы','Отчёт пенсионного фонда','Форма 161'],
  array['Предусмотрена ли в соглашении конкретная сумма или полный расчёт пицуим?'],
  array['Договорная выплата и обязательное по закону право на пицуим — не одно и то же.','Конкретное соглашение может требовать индивидуальной проверки текста.'],
  '[]'::jsonb,
  array['соглашение сторон','пицуим','выходное пособие','увольнение'],
  'соглашение сторон пицуим выходное пособие прекращение работы увольнение работодатель добровольный уход условия соглашения форма 161'
from public.topics t join public.sources s on s.slug='labor-severance-package'
where t.slug='severance'
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
  'old-age-wage-differences-allocation',
  'Как Битуах Леуми относит разницу зарплаты к месяцам при проверке дохода',
  'Разница зарплаты относится к тем месяцам, за которые она выплачена. Если Битуах Леуми не располагает информацией о периоде, разницу относят к месяцу фактической выплаты.',
  'На странице проверки дохода для пособия по старости Битуах Леуми прямо указывает: הפרשי שכר — разница/доплата зарплаты — добавляется к месячной зарплате тех месяцев, за которые эта сумма выплачена. Только если нет сведений о соответствующем периоде, её добавляют к месяцу фактической выплаты. Поэтому при выплате в июне зарплаты, относящейся также к апрелю и маю, критично представить документы с разбивкой по месяцам.',
  array['Попросите работодателя исправить/уточнить отчётность и выдать тлуши или справку с разбивкой по апрелю, маю и июню.','Передайте в Битуах Леуми документы, показывающие, к каким месяцам относится доплата.','Попросите письменный перерасчёт долга с учётом периода, к которому относится доход.'],
  array['Тлуши за спорные месяцы','Справка работодателя о периоде, к которому относится доплата','Требование Битуах Леуми о возврате'],
  array[]::text[],
  array['Если нет информации о периоде, Битуах Леуми вправе отнести разницу к месяцу фактической выплаты по опубликованному правилу.','Итоговый размер доплаты до прожиточного минимума проверяется отдельно по правилам соответствующего пособия.'],
  '[]'::jsonb,
  array['разница зарплаты','переплата','апрель май июнь','социальная надбавка','перерасчёт'],
  'пособие по старости социальная надбавка зарплата за несколько месяцев выплачена вместе июнь апрель май разница зарплаты הפרשי שכר переплата долг перерасчет'
from public.topics t join public.sources s on s.slug='btl-old-age-wage-differences'
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
  'severance-before-retirement-age',
  'Пицуим при увольнении до достижения пенсионного возраста',
  'Специальное правило, приравнивающее добровольное увольнение к увольнению работодателем из-за выхода на пенсию, действует после достижения пенсионного возраста. Самостоятельный уход за год до этого возраста не получает эту льготу автоматически.',
  'Министерство труда указывает, что добровольное увольнение после достижения пенсионного возраста рассматривается как увольнение для целей пицуим при соблюдении условий. Если работник ещё не достиг пенсионного возраста, это специальное основание само по себе не действует. Если отношения прекращает работодатель, применяются обычные правила увольнения; если работник уходит сам, нужно искать другое предусмотренное законом основание либо условия конкретного соглашения.',
  array['Не подписывайте добровольное увольнение только из-за приближения пенсионного возраста, рассчитывая на автоматический полный пицуим.','Уточните, кто фактически инициирует прекращение работы и что будет указано письменно.','Проверьте пенсионные отчисления и накопленный компонент пицуим.'],
  array['Письменное уведомление/предложение работодателя','Отчёт пенсионного фонда','Трудовой договор или соглашение о прекращении'],
  array['Кто фактически инициирует прекращение работы — работодатель или вы?'],
  array['Эта карточка не оценивает возможную возрастную дискриминацию; это отдельный трудовой вопрос.','При наличии существенного ухудшения условий или других специальных оснований добровольное увольнение может оцениваться иначе.'],
  '[]'::jsonb,
  array['до пенсии','за год до пенсии','пенсионный возраст','пицуим','вынуждают уйти'],
  'за год до пенсионного возраста вынуждают уйти добровольное увольнение пицуим выходное пособие до пенсии пенсионный возраст работодатель'
from public.topics t join public.sources s on s.slug='labor-severance-package'
where t.slug='severance'
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
  'unemployment-old-age-concurrent-woman',
  'Одновременное получение пособия по безработице и пособия по старости',
  'Женщина, которая одновременно отвечает условиям пособия по безработице и пособия по старости, может получать обе выплаты. Пособие по безработице учитывается как доход от работы при расчёте пособия по старости.',
  'Битуах Леуми прямо указывает, что женщина, имеющая одновременно право на пособие по безработице и пособие по старости, получает обе выплаты. При этом пособие по безработице учитывается как доход от работы для расчёта пособия по старости. Само право на авталу всё равно проверяется по обычным условиям — возраст до 67 лет, страховой период, причина прекращения работы и регистрация.',
  array['После прекращения работы зарегистрируйтесь в Службе занятости.','Подайте заявление на пособие по безработице и сообщите о получаемом пособии по старости.','Проверьте, изменился ли размер пособия по старости из-за учёта авталы как дохода.'],
  array['Решение о пособии по старости','Документы о прекращении работы'],
  array[]::text[],
  array['Для добровольного увольнения без уважительной причины отдельно действует 90-дневный период ожидания.','Совместимость выплат не отменяет проверки всех условий каждого пособия.'],
  '[]'::jsonb,
  array['старость и автала','два пособия','64 года','безработица','пенсия'],
  '64 года пособие по старости автала пособие по безработице одновременно две выплаты женщина 62 67 увольнение'
from public.topics t join public.sources s on s.slug='btl-unemployment-other-benefits-current'
where t.slug='unemployment'
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
  'unemployment-private-disability-pension',
  'Выплата по потере трудоспособности из страховой/пенсионной системы и автала',
  'Если выплата по потере трудоспособности от страховой компании не требует выхода на пенсию/прекращения работы как условия выплаты, Битуах Леуми не считает её пенсионной выплатой и не вычитает из авталы. Если для получения выплаты требуется формальный выход на пенсию, она считается пенсионным доходом и вычитается.',
  'На странице доходов во время безработицы Битуах Леуми отдельно рассматривает קצבת אובדן כושר עבודה. Выплата из страховой компании при временной или постоянной потере трудоспособности, которая не требует выхода на пенсию, не считается пенсией по прекращению работы и не вычитается из пособия по безработице. У работодателей/систем, где плохое здоровье требует выхода на пенсию для получения такой выплаты, она рассматривается как пенсионная и вычитается из авталы.',
  array['Запросите у фонда или страховой компании письменные условия выплаты.','Проверьте, требует ли выплата формального выхода на пенсию/прекращения работы.','Передайте Битуах Леуми документы о виде выплаты, если её нужно учитывать при расчёте авталы.'],
  array['Правила пенсионного фонда/страхового полиса','Решение о выплате по потере трудоспособности'],
  array['Требует ли эта выплата формального выхода на пенсию как условия её получения?'],
  array['Размер самой выплаты по потере трудоспособности определяется правилами конкретного фонда/полиса, а не Битуах Леуми.'],
  '[]'::jsonb,
  array['потеря трудоспособности','пенсионный фонд','автала','пенсия по инвалидности','страховая компания'],
  'потеря трудоспособности выплата пенсионный фонд страховая компания пенсия инвалидности автала пособие по безработице одновременно вычитается требует выхода на пенсию'
from public.topics t join public.sources s on s.slug='btl-unemployment-income-current'
where t.slug='unemployment'
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
  'disability-nonwork-income-dependents',
  'Как доход не от работы влияет на пособие по общей инвалидности',
  'Доход не от работы, включая некоторые пенсионные/страховые выплаты, прежде всего может уменьшать часть пособия сверх полной базовой выплаты — в том числе надбавки за супруга и детей; базовая полная выплата не должна уменьшаться ниже установленного полного размера по опубликованному правилу.',
  'Битуах Леуми отдельно учитывает доходы не от работы — например пенсию, аренду, стипендию, другие пособия и доходы от инвестиций. Если общая выплата включает надбавки за супруга/детей и превышает полный базовый размер, часть дохода не от работы может уменьшить эту надбавочную часть по текущим правилам. Если выплата не превышает полный базовый размер, доход не от работы её не уменьшает по опубликованному правилу.',
  array['Уточните, является ли выплата регулярным доходом не от работы.','Проверьте, получаете ли вы надбавки за супруга или детей.','Передайте Битуах Леуми сведения о новой выплате для перерасчёта.'],
  array['Решение о выплате из фонда/страховой компании','Решение Битуах Леуми о составе пособия по инвалидности'],
  array[]::text[],
  array['Точные суммы и необлагаемая/неучитываемая часть ежегодно обновляются.','Эта карточка не определяет условия выплаты пенсионного фонда.'],
  '[]'::jsonb,
  array['доход не от работы','пенсия','страховая выплата','надбавка супруг дети','инвалидность'],
  'общая инвалидность доход не от работы пенсия страховая выплата потеря трудоспособности надбавка супруг дети влияет на пособие'
from public.topics t join public.sources s on s.slug='btl-disability-nonwork-income'
where t.slug='disability'
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
  'disability-payment-current-month',
  'Пособие по инвалидности выплачивается за текущий месяц',
  'Пособие по общей инвалидности перечисляется 28-го числа каждого месяца за этот же месяц. Если право действует до конца августа и прекращается с 1 сентября, обычная выплата 28 августа относится к августу.',
  'Битуах Леуми публикует правило: пособие по общей инвалидности выплачивается 28-го числа каждого месяца за тот же месяц. Дата может быть сдвинута из-за праздников. Поэтому если решение прекращает право только с 1 сентября, август остаётся месяцем действующего права; окончательный статус конкретной выплаты всё равно сверяется с решением.',
  array['Проверьте в решении точную дату прекращения права.','Сверьте календарь выплат Битуах Леуми, если 28-е приходится на период праздничного переноса.'],
  array['Решение об изменении степени/прекращении пособия'],
  array[]::text[],
  array['Если в решении указана иная дата прекращения или есть перерасчёт задним числом, результат может отличаться.'],
  '[]'::jsonb,
  array['28 августа','выплата за август','прекращается 1 сентября','инвалидность'],
  'пособие инвалидность выплата 28 августа текущий месяц прекращается с 1 сентября последняя выплата дата'
from public.topics t join public.sources s on s.slug='btl-disability-payment-current'
where t.slug='disability'
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
  'disability-arnona-thresholds',
  'Арнона после изменения статуса общей инвалидности',
  'Для скидки по арноне среди оснований фигурирует получение общей инвалидности со степенью потери трудоспособности 75% и выше либо медицинская инвалидность 90% и выше; конкретный размер и предоставление скидки определяет муниципалитет.',
  'Материалы Битуах Леуми о льготах указывают две отдельные категории: получатели общей инвалидности со степенью потери трудоспособности не ниже 75% и лица с медицинской инвалидностью не ниже 90%. Поэтому снижение степени до 55% может прекратить основание, связанное с 75% утраты трудоспособности, если нет другого основания. Фактическую скидку и дату её изменения определяет муниципалитет.',
  array['Проверьте в новом решении именно степень потери трудоспособности и медицинский процент.','Передайте обновлённое решение в муниципалитет и запросите письменное решение по скидке.'],
  array['Решение Битуах Леуми о степени потери трудоспособности','Решение о медицинском проценте','Счёт/регистрация арноны'],
  array[]::text[],
  array['Размер скидки устанавливается муниципалитетом и может зависеть от дополнительных местных условий.'],
  '[]'::jsonb,
  array['арнона','55%','75%','90%','инвалидность','скидка'],
  'инвалидность 55 75 90 арнона скидка степень потери трудоспособности медицинская инвалидность муниципалитет'
from public.topics t join public.sources s on s.slug='btl-disability-other-rights-current'
where t.slug='disability'
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
  'disability-transport-card-validity',
  'Льгота на общественный транспорт и действующее удостоверение инвалида',
  '50% скидка на общественный транспорт предоставляется получателям общей инвалидности/других указанных пособий при наличии удостоверения инвалида. Удостоверение обычно действует до окончания периода права на пособие; специальное продление льгот на 36 месяцев опубликовано для случая прекращения инвалидности только из-за дохода от работы.',
  'Битуах Леуми указывает, что удостоверение инвалида действует до окончания периода права на пособие, если этот срок наступает раньше общего срока действия карты. Для скидки на общественный транспорт требуется соответствующий статус и профиль льготы. Отдельное правило о сохранении сопутствующих льгот на 36 месяцев относится к прекращению пособия из-за высоких доходов от работы; его нельзя автоматически переносить на прекращение из-за снижения степени инвалидности.',
  array['Проверьте срок действия цифрового/пластикового удостоверения инвалида.','Проверьте профиль льготы в Rav-Kav/приложении после даты изменения права.','Если льгота исчезла, уточните основание у Битуах Леуми и оператора транспортного профиля.'],
  array['Удостоверение инвалида','Решение об изменении права на пособие'],
  array[]::text[],
  array['Решение о транспортной скидке реализует транспортный орган; Битуах Леуми передаёт данные о потенциальных получателях.'],
  '[]'::jsonb,
  array['проезд','транспорт','удостоверение инвалида','55%','льгота','Rav-Kav'],
  'скидка проезд общественный транспорт удостоверение инвалида срок действия пособие прекращается 55 процентов rav kav 50 процентов'
from public.topics t join public.sources s on s.slug='btl-disability-card-current'
where t.slug='disability'
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
  'unemployment-self-employed-income-annual',
  'Как доход от малого бизнеса уменьшает пособие по безработице',
  'Обычно доход человека как самостоятельного предпринимателя во время получения авталы рассчитывается по годовому доходу: годовой доход делится на 12 и затем на 30. Его нельзя обычным способом привязать только к конкретным месяцам безработицы.',
  'Битуах Леуми указывает, что самостоятельный предприниматель может получать пособие по безработице по своей работе как наёмного сотрудника, но доход от самостоятельной деятельности вычитается. Для обычного режима доход рассчитывается на основе годового дохода; окончательный перерасчёт делают после получения окончательной налоговой оценки. Поэтому отсутствие фактического дохода в одном конкретном месяце обычно само по себе не означает нулевой доход для расчёта.',
  array['Проверьте, какой годовой доход самостоятельной деятельности учёл Битуах Леуми.','После окончательной налоговой оценки проверьте итоговый перерасчёт авталы.','Если спорный период подпадает под специальный военный режим, используйте отдельную карточку для этого периода.'],
  array['Налоговая оценка/шома по самостоятельной деятельности','Расчёт Битуах Леуми по пособию по безработице'],
  array[]::text[],
  array['Для специальных чрезвычайных периодов могут действовать отдельные правила, отличные от годового усреднения.'],
  '[]'::jsonb,
  array['самозанятый','ацмаи','малый бизнес','автала','годовой доход','среднемесячный доход'],
  'самозанятый ацмаи небольшой бизнес доход 2000 автала пособие по безработице годовой доход делить на 12 30 уменьшили выплату'
from public.topics t join public.sources s on s.slug='btl-unemployment-income-current'
where t.slug='unemployment'
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
  'unemployment-self-employed-shaagat-hari-2026',
  'Доход самозанятого при ХАЛАТе в период «Шаагат ха-Ари» 2026',
  'Для специальной схемы ХАЛАТа «Шаагат ха-Ари» работник, который одновременно является наёмным и самостоятельным, получает право по зарплате наёмного работника, а доход самостоятельной деятельности вычитается по декларации, подтверждённой бухгалтером или налоговым консультантом.',
  'Битуах Леуми отдельно установил для чрезвычайной схемы «Шаагат ха-Ари»: для человека, который одновременно работает по найму и как самостоятельный предприниматель, право на выплату основывается на работе по найму, а вычет самостоятельного дохода производится по декларации и подтверждению бухгалтера или налогового консультанта. Это специальное правило позволяет подтвердить фактический доход за соответствующий чрезвычайный период вместо автоматического переноса обычного годового усреднения без такой декларации.',
  array['Проверьте, относится ли спорная выплата к периоду специальной схемы «Шаагат ха-Ари».','Подготовьте декларацию о доходе самостоятельной деятельности за соответствующий период.','Получите подтверждение бухгалтера или налогового консультанта и передайте документы вместе с заявлением/запросом на перерасчёт.'],
  array['Декларация о доходах самостоятельной деятельности за период «Шаагат ха-Ари»','Подтверждение бухгалтера или налогового консультанта','Решение/расчёт Битуах Леуми'],
  array['Относится ли спорный период к схеме «Шаагат ха-Ари» 2026?'],
  array['Специальное правило применяется только к соответствующему чрезвычайному периоду; за другие периоды действует обычный годовой расчёт дохода самостоятельного предпринимателя.'],
  '[]'::jsonb,
  array['Шаагат ха-Ари','война','ХАЛАТ','самозанятый','бухгалтер','декларация дохода'],
  'шаагат ха ари 2026 война халат самозанятый ацмаи наемный работник декларация дохода бухгалтер налоговый консультант фактический доход период'
from public.topics t join public.sources s on s.slug='btl-shaagat-hari-halat-2026'
where t.slug='unemployment'
on conflict (slug) do update set
  topic_id=excluded.topic_id, source_id=excluded.source_id, title=excluded.title,
  short_answer=excluded.short_answer, answer=excluded.answer, steps=excluded.steps,
  documents=excluded.documents, follow_up_questions=excluded.follow_up_questions,
  caveats=excluded.caveats, keywords=excluded.keywords, search_text=excluded.search_text,
  is_published=true, reviewed_on='2026-09-17', ai_embedding_allowed=true, embedding=null;
