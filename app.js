const SUPABASE_URL = 'https://fgadxhyeegncmyjepypg.supabase.co';
const SUPABASE_KEY = 'sb_publishable_Q1pZaATQwb6XomNXpXA8NQ_2pAtgAi7';

const form = document.querySelector('#search-form');
const questionInput = document.querySelector('#question');
const submitButton = document.querySelector('#submit-button');
const result = document.querySelector('#result');
const exampleList = document.querySelector('#example-list');
let activeCard = null;
let dialogueAnswers = [];

const COMMON_REGISTERED = {
  key: 'registered',
  text: 'Вы уже зарегистрировались в Службе занятости?',
  options: [
    { label: 'Да', value: 'yes', note: 'Дата первой регистрации сохранена.' },
    { label: 'Нет', value: 'no', note: 'Зарегистрируйтесь как можно скорее: дата влияет на период права.' },
    { label: 'Не уверен(а)', value: 'unknown', note: 'Проверьте наличие подтверждения регистрации или первой явки.' }
  ]
};

const FLOWS = {
  'voluntary-resignation': [
    { key: 'reason', text: 'Что стало главной причиной увольнения?', options: [
      { label: 'Ухудшили условия', value: 'conditions', note: 'Это может быть уважительной причиной, если ухудшение существенное и подтверждено.' },
      { label: 'Состояние здоровья', value: 'health', note: 'Медицинская причина может быть уважительной при наличии документов.' },
      { label: 'Личное решение', value: 'personal', note: 'Без признанной уважительной причины обычно действует ожидание 90 дней.' },
      { label: 'Другая причина', value: 'other', note: 'Причину нужно сопоставить с официальным перечнем и подтвердить.' }
    ]},
    { key: 'proof', text: 'Есть документы, подтверждающие эту причину?', options: [
      { label: 'Да', value: 'yes', note: 'Приложите их к заявлению вместе с кратким объяснением.' },
      { label: 'Нет', value: 'no', note: 'Без подтверждений добиться отмены 90-дневного ожидания будет сложнее.' },
      { label: 'Частично', value: 'partial', note: 'Соберите недостающие письма, справки или переписку.' }
    ]}, COMMON_REGISTERED
  ],
  'unpaid-leave': [
    { key: 'initiator', text: 'Кто инициировал неоплачиваемый отпуск?', options: [
      { label: 'Работодатель', value: 'employer', note: 'Право возможно, если ХАЛАТ длится не менее 30 дней и выполнены остальные условия.' },
      { label: 'Я сам(а)', value: 'self', note: 'При добровольном ХАЛАТе пособие обычно не положено.' },
      { label: 'Неясно', value: 'unknown', note: 'Нужно получить письменное подтверждение работодателя.' }
    ]},
    { key: 'duration', text: 'Какова заявленная продолжительность ХАЛАТа?', options: [
      { label: '30 дней или больше', value: '30plus', note: 'Минимальное условие продолжительности выполнено.' },
      { label: 'Меньше 30 дней', value: 'under30', note: 'Для ХАЛАТа от работодателя минимальный срок обычно не выполнен.' },
      { label: 'Пока неизвестно', value: 'unknown', note: 'Попросите работодателя указать даты письменно.' }
    ]}, COMMON_REGISTERED
  ],
  'eligibility-basics': [
    { key: 'work', text: 'В каком статусе вы работали?', options: [
      { label: 'Наёмный работник', value: 'employee', note: 'Этот вид работы входит в обычную проверку права на авталу.' },
      { label: 'Только ацмаи', value: 'self', note: 'Ацмаи обычно не застрахован на случай безработицы.' },
      { label: 'И так, и так', value: 'both', note: 'Нужно отдельно проверить месяцы именно наёмной работы.' }
    ]},
    { key: 'months', text: 'Есть 12 месяцев наёмной работы из последних 18?', options: [
      { label: 'Да', value: 'yes', note: 'Базовое условие страхового периода, вероятно, выполнено.' },
      { label: 'Нет', value: 'no', note: 'Обычного страхового периода может не хватить.' },
      { label: 'Надо посчитать', value: 'unknown', note: 'Соберите тлуши и список месяцев работы.' }
    ]}, COMMON_REGISTERED
  ],
  'fired-contract-end': [
    { key: 'ending', text: 'Как закончилась работа?', options: [
      { label: 'Меня уволили', value: 'fired', note: 'Ожидание 90 дней, установленное для добровольного увольнения, обычно не применяется.' },
      { label: 'Закончился договор', value: 'contract', note: 'Окончание срочного договора рассматривается отдельно от добровольного увольнения.' },
      { label: 'Подписал(а) соглашение', value: 'agreement', note: 'Важно, как причина сформулирована в документах работодателя.' }
    ]},
    { key: 'months', text: 'Есть 12 месяцев работы из последних 18?', options: [
      { label: 'Да', value: 'yes', note: 'Страховой период, вероятно, выполнен.' },
      { label: 'Нет', value: 'no', note: 'Страхового периода может не хватить.' },
      { label: 'Не знаю', value: 'unknown', note: 'Понадобится список месяцев работы и тлуши.' }
    ]}, COMMON_REGISTERED
  ],
  'qualifying-period': [
    { key: 'months', text: 'Сколько месяцев наёмной работы было в последних 18 месяцах?', options: [
      { label: '12 или больше', value: 'yes', note: 'Общее условие страхового периода, вероятно, выполнено.' },
      { label: 'Меньше 12', value: 'no', note: 'Проверьте, могут ли специальные периоды дополнить расчёт.' },
      { label: 'Не могу посчитать', value: 'unknown', note: 'Составьте помесячный список по тлушам.' }
    ]}, COMMON_REGISTERED
  ],
  'self-employed': [
    { key: 'work', text: 'Кроме работы как ацмаи, была работа по найму?', options: [
      { label: 'Да', value: 'both', note: 'Право нужно проверять по периодам наёмной работы.' },
      { label: 'Нет', value: 'self', note: 'Обычное пособие по безработице ацмаи, как правило, не положено.' },
      { label: 'Была давно', value: 'old', note: 'Важно, попадает ли она в 18 месяцев до регистрации.' }
    ]}, COMMON_REGISTERED
  ],
  'missed-appointment': [
    { key: 'event', text: 'Что именно произошло?', options: [
      { label: 'Пропущена явка', value: 'missed', note: 'Можно потерять выплату за период между явками.' },
      { label: 'Отказ от работы', value: 'refusal', note: 'Возможны 90 дней без выплаты и уменьшение права на 30 дней.' },
      { label: 'Ошибка в системе', value: 'error', note: 'Сохраните подтверждения явки и запросите исправление записи.' }
    ]},
    { key: 'proof', text: 'Есть подтверждение уважительной причины или явки?', options: [
      { label: 'Да', value: 'yes', note: 'Приложите его при обращении или обжаловании.' },
      { label: 'Нет', value: 'no', note: 'Запросите у Службы занятости запись о событии.' },
      { label: 'Собираю', value: 'partial', note: 'Не откладывайте обращение до истечения возможного срока.' }
    ]}
  ],
  'travel-abroad': [
    { key: 'travel', text: 'На каком этапе поездка?', options: [
      { label: 'Только планирую', value: 'planning', note: 'Сверьте поездку с датами обязательных явок.' },
      { label: 'Уже за границей', value: 'abroad', note: 'Дни пребывания за границей обычно не оплачиваются.' },
      { label: 'Уже вернулся(ась)', value: 'returned', note: 'Возобновите явки и проверьте оставшиеся дни права.' }
    ]}
  ],
  'age-retirement': [
    { key: 'age', text: 'Ваш возраст сейчас?', options: [
      { label: 'Меньше 67', value: 'under67', note: 'Возрастное условие может быть выполнено; проверяются и остальные условия.' },
      { label: 'Уже исполнилось 67', value: '67plus', note: 'Стандартная автала рассчитана на период до достижения 67 лет.' },
      { label: '67 скоро', value: 'near67', note: 'Нужны точные даты рождения и прекращения работы.' }
    ]}
  ]
};

