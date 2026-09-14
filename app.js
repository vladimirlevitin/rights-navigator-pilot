const SUPABASE_URL = 'https://fgadxhyeegncmyjepypg.supabase.co';
const SUPABASE_KEY = 'sb_publishable_Q1pZaATQwb6XomNXpXA8NQ_2pAtgAi7';

const form = document.querySelector('#search-form');
const questionInput = document.querySelector('#question');
const submitButton = document.querySelector('#submit-button');
const result = document.querySelector('#result');
const exampleList = document.querySelector('#example-list');
const EXAMPLE_VARIANTS = {
  1: [
    { label: 'Уволили — когда регистрироваться?', question: 'Меня уволили. Когда нужно зарегистрироваться в Службе занятости?' },
    { label: 'Фирма закрылась', question: 'Фирма закрылась, и я остался без работы. Что нужно сделать в первую очередь?' },
    { label: 'Когда идти на биржу труда?', question: 'После увольнения когда нужно идти регистрироваться на бирже труда?' },
    { label: 'Первый день после увольнения', question: 'Я только что потеряла работу. Нужно ли сразу отмечаться в Службе занятости?' }
  ],
  2: [
    { label: 'Ухудшили условия работы', question: 'Я уволилась сама из-за существенного ухудшения условий. Придётся ждать 90 дней?' },
    { label: 'Ушла по состоянию здоровья', question: 'Я ушла с работы по медицинской причине. Можно ли не ждать 90 дней?' },
    { label: 'Уволился сам — будет автала?', question: 'Я уволился по собственному желанию. Когда смогу получать пособие по безработице?' },
    { label: 'Есть уважительная причина', question: 'Если была уважительная причина уволиться самому, выплатят ли авталу сразу?' }
  ],
  3: [
    { label: 'Отправили в ХАЛАТ', question: 'Работодатель отправил меня в ХАЛАТ на 45 дней. Положена ли мне автала?' },
    { label: 'Неоплачиваемый отпуск', question: 'Меня отправляют в неоплачиваемый отпуск. Могу ли я получить пособие?' },
    { label: 'ХАЛАТ на месяц', question: 'Работодатель оформил ХАЛАТ на 30 дней. Что мне теперь делать?' },
    { label: 'Временно нет работы', question: 'Работодатель временно остановил работу и не платит зарплату. Есть ли право на авталу?' }
  ],
  4: [
    { label: 'Сколько нужно проработать?', question: 'Сколько месяцев нужно проработать, чтобы иметь право на авталу?' },
    { label: 'Хватит ли стажа?', question: 'Я работал не весь последний год. Хватит ли страхового периода для пособия?' },
    { label: '12 месяцев из 18', question: 'Как считается условие 12 месяцев работы из последних 18?' },
    { label: 'Работала с перерывами', question: 'Я работала с перерывами. Как проверить, хватает ли месяцев для авталы?' }
  ],
  5: [
    { label: 'Сколько дней будут платить?', question: 'Мне 46 лет. Сколько дней мне могут платить пособие по безработице?' },
    { label: 'Возраст и срок авталы', question: 'Зависит ли количество дней выплаты авталы от возраста?' },
    { label: 'На какой срок дадут пособие?', question: 'Как узнать, сколько дней пособия по безработице мне положено?' },
    { label: 'Мне больше 45 лет', question: 'Мне больше 45 лет. На какой срок я могу получить авталу?' }
  ],
  6: [
    { label: 'Куда пропали первые пять дней?', question: 'Почему первые пять дней безработицы мне не оплатили?' },
    { label: 'Выплатили меньше ожидаемого', question: 'Пособие пришло меньше, чем я ожидал. Могли ли вычесть первые пять дней?' },
    { label: 'Первые дни без оплаты', question: 'Правда ли, что в начале периода безработицы несколько дней не оплачивают?' },
    { label: 'Как считают дни выплаты?', question: 'Как Битуах Леуми рассчитывает оплачиваемые дни и первые пять дней?' }
  ]
};

function chooseExampleVariant(scenario) {
  const variants = EXAMPLE_VARIANTS[scenario.id];
  if (!variants?.length) return { label: scenario.hint, question: scenario.question };

  const storageKey = `example_variant_${scenario.id}`;
  let previous = -1;
  try { previous = Number(sessionStorage.getItem(storageKey) ?? -1); } catch (_) {}

  let index = Math.floor(Math.random() * variants.length);
  if (variants.length > 1 && index === previous) index = (index + 1) % variants.length;
  try { sessionStorage.setItem(storageKey, String(index)); } catch (_) {}
  return variants[index];
}


let originalQuestion = '';
let dialogueAnswers = [];
let debugVisible = true;

