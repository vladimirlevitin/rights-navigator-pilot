import assert from 'node:assert/strict'
import { detectIntent, extractExplicitFacts } from '../supabase/functions/semantic-search/intent.js'

const cases = [
  ['дали инвалидность. могу просить пицуим на работе?', 'severance'],
  ['Я инвалид и продолжаю работать. Сохранится ли пособие?', 'disability'],
  ['Работодатель отправил меня в ХАЛАТ на 45 дней', 'unpaid_leave'],
  ['Мне 46 лет. Сколько дней будут платить авталу?', 'unemployment'],
  ['Меня уволили, что мне положено?', 'employment_ambiguous'],
  ['Как продлить загранпаспорт?', 'out_of_scope']
]

for (const [question, expected] of cases) {
  assert.equal(detectIntent(question).key, expected, question)
}

assert.deepEqual(detectIntent('Мне 46 лет. Сколько дней дадут авталу?').preferred_slugs, ['entitlement-days'])
assert.deepEqual(detectIntent('Когда после увольнения зарегистрироваться для авталы?').preferred_slugs, ['register-employment-service', 'missed-appointment'])
assert.deepEqual(detectIntent('Дали инвалидность. Могу просить пицуим?').preferred_slugs, ['severance-health-resignation', 'severance-medical-proof'])

console.log(`intent routing: ${cases.length} checks passed`)

assert.deepEqual(extractExplicitFacts('Работодатель отправил меня в ХАЛАТ на 45 дней'), [
  { key: 'halat_initiator', label: 'Инициатор ХАЛАТа', value: 'работодатель' },
  { key: 'halat_duration', label: 'Продолжительность ХАЛАТа', value: '45 дней' }
])
assert.equal(extractExplicitFacts('Мне 46 лет. Сколько дней дадут авталу?')[0].value, '46 лет')
assert.equal(extractExplicitFacts('Дали инвалидность. Могу просить пицуим?')[0].key, 'disability_status')
assert.equal(extractExplicitFacts('Я планирую уволиться по состоянию здоровья')[0].key, 'termination_status')
assert.equal(extractExplicitFacts('Работаю здесь 2 года')[0].key, 'tenure')
console.log('explicit facts: 5 checks passed')