const node = (tag, className, text) => {
  const element = document.createElement(tag);
  if (className) element.className = className;
  if (text !== undefined) element.textContent = text;
  return element;
};

async function api(path, options = {}) {
  const response = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    ...options,
    headers: {
      apikey: SUPABASE_KEY,
      'Content-Type': 'application/json',
      ...(options.headers || {})
    }
  });
  if (!response.ok) throw new Error(`API ${response.status}`);
  return response.json();
}

function addList(parent, items, ordered = false) {
  const list = node(ordered ? 'ol' : 'ul');
  items.forEach(item => list.append(node('li', '', item)));
  parent.append(list);
}

function renderEmpty(isError = false) {
  result.replaceChildren();
  const box = node('div', 'empty');
  box.append(node('h2', '', isError ? 'Сервис временно недоступен' : 'В пилотной базе пока нет уверенного ответа'));
  box.append(node('p', '', isError
    ? 'Попробуйте ещё раз немного позже. Ваш вопрос не был сохранён.'
    : 'Сейчас прототип знает только основные ситуации по автале. Попробуйте уточнить причину прекращения работы, дату, возраст или слова «ХАЛАТ», «ацмаи», «Служба занятости».'));
  result.append(box);
  result.hidden = false;
  result.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function renderAnswer(items) {
  if (!items.length || items[0].score < 0.1) return renderEmpty(false);
  const primary = items[0];
  result.replaceChildren();

  const card = node('article', 'answer-card');
  const top = node('div', 'answer-top');
  top.append(node('div', 'answer-icon', '✓'));
  const heading = node('div');
  heading.append(node('div', 'answer-label', 'Наиболее подходящее правило'));
  heading.append(node('h2', '', primary.title));
  heading.append(node('p', 'short-answer', primary.short_answer));
  top.append(heading);
  card.append(top);
  card.append(node('p', 'answer-body', primary.answer));

  const grid = node('div', 'answer-grid');
  if (primary.steps?.length) {
    const steps = node('section', 'answer-panel');
    steps.append(node('h3', '', 'Что можно сделать сейчас'));
    addList(steps, primary.steps, true);
    grid.append(steps);
  }
  if (primary.follow_up_questions?.length) {
    const questions = node('section', 'answer-panel questions');
    questions.append(node('h3', '', 'Что нужно уточнить'));
    addList(questions, primary.follow_up_questions);
    grid.append(questions);
  }
  card.append(grid);

  if (primary.hebrew_terms?.length) {
    const terms = node('div', 'terms');
    primary.hebrew_terms.forEach(term => {
      const item = node('span', 'term');
      const hebrew = node('b', '', term.he);
      hebrew.dir = 'rtl';
      item.append(hebrew, document.createTextNode(` · ${term.ru} — ${term.meaning}`));
      terms.append(item);
    });
    card.append(terms);
  }

  const source = node('div', 'source-row');
  const link = node('a', '', `Источник: ${primary.source_title}`);
  link.href = primary.source_url;
  link.target = '_blank';
  link.rel = 'noopener noreferrer';
  source.append(link, node('span', '', `Проверено: ${new Date(primary.reviewed_on).toLocaleDateString('ru-RU')}`));
  card.append(source);
  result.append(card);

  startDialogue(primary, card);

  const relatedItems = items.slice(1).filter(item => item.score >= Math.max(.11, primary.score * .45)).slice(0, 2);
  if (relatedItems.length) {
    const related = node('div', 'related');
    related.append(node('strong', '', 'Возможно, пригодится также:'));
    const buttons = node('div', 'related-buttons');
    relatedItems.forEach(item => {
      const button = node('button', '', item.title);
      button.type = 'button';
      button.addEventListener('click', () => renderAnswer([item]));
      buttons.append(button);
    });
    related.append(buttons);
    result.append(related);
  }

  result.hidden = false;
  result.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function startDialogue(card, answerCard) {
  activeCard = card;
  dialogueAnswers = [];
  const flow = FLOWS[card.slug] || [COMMON_REGISTERED];
  const dialogue = node('section', 'dialogue');
  answerCard.append(dialogue);
  renderDialogueStep(dialogue, flow, 0);
}

function renderDialogueStep(container, flow, index) {
  container.replaceChildren();
  const progress = node('div', 'dialogue-progress');
  progress.append(node('span', '', `Уточнение ${Math.min(index + 1, flow.length)} из ${flow.length}`));
  const track = node('i');
  track.style.width = `${Math.min((index / flow.length) * 100, 100)}%`;
  progress.append(track);
  container.append(progress);

  if (index >= flow.length) return renderRoute(container);

  const step = flow[index];
  container.append(node('h3', '', step.text));
  const options = node('div', 'dialogue-options');
  step.options.forEach(option => {
    const button = node('button', '', option.label);
    button.type = 'button';
    button.addEventListener('click', () => {
      dialogueAnswers.push({ key: step.key, label: option.label, value: option.value, note: option.note });
      renderDialogueStep(container, flow, index + 1);
    });
    options.append(button);
  });
  container.append(options);
  if (index > 0) {
    const back = node('button', 'dialogue-back', '← Вернуться к предыдущему вопросу');
    back.type = 'button';
    back.addEventListener('click', () => {
      dialogueAnswers.pop();
      renderDialogueStep(container, flow, index - 1);
    });
    container.append(back);
  }
}

function renderRoute(container) {
  container.classList.add('complete');
  container.replaceChildren();
  container.append(node('div', 'route-kicker', 'Ваш предварительный маршрут'));
  container.append(node('h3', '', 'Что следует из ваших ответов'));

  const summary = node('div', 'route-summary');
  dialogueAnswers.forEach(item => {
    const row = node('div', 'route-row');
    row.append(node('span', '', '✓'), node('p', '', item.note));
    summary.append(row);
  });
  container.append(summary);

  if (activeCard.steps?.length) {
    container.append(node('h3', '', 'Что делать дальше'));
    addList(container, activeCard.steps, true);
  }

  if (activeCard.documents?.length) {
    const docs = node('div', 'route-docs');
    docs.append(node('strong', '', 'Что приготовить: '));
    docs.append(document.createTextNode(activeCard.documents.join(' · ')));
    container.append(docs);
  }

  const restart = node('button', 'dialogue-restart', 'Изменить ответы');
  restart.type = 'button';
  restart.addEventListener('click', () => {
    dialogueAnswers = [];
    container.classList.remove('complete');
    renderDialogueStep(container, FLOWS[activeCard.slug] || [COMMON_REGISTERED], 0);
  });
  container.append(restart);
}

async function search(question) {
  submitButton.disabled = true;
  submitButton.firstElementChild.textContent = 'Ищу…';
  try {
    const data = await api('rpc/search_knowledge', {
      method: 'POST',
      body: JSON.stringify({ query_text: question, match_count: 5 })
    });
    renderAnswer(data);
  } catch (error) {
    console.error(error);
    renderEmpty(true);
  } finally {
    submitButton.disabled = false;
    submitButton.firstElementChild.textContent = 'Разобраться';
  }
}

function useExample(question) {
  questionInput.value = question;
  questionInput.focus();
  search(question);
}

form.addEventListener('submit', event => {
  event.preventDefault();
  const question = questionInput.value.trim();
  if (question.length >= 2) search(question);
});

exampleList.addEventListener('click', event => {
  const button = event.target.closest('[data-question]');
  if (button) useExample(button.dataset.question);
});

async function loadExamples() {
  try {
    const scenarios = await api('demo_scenarios?select=question,hint&is_published=eq.true&order=display_order.asc&limit=6');
    if (!scenarios.length) return;
    exampleList.replaceChildren();
    scenarios.forEach(scenario => {
      const button = node('button', '', scenario.hint);
      button.type = 'button';
      button.dataset.question = scenario.question;
      exampleList.append(button);
    });
  } catch (error) {
    console.warn('Не удалось обновить примеры', error);
  }
}

loadExamples();
