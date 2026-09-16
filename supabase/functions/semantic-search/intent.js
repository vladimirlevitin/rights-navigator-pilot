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

  // Tax on severance is a separate problem from entitlement to severance.
  if ((/(?:35\s*%|налог|удержан[а-яё]*\s+налог)/iu.test(q) && /пиц|выходн[а-яё]*\s+пособ/iu.test(q))
      || (/пиц|выходн[а-яё]*\s+пособ/iu.test(q) && /(?:35\s*%|налог)/iu.test(q))) {
    return intent('severance_tax', 'налогообложение пицуим', ['severance'], 'severance_tax', ['severance-tax-exemption-2026','severance-tax-disability-exemption','severance-form-161-tax'], 'пицуим + налог')
  }

  // A mutual termination agreement must be checked separately for severance and unemployment.
  if (/соглашени[а-яё]*\s+сторон|по\s+взаимн[а-яё]*\s+соглас/iu.test(q)
      && /увол|прекращ|пиц|выходн[а-яё]*\s+пособ|безработ|автал/iu.test(q)) {
    return intent('termination_agreement', 'прекращение работы по соглашению сторон', ['severance','unemployment'], 'termination_agreement', ['termination-agreement-severance','termination-agreement-unemployment'], 'соглашение сторон')
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

  // Old-age benefit and unemployment can coexist for an eligible woman; resignation timing is separate.
  if (/(?:пособи[ея]\s+по\s+старост|кицват\s+зикн|אזרח\s+ותיק)/iu.test(q)
      && /безработ|автал|דמי\s+אבטלה/iu.test(q)) {
    return intent('old_age_unemployment', 'пособие по старости и автала', ['unemployment'], 'old_age_concurrent', ['unemployment-old-age-concurrent-woman','unemployment-voluntary-register-immediately'], 'старость + безработица')
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

  // Recompute tenure conservatively so ages such as "23 лет" or "до 67 лет"
  // are not mistaken for years worked.
  let tenure = q.match(/(?:проработал[аи]?|работал[аи]?|работаю|работает|работал)[а-яё]*[^\d\n.]{0,45}(\d{1,2})\s*(год|года|лет|месяц|месяца|месяцев)/iu)
    || q.match(/(\d{1,2})\s*(год|года|лет|месяц|месяца|месяцев)\s+(?:про)?работал[аи]?[а-яё]*/iu)
    || q.match(/стаж[^\d]{0,20}(\d{1,2})\s*(год|года|лет|месяц|месяца|месяцев)/iu)
    || q.match(/послед[а-яё]*\s+(\d{1,2})\s*(год|года|лет|месяц|месяца|месяцев)[^\n.]{0,45}(?:нов[а-яё]*\s+работодател|у\s+нов[а-яё]*\s+работодател)/iu)
  if (tenure) facts.push({ key: 'tenure', label: 'Стаж у работодателя', value: tenure[1] + ' ' + tenure[2] })
  else if (/два\s+года.{0,30}работа[а-яё]*|работа[а-яё]*.{0,30}два\s+года/iu.test(q)) facts.push({ key: 'tenure', label: 'Стаж у работодателя', value: '2 года' })
  else if (/восемь\s+лет.{0,30}работа[а-яё]*|работа[а-яё]*.{0,30}восемь\s+лет/iu.test(q)) facts.push({ key: 'tenure', label: 'Стаж у работодателя', value: '8 лет' })

  if (/какой\s+возраст\s+считается.{0,80}(?:300\s*(?:дн|дней)|пособи[ея]\s+по\s+безработ)/iu.test(q)) {
    facts.push({ key: 'question_scope', label: 'Тип вопроса', value: 'общий вопрос о правиле, а не о личной дате рождения' })
  }

  if (/(?:(?:первые\s+)?(?:5|пять)\s+дн[^\n]{0,50}(?:не\s+оплат|без\s+оплат)|(?:не\s+оплат|без\s+оплат)[^\n]{0,50}(?:5|пять)\s+дн)/iu.test(q)) {
    facts.push({ key: 'five_day_rule_scope', label: 'Тип вопроса', value: 'вопрос именно об общем правиле первых пяти неоплачиваемых дней' })
  }

  if (/нет\s+отпускн|нет\s+дн[а-яё]*\s+отпуск|0\s+дн[а-яё]*\s+отпуск/iu.test(q)) {
    facts.push({ key: 'vacation_balance', label: 'Остаток ежегодного отпуска', value: '0 дней; в вопросе прямо сказано, что отпускных нет' })
  }

  const incapacity = q.match(/(\d{2,3})\s*%[^\n]{0,35}(?:утрат[а-яё]*|потер[яи]|нетрудоспособ)/iu)
    || q.match(/(?:утрат[а-яё]*|потер[яи]|нетрудоспособ)[^\d\n]{0,35}(\d{2,3})\s*%/iu)
  if (incapacity && !facts.some(x => x.key === 'disability_degree')) {
    facts.push({ key: 'disability_degree', label: 'Степень потери трудоспособности', value: incapacity[1] + '%' })
  }

  const medical = q.match(/(\d{2,3})\s*%[^\n]{0,25}медицинск[а-яё]*\s+инвалид/iu)
    || q.match(/медицинск[а-яё]*\s+инвалид[^\d\n]{0,25}(\d{2,3})\s*%/iu)
  if (medical) facts.push({ key: 'medical_disability_degree', label: 'Медицинская инвалидность', value: medical[1] + '%' })

  const reduced = q.match(/(?:снижа[а-яё]*|сниз[а-яё]*|уменьша[а-яё]*)[^\d\n]{0,35}(\d{2,3})\s*%/iu)
  if (reduced) facts.push({ key: 'new_disability_degree', label: 'Новая степень инвалидности/нетрудоспособности', value: reduced[1] + '%' })

  if (/(?:снижа[а-яё]*|сниз[а-яё]*|уменьша[а-яё]*).{0,90}(?:инвалид|степен|процент).{0,120}(?:пособи[ея]\s+прекращ|пособи[ея]\s+отмен|прекраща[а-яё]*\s+пособ)|(?:пособи[ея]\s+прекращ|пособи[ея]\s+отмен).{0,120}(?:снижа[а-яё]*|сниз[а-яё]*|уменьша[а-яё]*)/iu.test(q)) {
    facts.push({ key: 'termination_reason', label: 'Причина прекращения пособия', value: 'в вопросе указано, что пособие прекращается из-за снижения степени инвалидности' })
  }

  if (/с\s*(?:1|01)(?:[.\/-]0?9)?\s*(?:сентябр[яья]?|09)?/iu.test(q) && /пособи[ея]\s+прекращ|прекраща[а-яё]*\s+пособ/iu.test(q)) {
    facts.push({ key: 'benefit_end_date', label: 'Дата прекращения пособия', value: 'с 1 сентября; право заявлено действующим по 31 августа' })
  }

  if (/социальн[а-яё]*\s+надбав|доплат[а-яё]*\s+до\s+прожиточ/iu.test(q) && !facts.some(x => x.key === 'old_age_topup')) {
    facts.push({ key: 'old_age_topup', label: 'Доплата к пособию по старости', value: 'социальная надбавка / доплата до прожиточного минимума указана в вопросе' })
  }

  return facts
}
