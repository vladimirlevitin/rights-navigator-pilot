export const RIGHTS_SYNONYMS = [
  {
    key: 'unemployment',
    canonical_ru: 'пособие по безработице',
    canonical_he: 'דמי אבטלה',
    aliases: ['автала', 'автола', 'аватала', 'аватла', 'автале', 'автолу', 'дмей автала', 'безработица', 'пособие по безработице']
  },
  {
    key: 'severance',
    canonical_ru: 'выходное пособие при увольнении',
    canonical_he: 'פיצויי פיטורים',
    aliases: ['пицуим', 'питцуим', 'пицуи', 'пицуй', 'пицуим питурим', 'пицуей питурим', 'компенсация при увольнении', 'выходное пособие']
  },
  {
    key: 'unpaid_leave',
    canonical_ru: 'неоплачиваемый отпуск',
    canonical_he: 'חלת',
    aliases: ['халат', 'халат без оплаты', 'неоплачиваемый отпуск', 'отпуск за свой счет', 'отпуск за свой счёт']
  },
  {
    key: 'disability',
    canonical_ru: 'общая инвалидность',
    canonical_he: 'נכות כללית',
    aliases: ['нехут', 'нехут клали', 'нахут', 'инвалидность', 'общая инвалидность', 'пособие по инвалидности']
  },
  {
    key: 'incapacity',
    canonical_ru: 'степень потери трудоспособности',
    canonical_he: 'דרגת אי כושר',
    aliases: ['и кошер', 'и-кошер', 'אי כושר', 'рабочая инвалидность', 'потеря трудоспособности', 'степень нетрудоспособности']
  },
  {
    key: 'medical_disability',
    canonical_ru: 'медицинская инвалидность',
    canonical_he: 'נכות רפואית',
    aliases: ['нехут рефуит', 'медицинская инвалидность', 'медицинский процент инвалидности', 'процент медицинской инвалидности']
  },
  {
    key: 'employment_service',
    canonical_ru: 'Служба занятости',
    canonical_he: 'שירות התעסוקה',
    aliases: ['шерут таасука', 'лишкат таасука', 'биржа труда', 'служба занятости']
  },
  {
    key: 'national_insurance',
    canonical_ru: 'Битуах Леуми',
    canonical_he: 'ביטוח לאומי',
    aliases: ['битуах леуми', 'битуах леоми', 'битуах', 'национальное страхование']
  }
]

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}

export function expandRightsTerms(text) {
  const source = String(text || '')
  const lower = source.toLowerCase()
  const additions = []

  for (const entry of RIGHTS_SYNONYMS) {
    if (entry.aliases.some(alias => new RegExp(`(^|[^\\p{L}\\p{N}])${escapeRegExp(alias.toLowerCase())}([^\\p{L}\\p{N}]|$)`, 'iu').test(lower))) {
      additions.push(entry.canonical_ru, entry.canonical_he, ...entry.aliases)
    }
  }

  return additions.length ? `${source}\nТермины поиска: ${[...new Set(additions)].join(' | ')}` : source
}
