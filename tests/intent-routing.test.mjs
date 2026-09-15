import assert from 'node:assert/strict'
import { detectIntent, extractExplicitFacts } from '../supabase/functions/semantic-search/intent.js'

const cases = [
  ['дали инвалидность. могу просить пицуим на работе?', 'severance'],
  ['Я инвалид и продолжаю работать. Сохранится ли пособие?', 'disability'],
  ['какая разница между медицинской и рабочей инвалидностью?', 'disability'],
  ['У меня инвалидность, и я хочу уйти с работы. Что мне положено?', 'severance'],
  ['Меня увольняют, у меня инвалидность. Что мне положено?', 'multi_rights'],
  ['Работодатель отправил меня в ХАЛАТ на 45 дней', 'unpaid_leave'],
  ['Мне 46 лет. Сколько дней будут платить авталу?', 'unemployment'],
  ['Меня уволили, что мне положено?', 'employment_ambiguous'],
  ['Как продлить загранпаспорт?', 'out_of_scope']
]

for (const [question, expected] of cases) {
  assert.equal(detectIntent(question).key, expected, question)
}

const disabilityTerminology = detectIntent('какая разница между медицинской и рабочей инвалидностью?')
assert.equal(disabilityTerminology.key, 'disability')
assert.deepEqual(disabilityTerminology.topics, ['disability'])
assert.notEqual(disabilityTerminology.key, 'out_of_scope')

const disabilityJobExit = detectIntent('У меня инвалидность, и я хочу уйти с работы. Что мне положено?')
assert.equal(disabilityJobExit.key, 'severance')
assert.equal(disabilityJobExit.focus, 'health_resignation')
assert.deepEqual(disabilityJobExit.preferred_slugs, ['severance-health-resignation', 'severance-medical-proof'])

const disabilityFiring = detectIntent('Меня увольняют, у меня инвалидность. Что мне положено?')
assert.equal(disabilityFiring.key, 'multi_rights')
assert.deepEqual(disabilityFiring.topics, ['severance', 'unemployment', 'disability'])
assert.equal(disabilityFiring.focus, 'termination_with_disability')

assert.deepEqual(detectIntent('Мне 46 лет. Сколько дней дадут авталу?').preferred_slugs, ['entitlement-days'])
assert.deepEqual(detectIntent('Когда после увольнения зарегистрироваться для авталы?').preferred_slugs, ['register-employment-service', 'missed-appointment'])
assert.deepEqual(detectIntent('Хочу уволиться по собственному желанию. Как получить авталу?').preferred_slugs, ['voluntary-resignation', 'register-employment-service'])
assert.deepEqual(detectIntent('Дали инвалидность. Могу просить пицуим?').preferred_slugs, ['severance-health-resignation', 'severance-medical-proof'])

console.log(`intent routing: ${cases.length} checks passed`)

assert.deepEqual(extractExplicitFacts('Работодатель отправил меня в ХАЛАТ на 45 дней'), [
  { key: 'halat_initiator', label: 'Инициатор ХАЛАТа', value: 'работодатель' },
  { key: 'halat_duration', label: 'Продолжительность ХАЛАТа', value: '45 дней' }
])
assert.equal(extractExplicitFacts('Мне 46 лет. Сколько дней дадут авталу?')[0].value, '46 лет')
assert.equal(extractExplicitFacts('Дали инвалидность. Могу просить пицуим?')[0].key, 'disability_status')
assert.equal(extractExplicitFacts('Я планирую уволиться по состоянию здоровья')[0].key, 'termination_status')
assert.equal(extractExplicitFacts('У меня инвалидность, и я хочу уйти с работы. Что мне положено?').find(x => x.key === 'termination_status')?.value, 'работник планирует увольнение')
assert.equal(extractExplicitFacts('Меня увольняют, у меня инвалидность. Что мне положено?').find(x => x.key === 'termination_status')?.value, 'по инициативе работодателя')
assert.equal(extractExplicitFacts('Работаю здесь 2 года')[0].key, 'tenure')
console.log('explicit facts: 7 checks passed')
