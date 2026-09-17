import { detectIntent as baseDetectIntent, extractExplicitFacts as baseExtractExplicitFacts } from './intent-core-v26.js'

function intent(key, label, topics, focus, preferred_slugs, matched_term, confidence = 'explicit') {
  return { key, label, topics, focus, preferred_slugs, confidence, matched_term }
}

export function detectIntent(text) {
  const q = String(text || '').toLowerCase()

  // Specific unemployment payment rule must win over the broader 300-day scenario.
  if (/(?:автал|безработ|пособи[ея]\s+по\s+безработ)/iu.test(q)
      && /(?:(?:5|пять)\s+дн.{0,55}(?:не\s+оплат|без\s+оплат|удерж|кажд|четыр|тр[её]х|4\s*месяц|3\s*месяц)|(?:не\s+оплат|без\s+оплат|удерж).{0,45}(?:5|пять)\s+дн)/iu.test(q)) {
    return intent('unemployment', 'пособие по безработице — автала', ['unemployment'], 'payment_timing', ['payment-timing'], 'пять неоплачиваемых дней')
  }

  // Tax refund after a provident/pension-fund withdrawal is not a severance-entitlement question.
  if (/(?:пенсионн[а-яё]*\s+(?:фонд|касс)|накоплен|кופת|קופת)/iu.test(q)
      && /(?:35\s*%|налог|удерж)/iu.test(q)
      && /(?:вернут|возврат|ретроактив|шест[ьи]\s+лет|6\s+лет|инвалид)/iu.test(q)) {
    return intent('pension_withdrawal_tax', 'налог при снятии пенсионных накоплений', ['tax'], 'provident_withdrawal_tax', ['provident-withdrawal-relative-disability-75','tax-refund-six-years'], 'снятие накоплений + удержанный налог')
  }

  // Tax on severance is a separate problem from entitlement to severance.
  if ((/(?:35\s*%|налог|удержан[а-яё]*\s+налог)/iu.test(q) && /пиц|выходн[а-яё]*\s+пособ/iu.test(q))
      || (/пиц|выходн[а-яё]*\s+пособ/iu.test(q) && /(?:35\s*%|налог)/iu.test(q))) {
    return intent('severance_tax', 'налогообложение пицуим', ['severance'], 'severance_tax', ['severance-tax-exemption-2026','severance-tax-disability-exemption','severance-form-161-tax'], 'пицуим + налог')
  }

  // If health is explicitly the reason for resigning, it is the decisive severance rule even after retirement age.
  if (/(?:пиц|выходн[а-яё]*\s+пособ)/iu.test(q)
      && /(?:увол|уйти|уш[её]л|ушла|прекрат)/iu.test(q)
      && /(?:по\s+состояни[юя]\s+здоров|из-за\s+(?:болезн|здоров)|болезн[ьи]|здоровь)/iu.test(q)) {
    const slugs = ['severance-health-resignation','severance-basic-right']
    if (/пенсион|пенси[яи]|71\s+год|после\s+выхода\s+на\s+пенси/iu.test(q)) slugs.push('severance-retirement-resignation')
    return intent('severance_health', 'пицуим при увольнении по состоянию здоровья', ['severance'], 'health_resignation', slugs, 'увольнение по состоянию здоровья')
  }

  // A mutual termination agreement must be checked separately for severance and unemployment.
  if (/соглашени[а-яё]*\s+сторон|по\s+взаимн[а-яё]*\s+соглас/iu.test(q)
      && /увол|прекращ|пиц|выходн[а-яё]*\s+пособ|безработ|автал/iu.test(q)) {
    return intent('termination_agreement', 'прекращение работы по соглашению сторон', ['severance','unemployment'], 'termination_agreement', ['termination-agreement-severance','termination-agreement-unemployment'], 'соглашение сторон')
  }

  // Real public-housing refusals have different consequences depending on the authority managing the queue.
  if (/(?:социальн[а-яё]*\s+(?:жиль|квартир)|общественн[а-яё]*\s+жиль|דיור\s+ציבורי)/iu.test(q)
      && /(?:отказ|сирув|сирев|сирувим|סרב|סירוב)/iu.test(q)) {
    return intent('housing_refusal', 'отказ от предложения социального жилья', ['housing_support'], 'public_housing_refusal', ['housing-aliyah-refusal-three','housing-ministry-refusal-two'], 'социальное жильё + отказ')
  }

  // Missed/late rent assistance is a recovery process, not a generic eligibility question.
  if (/помощ[ьи]\s+(?:на|по)\s+аренд|аренд[а-яё]*\s+помощ/iu.test(q)
      && /(?:ретроактив|недополуч|предыдущ|раньше|с\s+август|ошибк[а-яё]*\s+(?:министер|ведом)|не\s+поступ)/iu.test(q)) {
    return intent('housing_retroactive', 'ретроактивный перерасчёт помощи на аренду', ['housing_support'], 'rent_retroactive', ['housing-rent-retroactive-differences','housing-assistance-update-details'], 'недополученная помощь на аренду')
  }

  // Single-parent rent assistance + new business requires an income-basis check.
  if (/(?:одинок[а-яё]*\s+(?:родител|мать|отец)|мать[- ]одиноч|חד.?הור)/iu.test(q)
      && /(?:помощ[ьи]\s+(?:на|по)\s+аренд|аренд[а-яё]*\s+помощ)/iu.test(q)
      && /(?:бизнес|осек|самозанят|ацмаи|עצמאי)/iu.test(q)) {
    return intent('housing_single_parent_income', 'помощь на аренду одинокому родителю и доход', ['housing_support'], 'single_parent_income', ['housing-single-parent-income-test'], 'одинокий родитель + аренда + бизнес')
  }

  // Existing disability recipient transitioning to old age is not an ordinary first old-age claim.
  if (/(?:инвалид|нетрудоспособ|нехут|נכות)/iu.test(q)
      && /(?:переход|перейд|вместо\s+инвалид|перед\s+переход)/iu.test(q)
      && /(?:пособи[ея]\s+по\s+старост|пенсионн[а-яё]*\s+возраст|אזרח\s+ותיק)/iu.test(q)) {
    const slugs = ['disability-to-old-age-transition','old-age-disability-recipient-qualifying-exemption']
    if (/1966/iu.test(q)) slugs.push('old-age-retirement-age-woman-1966')
    return intent('disability_old_age_transition', 'переход с инвалидности на пособие по старости', ['old_age'], 'disability_transition', slugs, 'инвалидность → старость')
  }

  // For someone already receiving long-term care, worsening means reassessment of care first; filing age for general disability remains a separate decisive fact.
  if (/(?:помощ[ьи]\s+по\s+уход|метапел|с[иі]юд|סיעוד)/iu.test(q)
      && /(?:увелич|больше\s+час|ухудш|операц|онколог)/iu.test(q)) {
    return intent('long_term_care_worsening', 'ухудшение состояния и увеличение помощи по уходу', ['old_age','disability'], 'care_reassessment', ['long-term-care-worsening-reassessment','disability-application-retirement-boundary','disability-first-application'], 'уход + ухудшение состояния')
  }

  // Calendar entitlement window and bank of payable unemployment days are different concepts.
  if (/(?:автал|безработ|пособи[ея]\s+по\s+безработ)/iu.test(q)
      && /300\s*(?:дн|дней)/iu.test(q)
      && /(?:срок\s+(?:реализац|прав)|прав[оа].{0,40}до\s+\d|до\s+31|законч[а-яё]*\s+(?:дни|300)|прерыва[а-яё]*\s+период|вернул[а-яё]*\s+на\s+(?:ту\s+же\s+)?работ)/iu.test(q)) {
    const slugs = ['unemployment-entitlement-window-vs-days','unemployment-women-57-67-300']
    if (/(?:нов[а-яё]*\s+период|откры[а-яё]*\s+нов|после\s+увольнен)/iu.test(q)) slugs.push('qualifying-period')
    return intent('unemployment_entitlement_window', 'срок реализации авталы и банк дней', ['unemployment'], 'entitlement_window', slugs, '300 дней + календарный срок права')
  }

  // Salary arrears/differences paid in one month can distort old-age income tests if the period is not reported.
  if (/(?:пособи[ея]\s+по\s+старост|социальн[а-яё]*\s+надбав|доплат[а-яё]*\s+до\s+прожиточ)/iu.test(q)
      && /(?:зарплат|доход).{0,100}(?:за\s+(?:два|три|несколько)\s+месяц|апрел|май|июн|сразу)|(?:апрел|май).{0,100}(?:июн|зарплат)/iu.test(q)
      && /переплат|вернут|возврат|перерасч|одним\s+платеж|сразу/iu.test(q)) {
    return intent('old_age', 'пособие по старости — учёт разницы зарплаты', ['old_age'], 'wage_differences', ['old-age-wage-differences-allocation','old-age-income-supplement-2026'], 'разница зарплаты за несколько месяцев')
  }

  // Do not apply the post-retirement resignation rule before retirement age is actually reached.
  if (/(?:за\s+(?:год|полгода).{0,40}до\s+пенсионн|через\s+(?:год|полгода).{0,45}(?:пенси|пенсионн)|до\s+пенсионн[а-яё]*\s+возраст)/iu.test(q)
      && /увол|уйти|вынужд|пиц|выходн[а-яё]*\s+пособ/iu.test(q)) {
    return intent('severance_pre_retirement', 'пицуим до достижения пенсионного возраста', ['severance'], 'pre_retirement', ['severance-before-retirement-age','severance-basic-right'], 'уход до пенсионного возраста')
  }

  // Old-age benefit and unemployment can coexist; only add resignation procedure when the question actually asks about it.
  if (/(?:пособи[ея]\s+по\s+старост|кицват\s+зикн|אזרח\s+ותיק)/iu.test(q)
      && /безработ|автал|דמי\s+אבטלה/iu.test(q)) {
    const slugs = ['unemployment-old-age-concurrent-woman']
    if (/(?:увол|по\s+собственн|90\s*дн|тр[её]хмесяч|когда.{0,30}подав|когда.{0,30}регистр)/iu.test(q)) slugs.push('unemployment-voluntary-register-immediately')
    return intent('old_age_unemployment', 'пособие по старости и автала', ['unemployment'], 'old_age_concurrent', slugs, 'старость + безработица')
  }

  // Private/pension-fund loss-of-capacity payment intersects both disability and unemployment.
  if (/(?:потер[яи]\s+трудоспособ|утрат[а-яё]*\s+трудоспособ|אובדן\s+כושר)/iu.test(q)
      && /(?:пенсионн[а-яё]*\s+фонд|страхов[а-яё]*\s+компан|пенси[яи])/iu.test(q)
      && /(?:инвалид|битуах|безработ|автал|пособ)/iu.test(q)) {
    return intent('private_disability_pension', 'выплата по потере трудоспособности и государственные пособия', ['disability','unemployment'], 'private_disability_pension', ['unemployment-private-disability-pension','disability-nonwork-income-dependents'], 'потеря трудоспособности из фонда + пособия')
  }

  // Benefit termination after a reduction in disability degree: payment date + ancillary benefits.
  if (/(?:снижа[а-яё]*|сниз[а-яё]*|уменьша[а-яё]*).{0,70}(?:инвалид|степен|процент)|(?:пособи[ея].{0,50}прекращ|прекраща[а-яё]*.{0,50}пособи[ея])/iu.test(q)
      && /(?:28|арнон|проезд|транспорт|прожиточ|инвалид)/iu.test(q)) {
    return intent('disability_change', 'изменение степени инвалидности и прекращение пособия', ['disability'], 'benefit_reduction_end', ['disability-payment-current-month','disability-arnona-thresholds','disability-transport-card-validity','disability-stop-work'], 'снижение степени + прекращение пособия')
  }

  // During the 2026 Shaagat HaAri arrangement, self-employed income uses a special declaration.
  if (/(?:халат|неоплачиваем[а-яё]*\s+отпуск|безработ|автал)/iu.test(q)
      && /(?:бизнес|самозанят|ацмаи|עצמאי|доход[а-яё]*\s+от\s+бизнес)/iu.test(q)
      && /(?:войн|шаагат|львин|доход.{0,40}не\s+был|уменьшил[а-яё]*\s+выплат)/iu.test(q)) {
    return intent('unemployment_wartime', 'автала и доход от самостоятельной деятельности в чрезвычайный период', ['unemployment'], 'self_employed_wartime', ['unemployment-self-employed-shaagat-hari-2026','unemployment-self-employed-income-annual'], 'ХАЛАТ + самостоятельный доход + чрезвычайный период')
  }

  return baseDetectIntent(text)
}

