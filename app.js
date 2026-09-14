const SUPABASE_URL = 'https://fgadxhyeegncmyjepypg.supabase.co';
const SUPABASE_KEY = 'sb_publishable_Q1pZaATQwb6XomNXpXA8NQ_2pAtgAi7';

const form = document.querySelector('#search-form');
const questionInput = document.querySelector('#question');
const submitButton = document.querySelector('#submit-button');
const result = document.querySelector('#result');
const exampleList = document.querySelector('#example-list');

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