const node = (tag, className, text) => {
  const element = document.createElement(tag);
  if (className) element.className = className;
  if (text !== undefined) element.textContent = text;
  return element;
};

async function api(path, options = {}) {
  const response = await fetch(SUPABASE_URL + '/rest/v1/' + path, {
    ...options,
    headers: { apikey: SUPABASE_KEY, 'Content-Type': 'application/json', ...(options.headers || {}) }
  });
  if (!response.ok) throw new Error('API ' + response.status);
  return response.json();
}

function ensureClientId() {
  let id = sessionStorage.getItem('navigator_session_id');
  if (!id) {
    id = crypto.randomUUID();
    sessionStorage.setItem('navigator_session_id', id);
  }
  return id;
}

function dateRu(value) {
  if (!value) return 'дата не указана';
  return new Date(value).toLocaleDateString('ru-RU');
}

function percent(value) {
  return Math.max(0, Math.min(100, Math.round((Number(value) || 0) * 100)));
}

function addCitations(parent, slugs, sourceMap) {
  if (!slugs?.length) return;
  const citations = node('span', 'inline-citations');
  slugs.forEach(slug => {
    const source = sourceMap.get(slug);
    if (!source) return;
    const link = node('a', '', source.title);
    link.href = source.source_url;
    link.target = '_blank';
    link.rel = 'noopener noreferrer';
    link.title = source.source_title;
    citations.append(link);
  });
  parent.append(citations);
}

function renderLoading() {
  result.replaceChildren();
  const box = node('article', 'answer-card loading-card');
  box.append(node('div', 'answer-label', 'Многоэтапный анализ'));
  box.append(node('h2', '', 'Разбираю ситуацию…'));
  const stages = node('div', 'loading-stages');
  ['Привожу вопрос к стандартному виду', 'Ищу материалы по смыслу', 'Проверяю, хватает ли данных', 'Собираю ответ с источниками'].forEach((text, index) => {
    const row = node('div', 'loading-stage');
    row.append(node('span', '', String(index + 1)), node('p', '', text));
    stages.append(row);
  });
  box.append(stages);
  result.append(box);
  result.hidden = false;
  result.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function renderEmpty(message = 'Сейчас прототип знает только основные ситуации по автале.') {
  result.replaceChildren();
  const box = node('div', 'empty');
  box.append(node('h2', '', 'В базе пока нет уверенного ответа'));
  box.append(node('p', '', message));
  result.append(box);
  result.hidden = false;
}

function renderDebug(analysis) {
  const wrapper = node('section', 'debug-wrapper');
  const head = node('div', 'debug-head');
  const title = node('div');
  title.append(node('strong', '', 'Как получен ответ'), node('p', '', 'Проверяемый протокол работы алгоритма, не скрытые рассуждения модели.'));
  const toggle = node('button', 'debug-toggle', debugVisible ? 'Скрыть' : 'Показать');
  toggle.type = 'button';
  head.append(title, toggle);
  wrapper.append(head);

  const body = node('div', 'debug-body');
  body.hidden = !debugVisible;
  toggle.addEventListener('click', () => {
    debugVisible = !debugVisible;
    body.hidden = !debugVisible;
    toggle.textContent = debugVisible ? 'Скрыть' : 'Показать';
  });

  const stages = [
    ['1', 'Принят вопрос', analysis.received_question],
    ['2', 'Стандартная формулировка', analysis.normalized_question],
    ['3', 'Выделены факты', analysis.known_facts?.length ? analysis.known_facts.map(x => x.label + ': ' + x.value).join(' · ') : 'Явных фактов пока мало'],
    ['4', 'Построен смысловой вектор', analysis.vector.model + ' · ' + analysis.vector.dimensions + ' чисел'],
  ];
  stages.forEach(([number, label, value]) => {
    const item = node('article', 'debug-stage');
    item.append(node('span', 'debug-number', number));
    const copy = node('div');
    copy.append(node('strong', '', label), node('p', '', value));
    item.append(copy);
    body.append(item);
  });

  const retrieval = node('article', 'debug-stage debug-retrieval');
  retrieval.append(node('span', 'debug-number', '5'));
  const found = node('div');
  found.append(node('strong', '', 'Найдены релевантные материалы'));
  if (!analysis.retrieval?.length) found.append(node('p', '', 'Ни одна карточка не прошла порог уверенности.'));
  (analysis.retrieval || []).forEach(item => {
    const row = node('div', 'score-row');
    const copy = node('div');
    copy.append(node('b', '', item.title), node('small', '', ' смысл ' + percent(item.semantic_score) + '% · текст ' + percent(item.lexical_score) + '%'));
    const meter = node('i');
    meter.style.width = percent(item.combined_score) + '%';
    row.append(copy, meter);
    found.append(row);
  });
  retrieval.append(found);
  body.append(retrieval);

  const final = node('article', 'debug-stage');
  final.append(node('span', 'debug-number', '6'));
  const finalCopy = node('div');
  finalCopy.append(node('strong', '', 'Ответ собран по найденным материалам'));
  finalCopy.append(node('p', '', analysis.synthesis.model + ' · использовано карточек: ' + analysis.synthesis.used_cards + ' · внешние знания запрещены'));
  final.append(finalCopy);
  body.append(final);

  const routeStage = node('article', 'debug-stage');
  routeStage.append(node('span', 'debug-number', '7'));
  const routeCopy = node('div');
  routeCopy.append(node('strong', '', analysis.next_question?.ask ? 'Выбрано следующее уточнение' : 'Выбран итоговый маршрут'));
  routeCopy.append(node('p', '', analysis.next_question?.ask ? analysis.next_question.text : (analysis.routing?.title || 'Маршрут не определён')));
  routeStage.append(routeCopy);
  body.append(routeStage);

  if (analysis.missing_facts?.length) {
    const missing = node('div', 'debug-missing');
    missing.append(node('strong', '', 'Каких данных не хватает'));
    const list = node('ul');
    analysis.missing_facts.forEach(item => list.append(node('li', '', item.label + ' — ' + item.why)));
    missing.append(list);
    body.append(missing);
  }
  wrapper.append(body);
  return wrapper;
}

function renderRouting(route, payload) {
  if (!route) return null;
  const labels = {
    self_service: 'Можно действовать самостоятельно',
    community_question: 'Подготовить вопрос для сообщества',
    professional_help: 'Возможно, нужна профессиональная помощь',
    out_of_scope: 'Вопрос пока отсутствует в базе'
  };
  const box = node('section', 'route-decision route-' + route.type);
  box.append(node('div', 'route-kicker', 'Результат маршрутизации'));
  box.append(node('h3', '', route.title || labels[route.type]));
  box.append(node('p', 'route-explanation', route.explanation));

  if (route.type === 'self_service' && payload.sources?.[0]) {
    const link = node('a', 'route-action', 'Открыть официальный источник →');
    link.href = payload.sources[0].source_url;
    link.target = '_blank';
    link.rel = 'noopener noreferrer';
    box.append(link);
  }

  if (route.type === 'community_question' && route.prepared_question) {
    const prepared = node('div', 'prepared-question');
    prepared.append(node('strong', '', 'Подготовленный вопрос'));
    prepared.append(node('p', '', route.prepared_question));
    const copy = node('button', 'route-action', 'Скопировать вопрос');
    copy.type = 'button';
    copy.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(route.prepared_question);
        copy.textContent = 'Скопировано ✓';
      } catch (_) {
        copy.textContent = 'Выделите и скопируйте текст';
      }
    });
    prepared.append(copy);
    box.append(prepared);
  }

  if (route.type === 'professional_help') {
    box.append(node('p', 'route-note', 'В рабочей версии здесь можно подключить проверенного специалиста или коммерческую службу. Сейчас это только демонстрация маршрута.'));
  }
  if (route.type === 'out_of_scope') {
    box.append(node('p', 'route-note', 'Система не будет придумывать ответ по теме, которой нет среди проверенных материалов.'));
  }
  return box;
}