export function extractExplicitFacts(text) {
  const q = String(text || '').toLowerCase()
  const facts = baseExtractExplicitFacts(text).filter(x => x.key !== 'tenure')

  function upsert(key, label, value) {
    const i = facts.findIndex(x => x.key === key)
    if (i >= 0) facts[i] = { key, label, value }
    else facts.push({ key, label, value })
  }

  // Recompute tenure conservatively so ages such as "23 лет" or "до 67 лет" are not mistaken for years worked.
  let tenure = q.match(/(?:проработал[аи]?|работал[аи]?|работаю|работает|работал)[а-яё]*[^\d\n.]{0,45}(\d{1,2})\s*(год|года|лет|месяц|месяца|месяцев)/iu)
    || q.match(/(\d{1,2})\s*(год|года|лет|месяц|месяца|месяцев)\s+(?:про)?работал[аи]?[а-яё]*/iu)
    || q.match(/стаж[^\d]{0,20}(\d{1,2})\s*(год|года|лет|месяц|месяца|месяцев)/iu)
    || q.match(/послед[а-яё]*\s+(\d{1,2})\s*(год|года|лет|месяц|месяца|месяцев)[^\n.]{0,45}(?:нов[а-яё]*\s+работодател|у\s+нов[а-яё]*\s+работодател)/iu)
  if (tenure) upsert('tenure', 'Стаж у работодателя', tenure[1] + ' ' + tenure[2])
  else if (/два\s+года.{0,30}работа[а-яё]*|работа[а-яё]*.{0,30}два\s+года/iu.test(q)) upsert('tenure', 'Стаж у работодателя', '2 года')
  else if (/восемь\s+лет.{0,30}работа[а-яё]*|работа[а-яё]*.{0,30}восемь\s+лет/iu.test(q)) upsert('tenure', 'Стаж у работодателя', '8 лет')

  if (/начал[аи]?\s+работа[а-яё]*.{0,70}после.{0,40}(?:пенсионн[а-яё]*\s+возраст|выхода\s+на\s+пенси)|после.{0,40}(?:пенсионн[а-яё]*\s+возраст|выхода\s+на\s+пенси).{0,70}начал[аи]?\s+работа/iu.test(q)) {
    upsert('start_after_pension', 'Начало работы относительно пенсионного возраста', 'работа у этого работодателя началась после достижения пенсионного возраста')
  }

  if (/(?:министерств[а-яё]*\s+(?:алии|абсорбц)|משרד\s+העלייה|קליטה)/iu.test(q)) {
    upsert('housing_queue_authority', 'Ведомство очереди на жильё', 'Министерство алии и интеграции')
  } else if (/(?:министерств[а-яё]*\s+(?:строительств|жилищ)|משרד\s+הבינוי)/iu.test(q)) {
    upsert('housing_queue_authority', 'Ведомство очереди на жильё', 'Министерство строительства и жилищного хозяйства')
  }

  const birthYear = q.match(/(?:родил[а-яё]*|рождени[яе]|года\s+рождения)[^\d]{0,15}(19\d{2}|20\d{2})|(19\d{2}|20\d{2})\s+года\s+рожд/iu)
  if (birthYear) upsert('birth_year', 'Год рождения', String(birthYear[1] || birthYear[2]))

  if (/какой\s+возраст\s+считается.{0,80}(?:300\s*(?:дн|дней)|пособи[ея]\s+по\s+безработ)/iu.test(q)) {
    upsert('question_scope', 'Тип вопроса', 'общий вопрос о правиле, а не о личной дате рождения')
  }

  if (/(?:(?:первые\s+)?(?:5|пять)\s+дн[^\n]{0,50}(?:не\s+оплат|без\s+оплат)|(?:не\s+оплат|без\s+оплат)[^\n]{0,50}(?:5|пять)\s+дн)/iu.test(q)) {
    upsert('five_day_rule_scope', 'Тип вопроса', 'вопрос именно об общем правиле первых пяти неоплачиваемых дней')
  }

  if (/нет\s+отпускн|нет\s+дн[а-яё]*\s+отпуск|0\s+дн[а-яё]*\s+отпуск/iu.test(q)) {
    upsert('vacation_balance', 'Остаток ежегодного отпуска', '0 дней; в вопросе прямо сказано, что отпускных нет')
  }

  const incapacity = q.match(/(\d{2,3})\s*%[^\n]{0,35}(?:утрат[а-яё]*|потер[яи]|нетрудоспособ)/iu)
    || q.match(/(?:утрат[а-яё]*|потер[яи]|нетрудоспособ)[^\d\n]{0,35}(\d{2,3})\s*%/iu)
  if (incapacity) upsert('disability_degree', 'Степень потери трудоспособности', incapacity[1] + '%')

  const medical = q.match(/(\d{2,3})\s*%[^\n]{0,25}медицинск[а-яё]*\s+инвалид/iu)
    || q.match(/медицинск[а-яё]*\s+инвалид[^\d\n]{0,25}(\d{2,3})\s*%/iu)
  if (medical) upsert('medical_disability_degree', 'Медицинская инвалидность', medical[1] + '%')

  if (/постоянн[а-яё]*[^\n]{0,45}(?:медицинск[а-яё]*\s+инвалид|инвалид)|(?:инвалид|нетрудоспособ)[^\n]{0,45}постоянн/iu.test(q)) {
    upsert('disability_permanent', 'Срок инвалидности', 'в вопросе инвалидность указана как постоянная')
  }

  const reduced = q.match(/(?:снижа[а-яё]*|сниз[а-яё]*|уменьша[а-яё]*)[^\d\n]{0,35}(\d{2,3})\s*%/iu)
  if (reduced) upsert('new_disability_degree', 'Новая степень инвалидности/нетрудоспособности', reduced[1] + '%')

  if (/(?:снижа[а-яё]*|сниз[а-яё]*|уменьша[а-яё]*).{0,90}(?:инвалид|степен|процент).{0,120}(?:пособи[ея]\s+прекращ|пособи[ея]\s+отмен|прекраща[а-яё]*\s+пособ)|(?:пособи[ея]\s+прекращ|пособи[ея]\s+отмен).{0,120}(?:снижа[а-яё]*|сниз[а-яё]*|уменьша[а-яё]*)/iu.test(q)) {
    upsert('termination_reason', 'Причина прекращения пособия', 'в вопросе указано, что пособие прекращается из-за снижения степени инвалидности')
  }

  if (/с\s*(?:1|01)(?:[.\/-]0?9)?\s*(?:сентябр[яья]?|09)?/iu.test(q) && /пособи[ея]\s+прекращ|прекраща[а-яё]*\s+пособ/iu.test(q)) {
    upsert('benefit_end_date', 'Дата прекращения пособия', 'с 1 сентября; право заявлено действующим по 31 августа')
  }

  if (/социальн[а-яё]*\s+надбав|доплат[а-яё]*\s+до\s+прожиточ/iu.test(q)) {
    upsert('old_age_topup', 'Доплата к пособию по старости', 'социальная надбавка / доплата до прожиточного минимума указана в вопросе')
  }

  if (/получа[а-яё]*.{0,35}(?:помощ[ьи]\s+по\s+уход|метапел|с[иі]юд)|(?:помощ[ьи]\s+по\s+уход|метапел|с[иі]юд).{0,35}получа/iu.test(q)) {
    upsert('long_term_care_status', 'Пособие/помощь по уходу', 'уже получает помощь по уходу')
  }

  if (/300\s*(?:дн|дней).{0,80}(?:законч|использ|выплачен)|(?:все|300).{0,50}(?:дни|дней).{0,40}(?:законч|выплачен|использ)/iu.test(q)) {
    upsert('entitlement_days_status', 'Статус дней авталы', 'в вопросе указано, что назначенный лимит 300 дней уже исчерпан')
  }

  const deadline = q.match(/до\s+(\d{1,2})\s+(январ[яья]|феврал[яья]|март[а-яё]*|апрел[яья]|ма[яй]|июн[яья]|июл[яья]|август[а-яё]*|сентябр[яья]|октябр[яья]|ноябр[яья]|декабр[яья])\s+(20\d{2})/iu)
  if (deadline) upsert('entitlement_deadline', 'Календарный срок реализации права', `до ${deadline[1]} ${deadline[2]} ${deadline[3]} года`)

  return facts
}
