const RULES = [
  {
    key: 'severance',
    label: 'выходное пособие — пицуим',
    topics: ['severance'],
    pattern: /пиц(?:у|о|ы|и)?им|питцуим|пицуим|פיצוי|выходн\w*\s+пособ|компенсац\w*.{0,35}увол/i
  },
  {
    key: 'unpaid_leave',
    label: 'неоплачиваемый отпуск — ХАЛАТ',
    topics: ['unpaid_leave'],
    pattern: /халат|חל[״"']?ת|неоплачиваем\w*\s+отпуск|отпуск\w*\s+за\s+свой\s+сч[её]т/i
  },
  {
    key: 'disability',
    label: 'пособие и работа при инвалидности',
    topics: ['disability'],
    pattern: /инвалид|нехут|нехут клали|נכות|нетрудоспособ|потер[яи]\s+трудоспособ/i
  },
  {
    key: 'unemployment',
    label: 'пособие по безработице — автала',
    topics: ['unemployment'],
    pattern: /автал|аватал|דמי\s+אבטלה|безработ|служб\w*\s+занятост|бирж\w*\s+труд|шерут\s+таасука|שירות\s+התעסוקה/i
  }
]

export function detectIntent(text) {
  const query = String(text || '').toLowerCase()
  for (const rule of RULES) {
    const match = query.match(rule.pattern)
    if (match) {
      let focus = 'general'
      let preferred_slugs = []
      if (rule.key === 'unemployment') {
        if (/(?:сколько|максимум|на какой).{0,20}(?:дн|срок)|иждивен/i.test(query)) { focus = 'entitlement_duration'; preferred_slugs = ['entitlement-days'] }
        else if (/12.{0,12}18|стаж|страхов\w*\s+период|ткуфат\s+ахшар/i.test(query)) { focus = 'qualifying_period'; preferred_slugs = ['qualifying-period', 'eligibility-basics'] }
        else if (/когда.{0,20}(?:плат|деньг)|17.{0,8}чис|первые.{0,8}(?:5|пять)/i.test(query)) { focus = 'payment_timing'; preferred_slugs = ['payment-timing'] }
        else if (/увол\w*.{0,25}собствен|сам\w*.{0,25}увол|хочу.{0,25}увол/i.test(query)) { focus = 'voluntary_resignation'; preferred_slugs = ['voluntary-resignation', 'register-employment-service'] }
        else if (/регистр|отмеч|явк|шерут\s+таасука|служб\w*\s+занятост/i.test(query)) { focus = 'registration'; preferred_slugs = ['register-employment-service', 'missed-appointment'] }
        else if (/за\s+границ|вылет|поездк|хуль/i.test(query)) { focus = 'travel'; preferred_slugs = ['travel-abroad'] }
        else if (/ацмаи|самозанят|предпринимател/i.test(query)) { focus = 'self_employed'; preferred_slugs = ['self-employed', 'eligibility-basics'] }
      } else if (rule.key === 'severance' && /инвалид|здоров|болезн|медицин/i.test(query)) {
        focus = 'health_resignation'; preferred_slugs = ['severance-health-resignation', 'severance-medical-proof']
      } else if (rule.key === 'disability' && /работ|зарплат|доход|зарабат/i.test(query)) {
        focus = 'work_and_benefit'; preferred_slugs = ['disability-work-allowed', 'disability-income-change', 'disability-stop-work']
      } else if (rule.key === 'unpaid_leave') {
        focus = 'initiator_and_duration'; preferred_slugs = ['unpaid-leave', 'unpaid-leave-voluntary']
      }
      return { key: rule.key, label: rule.label, topics: rule.topics, focus, preferred_slugs, confidence: 'explicit', matched_term: match[0] }
    }
  }

  if (/увол|сократ|прекрат\w*\s+работ|работодатель|трудов\w*\s+договор/i.test(query)) {
    return {
      key: 'employment_ambiguous',
      label: 'прекращение работы — вид права нужно уточнить',
      topics: ['unemployment', 'severance'],
      focus: 'general',
      preferred_slugs: [],
      confidence: 'ambiguous',
      matched_term: 'общая трудовая формулировка'
    }
  }

  return { key: 'out_of_scope', label: 'тема не определена', topics: [], focus: 'none', preferred_slugs: [], confidence: 'none', matched_term: '' }
}

export function extractExplicitFacts(text) {
  const query = String(text || '').toLowerCase()
  const facts = []
  const age = query.match(/(?:мне|возраст)\s*(\d{2})\s*(?:лет|год)?/i)
  if (age) facts.push({ key: 'age', label: 'Возраст', value: age[1] + ' лет' })

  if (/работодатель.{0,45}(?:отправил|оформил|инициировал).{0,25}(?:халат|неоплачиваем)/i.test(query)) {
    facts.push({ key: 'halat_initiator', label: 'Инициатор ХАЛАТа', value: 'работодатель' })
  } else if (/(?:сам|сама|самостоятельно).{0,35}(?:попросил|уш[её]л).{0,25}(?:халат|неоплачиваем)/i.test(query)) {
    facts.push({ key: 'halat_initiator', label: 'Инициатор ХАЛАТа', value: 'работник' })
  }

  const days = query.match(/(?:халат|неоплачиваем\w*\s+отпуск)[^\d]{0,30}(\d{1,3})\s*(?:дн|день|дня|дней)/i)
    || query.match(/(\d{1,3})\s*(?:дн|день|дня|дней)[^\n]{0,30}(?:халат|неоплачиваем)/i)
  if (days) facts.push({ key: 'halat_duration', label: 'Продолжительность ХАЛАТа', value: days[1] + ' дней' })

  if (/дали\s+инвалид|установил\w*\s+инвалид|получа\w*\s+(?:пособие\s+по\s+)?инвалид/i.test(query)) {
    facts.push({ key: 'disability_status', label: 'Инвалидность', value: 'установлена или пособие уже назначено' })
  }
  if (/работодатель.{0,35}(?:уволил|сократил|прекратил)/i.test(query)) {
    facts.push({ key: 'termination_status', label: 'Прекращение работы', value: 'по инициативе работодателя' })
  } else if (/(?:хочу|планирую|собираюсь).{0,25}увол/i.test(query)) {
    facts.push({ key: 'termination_status', label: 'Прекращение работы', value: 'работник планирует увольнение' })
  } else if (/(?:уволил(?:ся|ась)|уш[её]л(?:а)?).{0,35}(?:сам|здоров|болезн)/i.test(query)) {
    facts.push({ key: 'termination_status', label: 'Прекращение работы', value: 'работник уволился сам' })
  }
  const tenure = query.match(/(?:работа\w*|стаж)[^\d]{0,20}(\d{1,2})\s*(год|года|лет|месяц|месяца|месяцев)/i)
  if (tenure) facts.push({ key: 'tenure', label: 'Стаж у работодателя', value: tenure[1] + ' ' + tenure[2] })
  return facts
}