function renderPayload(payload) {
  const answer = payload.answer;
  if (!answer) return renderEmpty();
  const sourceMap = new Map((payload.sources || []).map(x => [x.slug, x]));
  result.replaceChildren();

  const card = node('article', 'answer-card');
  const top = node('div', 'answer-top');
  top.append(node('div', 'answer-icon', answer.status === 'out_of_scope' ? '?' : '✓'));
  const heading = node('div');
  const status = answer.status === 'needs_clarification' ? 'Предварительный ответ · нужно уточнение'
    : answer.status === 'out_of_scope' ? 'За пределами пилотной базы' : 'Предварительный маршрут';
  heading.append(node('div', 'answer-label', status), node('h2', '', answer.headline));
  top.append(heading);
  card.append(top);

  if (dialogueAnswers.length) {
    const history = node('div', 'clarification-history');
    history.append(node('strong', '', 'Уже уточнили: '));
    history.append(document.createTextNode(dialogueAnswers.map(x => x.question + ' — ' + x.answer).join(' · ')));
    card.append(history);
  }

  const findings = node('section', 'synthesis-section');
  findings.append(node('h3', '', 'Что следует из имеющихся данных'));
  if (!answer.findings?.length) findings.append(node('p', 'answer-body-v2', 'В текущей базе недостаточно материала для содержательного вывода.'));
  (answer.findings || []).forEach(item => {
    const paragraph = node('p', 'finding');
    paragraph.append(document.createTextNode(item.text));
    addCitations(paragraph, item.source_slugs, sourceMap);
    findings.append(paragraph);
  });
  card.append(findings);

  if (answer.next_steps?.length) {
    const steps = node('section', 'synthesis-section steps-v2');
    steps.append(node('h3', '', 'Что можно сделать сейчас'));
    const list = node('ol');
    answer.next_steps.forEach(item => {
      const li = node('li');
      li.append(document.createTextNode(item.text));
      addCitations(li, item.source_slugs, sourceMap);
      list.append(li);
    });
    steps.append(list);
    card.append(steps);
  }

  if (answer.next_question?.ask && answer.next_question.options?.length) {
    const dialogue = node('section', 'dialogue dynamic-dialogue');
    dialogue.append(node('div', 'route-kicker', 'Уточнение, которое меняет вывод'));
    dialogue.append(node('h3', '', answer.next_question.text));
    dialogue.append(node('p', 'question-why', answer.next_question.why));
    const options = node('div', 'dialogue-options');
    answer.next_question.options.forEach(option => {
      const button = node('button', '', option.label);
      button.type = 'button';
      button.addEventListener('click', () => {
        dialogueAnswers.push({ key: answer.next_question.key, question: answer.next_question.text, answer: option.label });
        search(originalQuestion, dialogueAnswers);
      });
      options.append(button);
    });
    dialogue.append(options);
    card.append(dialogue);
  } else if (answer.routing) {
    const route = renderRouting(answer.routing, payload);
    if (route) card.append(route);
  }

  if (payload.sources?.length) {
    const sources = node('section', 'sources-v2');
    sources.append(node('h3', '', 'Использованные источники'));
    payload.sources.forEach((source, index) => {
      const row = node('div', 'source-v2');
      const link = node('a', '', (index + 1) + '. ' + source.source_title);
      link.href = source.source_url;
      link.target = '_blank';
      link.rel = 'noopener noreferrer';
      row.append(link, node('span', '', source.title + ' · проверено ' + dateRu(source.reviewed_on)));
      sources.append(row);
    });
    card.append(sources);
  }

  if (answer.limitations?.length) {
    const limits = node('div', 'limitations');
    limits.append(node('strong', '', 'Ограничения: '), document.createTextNode(answer.limitations.join(' ')));
    card.append(limits);
  }
  result.append(card, renderDebug({ ...payload.analysis, routing: answer.routing, next_question: answer.next_question }));

  if (dialogueAnswers.length) {
    const restart = node('button', 'restart-analysis', 'Начать разбор заново');
    restart.type = 'button';
    restart.addEventListener('click', () => { dialogueAnswers = []; search(originalQuestion, []); });
    result.append(restart);
  }
  result.hidden = false;
  result.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

async function search(question, answers = []) {
  originalQuestion = question;
  submitButton.disabled = true;
  submitButton.firstElementChild.textContent = answers.length ? 'Уточняю…' : 'Разбираю…';
  renderLoading();
  try {
    const response = await fetch(SUPABASE_URL + '/functions/v1/semantic-search', {
      method: 'POST',
      headers: { apikey: SUPABASE_KEY, 'Content-Type': 'application/json' },
      body: JSON.stringify({ question, answers, client_id: ensureClientId() })
    });
    const payload = await response.json();
    if (!response.ok) throw new Error(payload.message || 'semantic API ' + response.status);
    renderPayload(payload);
  } catch (error) {
    console.error(error);
    renderEmpty('Не удалось завершить интеллектуальный анализ. Попробуйте ещё раз немного позже. Вопрос не был сохранён.');
  } finally {
    submitButton.disabled = false;
    submitButton.firstElementChild.textContent = 'Разобраться';
  }
}

function useExample(question) {
  dialogueAnswers = [];
  questionInput.value = question;
  questionInput.focus();
  search(question, []);
}

form.addEventListener('submit', event => {
  event.preventDefault();
  const question = questionInput.value.trim();
  if (question.length >= 2) {
    dialogueAnswers = [];
    search(question, []);
  }
});

exampleList.addEventListener('click', event => {
  const button = event.target.closest('[data-question]');
  if (button) useExample(button.dataset.question);
});

async function loadExamples() {
  try {
    const scenarios = await api('demo_scenarios?select=id,question,hint&is_published=eq.true&order=display_order.asc&limit=6');
    if (!scenarios.length) return;
    exampleList.replaceChildren();
    scenarios.forEach(scenario => {
      const variant = chooseExampleVariant(scenario);
      const button = node('button', '', variant.label);
      button.type = 'button';
      button.dataset.question = variant.question;
      exampleList.append(button);
    });
  } catch (error) {
    console.warn('Не удалось обновить примеры', error);
  }
}

loadExamples();
