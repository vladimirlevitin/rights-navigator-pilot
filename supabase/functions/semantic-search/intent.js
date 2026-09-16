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

  return baseDetectIntent(text)
}

export function extractExplicitFacts(text) {
  const q = String(text || '').toLowerCase()
  const facts = baseExtractExplicitFacts(text).filter(x => x.key !== 'tenure')

  // Recompute tenure conservatively so ages such as "23 лет" or "до 67 лет"
  // are not mistaken for years worked.
  let tenure = q.match(/(?:про)?работал[аи]?[а-яё]*[^\d]{0,20}(\d{1,2})\s*(год|года|лет|месяц|месяца|месяцев)/iu)
    || q.match(/(\d{1,2})\s*(год|года|лет|месяц|месяца|месяцев)\s+(?:про)?работал[аи]?[а-яё]*/iu)
    || q.match(/стаж[^\d]{0,20}(\d{1,2})\s*(год|года|лет|месяц|месяца|месяцев)/iu)
  if (tenure) facts.push({ key: 'tenure', label: 'Стаж у работодателя', value: tenure[1] + ' ' + tenure[2] })
  else if (/два\s+года.{0,30}работа[а-яё]*|работа[а-яё]*.{0,30}два\s+года/iu.test(q)) facts.push({ key: 'tenure', label: 'Стаж у работодателя', value: '2 года' })
  else if (/восемь\s+лет.{0,30}работа[а-яё]*|работа[а-яё]*.{0,30}восемь\s+лет/iu.test(q)) facts.push({ key: 'tenure', label: 'Стаж у работодателя', value: '8 лет' })

  if (/какой\s+возраст\s+считается.{0,80}(?:300\s*(?:дн|дней)|пособи[ея]\s+по\s+безработ)/iu.test(q)) {
    facts.push({ key: 'question_scope', label: 'Тип вопроса', value: 'общий вопрос о правиле, а не о личной дате рождения' })
  }

  return facts
}
