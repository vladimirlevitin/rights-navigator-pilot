import { expandRightsTerms } from './synonyms.js'

const RULES = [
  { key: 'severance', label: 'выходное пособие — пицуим', topics: ['severance'], pattern: /пиц(?:у|о|ы|и)?им|питцуим|пицуим|פיצוי|выходн[а-яё]*\s+пособ|компенсац[а-яё]*.{0,35}увол/iu },
  { key: 'unpaid_leave', label: 'неоплачиваемый отпуск — ХАЛАТ', topics: ['unpaid_leave'], pattern: /халат|חל[״"']?ת|неоплачиваем[а-яё]*\s+отпуск|отпуск[а-яё]*\s+за\s+свой\s+сч[её]т|(?:сидеть|сидит|оставаться|оставляет|дома).{0,40}за\s+свой\s+сч[её]т/iu },
  { key: 'disability', label: 'пособие и работа при инвалидности', topics: ['disability'], pattern: /инвалид|нехут|нехут клали|נכות|нетрудоспособ|потер[яи]\s+трудоспособ/iu },
  { key: 'unemployment', label: 'пособие по безработице — автала', topics: ['unemployment'], pattern: /автал|аватал|דמי\s+אבטלה|безработ|служб[а-яё]*\s+занятост|бирж[а-яё]*\s+труд|шерут\s+таасука|שירות\s+התעסוקה/iu }
]

function intent(key, label, topics, focus, preferred_slugs, matched_term, confidence = 'explicit') {
  return { key, label, topics, focus, preferred_slugs, confidence, matched_term }
}

export function detectIntent(text) {
  const query = expandRightsTerms(text).toLowerCase()

  if (/(?:снят|вывест|получить).{0,45}(?:пенсионн|накоплен|страхов[а-яё]*\s+компан)|(?:35\s*%|налог).{0,45}(?:пенсионн|накоплен)/iu.test(query)) {
    return intent('out_of_scope', 'снятие пенсионных накоплений — тема пока вне базы', [], 'pension_capital_withdrawal', [], 'пенсионные накопления/снятие', 'explicit')
  }

  if (/(?:реб[её]нок|доч[ьи]|сын|13[-\s]?лет).{0,120}(?:интернат|пансион|учрежден)|(?:интернат|пансион|учрежден).{0,120}(?:реб[её]нок|доч[ьи]|сын)/iu.test(query) && /инвалид|пособ|битуах|амигур|жиль/iu.test(query)) {
    return intent('child_disability_housing', 'ребёнок с инвалидностью — учреждение и жилищная помощь', ['child_disability','housing_support'], 'institution_and_housing', ['child-disability-institution','housing-household-change'], 'ребёнок + интернат/учреждение')
  }

  if (/(?:родил[аи]|после\s+род|отпуск[а-яё]*\s+по\s+уходу\s+за\s+реб[её]нк|уход[а-яё]*\s+за\s+реб[её]нк).{0,180}(?:увол|уйти|не\s+планир[а-яё]*\s+возвращ|выходн[а-яё]*\s+пособ|пиц)|(?:увол|уйти|выходн[а-яё]*\s+пособ|пиц).{0,180}(?:родил[аи]|после\s+род|уход[а-яё]*\s+за\s+реб[её]нк)/iu.test(query)) {
    return intent('severance', 'выходное пособие — пицуим', ['severance'], 'childcare_resignation', ['severance-childcare-resignation'], 'увольнение для ухода за ребёнком после родов')
  }

  if (/мигрен/iu.test(query) && /инвалид|пособ|финанс|битуах|работ|трудоспособ/iu.test(query)) {
    return intent('disability', 'общая инвалидность — мигрень', ['disability'], 'migraine', ['disability-migraine-criteria','disability-first-application','disability-application-process'], 'мигрень + инвалидность/поддержка')
  }

  if (/(?:пособи[ея]\s+по\s+старост|пенси).{0,100}(?:надбавк[а-яё]*\s+по\s+инвалид|доплат[а-яё]*\s+по\s+инвалид)|(?:надбавк[а-яё]*\s+по\s+инвалид|доплат[а-яё]*\s+по\s+инвалид).{0,100}(?:пособи[ея]\s+по\s+старост|пенси)/iu.test(query) && /льгот|электр|вод|арнон|больничн[а-яё]*\s+касс|купат/iu.test(query)) {
    return intent('old_age', 'льготы при пособии по старости с доплатой по инвалидности', ['old_age'], 'disability_supplement_benefits', ['old-age-disability-supplement-benefits','old-age-water-benefit','old-age-electricity-account-holder','old-age-arnona-senior-2026'], 'старость + доплата по инвалидности + льготы')
  }

  if (/(?:пособи[ея]\s+по\s+старост|пенси).{0,120}(?:социальн[а-яё]*\s+надбав|доплат[а-яё]*\s+(?:до\s+)?прожиточн)|(?:социальн[а-яё]*\s+надбав|доплат[а-яё]*\s+(?:до\s+)?прожиточн).{0,120}(?:пособи[ея]\s+по\s+старост|пенси)/iu.test(query) && /вод|кубометр|водн[а-яё]*\s+корпорац/iu.test(query)) {
    return intent('old_age', 'льгота на воду при пособии по старости', ['old_age'], 'water_benefit', ['old-age-water-benefit'], 'старость + социальная надбавка + вода')
  }

  if (/(?:300\s*(?:дн|дней)|предпенсион)/iu.test(query) && /безработ|автал|דמי\s+אבטלה/iu.test(query)) {
    const repeat = /(?:снова|повтор|нов[а-яё]*\s+прав|ещ[её]\s+год\s+работ|через.{0,25}работ|после.{0,35}300)/iu.test(query)
    const spouseIncome = /(?:доход|зарплат).{0,35}(?:супруг|муж|жен)|(?:супруг|муж|жен).{0,35}(?:доход|зарплат)/iu.test(query)
    const slugs = repeat
      ? ['unemployment-women-57-67-300','unemployment-repeat-claims','qualifying-period','entitlement-days',...(spouseIncome?['unemployment-spouse-income']:[])]
      : ['unemployment-women-57-67-300','entitlement-days',...(spouseIncome?['unemployment-spouse-income']:[])]
    return intent('unemployment', 'пособие по безработице — специальное правило 57–67', ['unemployment'], repeat ? 'repeat_after_300' : 'women_57_67_300', slugs, repeat ? '300 дней + повторная заявка' : '300 дней / предпенсионный возраст')
  }

  if (/(?:вернувш[а-яё]*\s+жител|тошав\s+хозер|репатриир.{0,60}(?:уех|вернул)|144\s*месяц|60\s*месяц|страхов[а-яё]*\s+(?:стаж|период)).{0,180}(?:пособи[ея]\s+по\s+старост|старост)|(?:пособи[ея]\s+по\s+старост|старост).{0,180}(?:вернувш[а-яё]*\s+жител|144\s*месяц|60\s*месяц|страхов[а-яё]*\s+(?:стаж|период))/iu.test(query)) {
    return intent('old_age', 'пособие по старости — страховой период', ['old_age'], 'qualifying_period', ['old-age-qualifying-period-woman'], 'старость + страховой период/вернувшийся житель')
  }

  if (/социальн[а-яё]*\s+жиль|очеред[а-яё]*.{0,20}жиль|помощ[ьи]\s+на\s+аренд/iu.test(query) && /инвалид|100\s*%|коляск|хостел/iu.test(query)) {
    return intent('housing_support', 'социальное жильё при инвалидности', ['housing_support'], 'disabled_public_housing', ['housing-disabled-wheelchair-public-housing','housing-assistance-update-details'], 'социальное жильё + инвалидность')
  }

  if (/(?:прожиточн[а-яё]*\s+минимум|пособи[ея]\s+по\s+прожиточн|income\s+support)/iu.test(query) && /(?:пенсионн[а-яё]*\s+возраст|6[3-9][,.]?\d*\s*лет|пособи[ея]\s+по\s+старост|отказ.{0,40}старост)/iu.test(query) && /арнон|социальн[а-яё]*\s+жиль|аренд/iu.test(query)) {
    return intent('senior_housing_benefits', 'льготы и жильё после пенсионного возраста при пособии по прожиточному минимуму', ['old_age','housing_support'], 'senior_income_support', ['old-age-income-support-arnona','housing-senior-income-support-options','housing-assistance-update-details'], 'прожиточный минимум + пенсионный возраст + жильё/арнона')
  }

  if (/(?:переезд|переезжа|переех).{0,120}(?:пиц|выходн[а-яё]*\s+пособ|увол)|(?:пиц|выходн[а-яё]*\s+пособ|увол).{0,120}(?:переезд|переезжа|переех)/iu.test(query)) {
    const pensionGap = /пенсионн[а-яё]*\s+(?:отчисл|программ|фонд)|не\s+делал.{0,50}отчисл|компонент.{0,20}пиц/iu.test(query)
    return intent('severance', 'пицуим при увольнении из-за переезда', pensionGap ? ['severance','employment_rights'] : ['severance'], 'relocation_and_pension', pensionGap ? ['severance-relocation-development-area','employment-pension-contributions-basic','severance-basic-right'] : ['severance-relocation-development-area','severance-basic-right'], 'переезд + увольнение/пицуим')
  }

  if (/(?:работодатель|начальник).{0,160}(?:сидеть|оставаться|дома).{0,60}за\s+свой\s+сч[её]т|(?:весь\s+месяц|30\s*дн).{0,80}за\s+свой\s+сч[её]т/iu.test(query)) {
    return intent('unpaid_leave', 'неоплачиваемый отпуск — ХАЛАТ', ['unpaid_leave'], 'initiator_and_duration', ['unpaid-leave','unpaid-leave-voluntary'], 'работодатель отправляет домой за свой счёт')
  }

  if (/(?:степен[ьи].{0,30}(?:нетрудоспособ|потер[а-яё]*\s+трудоспособ)|нетрудоспособност[ьи]).{0,20}65\s*%|65\s*%.{0,35}(?:нетрудоспособ|потер[а-яё]*\s+трудоспособ)/iu.test(query) && /зарплат|доход|зарабат|работ/iu.test(query)) {
    return intent('disability', 'пособие и работа при инвалидности', ['disability'], 'work_income_65', ['disability-income-65-2026'], '65% нетрудоспособности + заработок')
  }

  if (/(?:социальн[а-яё]*\s+надбав|доплат[а-яё]*\s+(?:до\s+)?(?:прожиточн|доход)|השלמת\s+הכנסה)/iu.test(query) && /(?:пособи[ея]\s+по\s+старост|пенси|мне\s+(?:6[7-9]|7\d|8\d)\s+лет|возраст.{0,10}(?:6[7-9]|7\d|8\d))/iu.test(query)) {
    return intent('old_age', 'пособие по старости и доплата до прожиточного минимума', ['old_age'], 'income_supplement', ['old-age-income-supplement-2026','old-age-income-supplement-assets-2026'], 'пособие по старости/возраст + социальная надбавка')
  }

  if (/(?:выход[а-яё]*\s+на\s+пенси|выходит?\s+на\s+пенси|пособи[ея]\s+по\s+старост|мне\s+(?:6[7-9]|7\d|8\d)\s+лет).{0,150}(?:скидк|льгот|сч[её]т|перепис)|(?:скидк|льгот|сч[её]т|перепис).{0,150}(?:пенси|пособи[ея]\s+по\s+старост|мне\s+(?:6[7-9]|7\d|8\d)\s+лет)/iu.test(query)) {
    return intent('old_age', 'льготы в пенсионном возрасте', ['old_age'], 'benefits_and_bills', ['old-age-supplement-benefits','old-age-discount-account-holder','old-age-arnona-senior-2026','old-age-electricity-account-holder','old-age-water-benefit','old-age-disability-supplement-benefits'], 'пенсионный возраст + льготы/счета')
  }

  if (/амигур|amigur|хостел|социальн[а-яё]*\s+жиль|общественн[а-яё]*\s+жиль|помощ[ьи]\s+на\s+аренд|помощ[ьи]\s+в\s+аренд|субсид[а-яё]*\s+на\s+аренд/iu.test(query)) {
    if (/(?:доход|пенси).{0,80}(?:учитыва|перерасч|оплат|квартплат)|(?:учитыва|перерасч|квартплат).{0,80}(?:доход|пенси)/iu.test(query)) return intent('housing_support', 'жилищная помощь и социальное жильё', ['housing_support'], 'rent_income_recalc', ['public-housing-rent-income-recalc'], 'социальное жильё + изменение дохода')
    return intent('housing_support', 'жилищная помощь и социальное жильё', ['housing_support'], 'rent_assistance', ['housing-assistance-update-details','housing-disabled-wheelchair-public-housing','housing-senior-income-support-options'], 'социальное жильё/помощь на аренду')
  }

  if (/налогов[а-яё]*\s+(?:льготн[а-яё]*\s+)?(?:единиц|балл)|льготн[а-яё]*\s+налогов[а-яё]*\s+единиц|3[,.]25|נקודות\s+זיכוי/iu.test(query) && /реб[её]н|дет|отец|мать|родител|расч[её]тн[а-яё]*\s+лист|тлуш|2026/iu.test(query)) {
    return intent('tax_credits', 'налоговые льготные единицы', ['tax_credits'], 'child_6_12', ['tax-credit-father-child-6-12-2026'], 'налоговые единицы + ребёнок')
  }

  if (/(?:пособи[ея]\s+по\s+старост|кицват\s+зикн|אזרח\s+ותיק).{0,55}(?:выплат|поступ|дата|когда|числ)|(?:выплат|когда|дата).{0,55}(?:пособи[ея]\s+по\s+старост)/iu.test(query)) return intent('old_age', 'пособие по старости', ['old_age'], 'payment_timing', ['old-age-payment-september-2026','old-age-payment-date'], 'пособие по старости + дата выплаты')

  if (/(?:взнос|страхов[а-яё]*\s+взнос|медицинск[а-яё]*\s+страхован|не\s+удержива[а-яё]*|удержива[а-яё]*).{0,55}(?:битуах|зарплат|доход)|(?:битуах|зарплат|доход).{0,55}(?:взнос|медицинск[а-яё]*\s+страхован|удержива[а-яё]*)/iu.test(query)) {
    const oldAgeEmployee = /пособи[ея]\s+по\s+старост|кицват\s+зикн|אזרח\s+ותיק/iu.test(query) && /работ|зарплат|наём|наем/iu.test(query)
    if (oldAgeEmployee) return intent('insurance_contributions', 'страховые взносы Битуах Леуми', ['insurance_contributions'], 'old_age_employee', ['insurance-old-age-recipient-employee'], 'пособие по старости + работа + взносы')
    return intent('insurance_contributions', 'страховые взносы Битуах Леуми', ['insurance_contributions'], 'nonwork_income', ['insurance-nonwork-income'], 'взносы/доход не от работы')
  }

  if (/форм(?:а|ы|у|е|ой|ою)?\s*161|тофес\s*161|טופס\s*161/iu.test(query)) return intent('severance', 'выходное пособие — пицуим', ['severance'], 'form161_tax', ['severance-form-161-tax'], 'форма 161')
  if (/окончательн[а-яё]*\s+расч[её]т|неиспользованн[а-яё]*\s+отпуск.{0,45}(?:увол|расч[её]т)|расч[её]т.{0,45}после.{0,20}увол/iu.test(query)) return intent('employment_rights', 'трудовые права и расчёты', ['employment_rights'], 'final_settlement', ['final-settlement-unused-leave', 'wage-payment-timing'], 'окончательный расчёт/неиспользованный отпуск')
  if (/(?:больнич|отпускн|73[,.]95).{0,70}(?:рассчит|начисл|процент|расч[её]тн)|(?:рассчит|начисл).{0,70}(?:больнич|отпускн)/iu.test(query)) return intent('employment_rights', 'трудовые права и расчёты', ['employment_rights'], 'leave_sick_pay', ['sick-pay-monthly', 'sick-pay-hourly', 'annual-leave-pay-calculation'], 'расчёт больничных/отпускных')
  if (/работодатель.{0,65}(?:отправ|застав|закры).{0,45}отпуск|коллективн[а-яё]*\s+отпуск|сукот.{0,35}отпуск|праздничн[а-яё]*.{0,25}отпуск/iu.test(query) && !/халат|неоплачиваем/iu.test(query)) return intent('employment_rights', 'трудовые права и расчёты', ['employment_rights'], 'employer_initiated_annual_leave', ['annual-leave-employer-initiated'], 'отпуск по инициативе работодателя')
  if (/(?:график|смен[аы]|рабоч[а-яё]*\s+врем|окончан[а-яё]*\s+смен).{0,70}(?:работодатель|измен|перен[её]с|односторон)|(?:работодатель|односторон).{0,70}(?:график|смен[аы]|рабоч[а-яё]*\s+врем)|ухудшени[ея]\s+условий\s+труда/iu.test(query)) return intent('employment_rights', 'трудовые права и расчёты', ['employment_rights'], 'material_change', ['employment-material-change'], 'изменение графика/условий труда')
  if (/мобил|подвижн|ниядут|ניידות|условн[а-яё]*\s+ссуд|алваа\s+омед|הלוואה\s+עומדת|особ[а-яё]*\s+услуг|שירותים\s+מיוחדים|автомобил/iu.test(query) && /инвалид|пособ|битуах|мобил|подвижн|ниядут/iu.test(query)) return intent('disability', 'инвалидность — мобильность и особые услуги', ['disability'], 'mobility_special_services', ['disability-special-services-mobility', 'disability-mobility-standing-loan'], 'мобильность/особые услуги/условная ссуда')
  if (/(?:оформ|подат|подава|заявлен|с\s+чего\s+начать|какие\s+документ).{0,55}(?:инвалид|нехут)|(?:инвалид|нехут).{0,55}(?:оформ|подат|подава|заявлен|с\s+чего\s+начать|документ)/iu.test(query)) return intent('disability', 'общая инвалидность', ['disability'], 'initial_application', ['disability-first-application','disability-application-process'], 'первичное оформление инвалидности')
  if (/(?:пенсионн[а-яё]*\s+возраст|выход[а-яё]*\s+на\s+пенси|в\s+связи\s+с\s+выходом\s+на\s+пенси|мне\s+(?:6[2-9]|7\d)\s+лет).{0,80}(?:пиц|выходн[а-яё]*\s+пособ|увол)|(?:пиц|выходн[а-яё]*\s+пособ).{0,80}(?:пенсионн|пенси)/iu.test(query)) return intent('severance', 'выходное пособие — пицуим', ['severance'], 'retirement_resignation', ['severance-retirement-resignation', 'severance-basic-right'], 'пенсионный возраст + увольнение/пицуим')

  const disabilityOrHealth = /инвалид|нехут|נכות|нетрудоспособ|здоров|болезн|медицин/iu.test(query)
  const employerTermination = /(?:меня\s+)?(?:увольняют|увольняет(?![а-яё])|уволили(?![а-яё])|уволил(?![а-яё]))|работодатель.{0,35}(?:увольняет(?![а-яё])|уволил(?![а-яё])|сократил(?![а-яё])|прекращает(?![а-яё])|прекратил(?![а-яё]))/iu.test(query)
  if (disabilityOrHealth && employerTermination) return intent('multi_rights', 'увольнение при инвалидности — нужно проверить несколько прав', ['severance', 'unemployment', 'disability'], 'termination_with_disability', ['severance-basic-right', 'eligibility-basics', 'register-employment-service', 'disability-stop-work', 'disability-income-change'], 'увольнение работодателем + инвалидность')

  const plannedExit = /(?:хочу|планирую|собираюсь).{0,35}(?:уйти|увол)|(?:уйти|уход).{0,25}(?:с|из)\s+работ/iu.test(query)
  if (disabilityOrHealth && plannedExit) return intent('severance', 'выходное пособие — пицуим', ['severance'], 'health_resignation', ['severance-health-resignation', 'severance-medical-proof'], 'инвалидность/здоровье + планируемый уход с работы')

  for (const rule of RULES) {
    const match = query.match(rule.pattern)
    if (!match) continue
    let focus = 'general'
    let preferred_slugs = []
    if (rule.key === 'unemployment') {
      if (/(?:сколько|максимум|на\s+какой).{0,20}(?:дн|срок)|иждивен/iu.test(query)) { focus = 'entitlement_duration'; preferred_slugs = ['entitlement-days','unemployment-women-57-67-300'] }
      else if (/12.{0,12}18|стаж|страхов[а-яё]*\s+период|ткуфат\s+ахшар/iu.test(query)) { focus = 'qualifying_period'; preferred_slugs = ['qualifying-period', 'eligibility-basics'] }
      else if (/(?:первые|удерж|не\s+оплат|без\s+оплат).{0,30}(?:5|пять)\s+дн|(?:5|пять)\s+дн.{0,45}(?:не\s+оплат|удерж|кажд|четыр|тр[её]х|4\s*месяц|3\s*месяц)|когда.{0,20}(?:плат|деньг)|17.{0,8}чис/iu.test(query)) { focus = 'payment_timing'; preferred_slugs = ['payment-timing'] }
      else if (/увол[а-яё]*.{0,25}собствен|сам[а-яё]*.{0,25}увол|хочу.{0,25}увол/iu.test(query)) { focus = 'voluntary_resignation'; preferred_slugs = ['voluntary-resignation', 'register-employment-service'] }
      else if (/регистр|отмеч|явк|шерут\s+таасука|служб[а-яё]*\s+занятост/iu.test(query)) { focus = 'registration'; preferred_slugs = ['register-employment-service', 'missed-appointment'] }
      else if (/за\s+границ|вылет|поездк|хуль/iu.test(query)) { focus = 'travel'; preferred_slugs = ['travel-abroad'] }
      else if (/ацмаи|самозанят|предпринимател/iu.test(query)) { focus = 'self_employed'; preferred_slugs = ['self-employed', 'eligibility-basics'] }
    } else if (rule.key === 'severance' && /инвалид|здоров|болезн|медицин/iu.test(query)) { focus = 'health_resignation'; preferred_slugs = ['severance-health-resignation', 'severance-medical-proof'] }
    else if (rule.key === 'disability' && /работ|зарплат|доход|зарабат/iu.test(query)) { focus = 'work_and_benefit'; preferred_slugs = ['disability-work-allowed', 'disability-income-change', 'disability-stop-work'] }
    else if (rule.key === 'unpaid_leave') { focus = 'initiator_and_duration'; preferred_slugs = ['unpaid-leave', 'unpaid-leave-voluntary'] }
    return intent(rule.key, rule.label, rule.topics, focus, preferred_slugs, match[0])
  }

  if (/пособи[ея]\s+по\s+старост|кицват\s+зикн|אזרח\s+ותיק/iu.test(query)) return intent('old_age', 'пособие по старости', ['old_age'], 'general', ['old-age-qualifying-period-woman','old-age-payment-date'], 'пособие по старости')
  if (/увол|сократ|прекрат[а-яё]*\s+работ|трудов[а-яё]*\s+договор.{0,35}(?:законч|расторг)/iu.test(query)) return intent('employment_ambiguous', 'прекращение работы — вид права нужно уточнить', ['unemployment', 'severance'], 'general', [], 'общая трудовая формулировка', 'ambiguous')
  return intent('out_of_scope', 'тема не определена', [], 'none', [], '', 'none')
}

export function extractExplicitFacts(text) {
  const query = String(text || '').toLowerCase()
  const facts = []
  const age = query.match(/(?:мне|возраст)\s*(\d{2})\s*(?:лет|год)?/iu) || query.match(/(?:^|\s)в\s+(\d{2})\s*(?:лет|года|год)/iu)
  if (age) facts.push({ key: 'age', label: 'Возраст', value: age[1] + ' лет' })

  const degree = query.match(/(?:степен[ьи].{0,30}(?:нетрудоспособ|потер[а-яё]*\s+трудоспособ)|нетрудоспособност[ьи])[^0-9]{0,20}(60|65|74|75|100)\s*%/iu) || query.match(/(60|65|74|75|100)\s*%[^\n]{0,35}(?:нетрудоспособ|потер[а-яё]*\s+трудоспособ)/iu)
  if (degree) facts.push({ key: 'disability_degree', label: 'Степень потери трудоспособности', value: degree[1] + '%' })

  if (/пособи[ея]\s+по\s+старост.{0,80}(?:социальн[а-яё]*\s+надбав|доплат[а-яё]*\s+(?:до\s+)?прожиточн)/iu.test(query)) facts.push({ key: 'old_age_topup', label: 'Доплата к пособию по старости', value: 'доплата до прожиточного минимума / социальная надбавка указана в вопросе' })
  if (/пособи[ея]\s+по\s+старост.{0,100}(?:надбавк[а-яё]*\s+по\s+инвалид|доплат[а-яё]*\s+по\s+инвалид)/iu.test(query)) facts.push({ key: 'old_age_disability_topup', label: 'Доплата к пособию по старости', value: 'доплата по инвалидности указана в вопросе' })

  if (/(?:работодатель|начальник).{0,180}(?:решил|отправил|оформил|инициировал).{0,100}(?:халат|неоплачиваем|за\s+свой\s+сч[её]т)|(?:работодатель|начальник).{0,180}(?:сидеть|дома).{0,60}за\s+свой\s+сч[её]т/iu.test(query)) facts.push({ key: 'halat_initiator', label: 'Инициатор ХАЛАТа', value: 'работодатель' })
  else if (/(?:сам|сама|самостоятельно).{0,35}(?:попросил|уш[её]л).{0,25}(?:халат|неоплачиваем)/iu.test(query)) facts.push({ key: 'halat_initiator', label: 'Инициатор ХАЛАТа', value: 'работник' })

  const days = query.match(/(?:халат|неоплачиваем[а-яё]*\s+отпуск)[^\d]{0,30}(\d{1,3})\s*(?:дн|день|дня|дней)/iu) || query.match(/(\d{1,3})\s*(?:дн|день|дня|дней)[^\n]{0,30}(?:халат|неоплачиваем)/iu)
  if (days) facts.push({ key: 'halat_duration', label: 'Продолжительность ХАЛАТа', value: days[1] + ' дней' })
  else if (/весь\s+сентябр/iu.test(query) && /за\s+свой\s+сч[её]т|неоплачиваем|халат/iu.test(query)) facts.push({ key: 'halat_duration', label: 'Продолжительность ХАЛАТа', value: 'весь сентябрь (30 календарных дней)' })

  if (/накоплен[а-яё]*.{0,60}отпускн|использова[а-яё]*.{0,60}отпускн[а-яё]*\s+дн/iu.test(query)) facts.push({ key: 'paid_leave', label: 'Оплачиваемый отпуск', value: 'есть накопленные оплачиваемые дни отпуска' })

  if (/дали\s+инвалид|установил[а-яё]*\s+инвалид|получа[а-яё]*\s+(?:пособие\s+по\s+)?инвалид|у\s+меня\s+инвалид/iu.test(query)) facts.push({ key: 'disability_status', label: 'Инвалидность', value: 'установлена или пособие уже назначено' })

  if (/(?:меня\s+)?(?:увольняют(?![а-яё])|увольняет(?![а-яё])|уволили(?![а-яё])|уволил(?![а-яё]))|работодатель.{0,35}(?:уволил(?![а-яё])|увольняет(?![а-яё])|сократил(?![а-яё])|прекратил(?![а-яё]))/iu.test(query)) facts.push({ key: 'termination_status', label: 'Прекращение работы', value: 'по инициативе работодателя' })
  else if (/(?:хочу|планирую|собираюсь).{0,35}(?:увол|уйти(?:\s+с\s+работы)?)|(?:она|он|я)\s+увольняется|уход(?:и|я|ят|жу|жусь)[а-яё]*.{0,25}по\s+собственн/iu.test(query)) facts.push({ key: 'termination_status', label: 'Прекращение работы', value: 'работник увольняется или планирует увольнение' })
  else if (/(?:уволил(?:ся|ась)|уш[её]л(?:а)?).{0,35}(?:сам|здоров|болезн|пенси)/iu.test(query)) facts.push({ key: 'termination_status', label: 'Прекращение работы', value: 'работник уволился сам' })

  const tenure = query.match(/(?:работа[а-яё]*|стаж)[^\d]{0,20}(\d{1,2})\s*(год|года|лет|месяц|месяца|месяцев)/iu) || query.match(/(\d{1,2})\s*(год|года|лет|месяц|месяца|месяцев).{0,30}работа[а-яё]*/iu)
  if (tenure) facts.push({ key: 'tenure', label: 'Стаж у работодателя', value: tenure[1] + ' ' + tenure[2] })
  else if (/два\s+года.{0,30}работа[а-яё]*|работа[а-яё]*.{0,30}два\s+года/iu.test(query)) facts.push({ key: 'tenure', label: 'Стаж у работодателя', value: '2 года' })
  else if (/восемь\s+лет.{0,30}работа[а-яё]*|работа[а-яё]*.{0,30}восемь\s+лет/iu.test(query)) facts.push({ key: 'tenure', label: 'Стаж у работодателя', value: '8 лет' })

  return facts
}
