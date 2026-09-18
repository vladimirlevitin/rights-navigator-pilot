(()=>{
  const VERSION='fb-js-v1';
  const GROUP=(location.pathname.match(/\/groups\/([^/?]+)/)||[])[1]||'group';
  const STATE_KEY='rights_nav_fb_collector_'+GROUP;
  const TATIANA=/Татьяна\s+Берлин|Tatiana\s+Berlin/i;
  const MORE_TEXT=/^(ещ[её]|see more)$/i;
  const COMMENT_EXPAND=/(посмотреть|показать|view|see).{0,35}(комментар|ответ|repl|comment)|ещ[её].{0,20}(комментар|ответ)|more.{0,20}(comment|repl)/i;
  const UI_ID='rights-nav-fb-collector';
  if(window.__RIGHTS_FB_COLLECTOR?.panel){
    window.__RIGHTS_FB_COLLECTOR.panel.style.display='block';
    return;
  }

  let running=false,timer=null,targetDate=null,targetAccepted=10,frontier=null;
  const sessionPosts=new Map(),cases=[],skipped=[],pairKeys=new Set();
  const clicked=new WeakSet();
  const monthMap={
    январь:0,января:0,янв:0,февраль:1,февраля:1,фев:1,март:2,марта:2,мар:2,
    апрель:3,апреля:3,апр:3,май:4,мая:4,июнь:5,июня:5,июн:5,июль:6,июля:6,июл:6,
    август:7,августа:7,авг:7,сентябрь:8,сентября:8,сен:8,сент:8,октябрь:9,октября:9,окт:9,
    ноябрь:10,ноября:10,ноя:10,декабрь:11,декабря:11,дек:11
  };

  const norm=s=>String(s||'').replace(/\u00a0/g,' ').replace(/[ \t]+/g,' ').replace(/\n{3,}/g,'\n\n').trim();
  const text=e=>norm(e?.innerText||e?.textContent||'');
  const visible=e=>{if(!e?.getBoundingClientRect)return false;const r=e.getBoundingClientRect();return r.width>0&&r.height>0};
  const esc=s=>norm(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));

  function parseDate(raw){
    let s=norm(raw).toLowerCase().replace(/,/g,' ').replace(/\s+г\.?/g,' ');
    let m=s.match(/(\d{1,2})[.\/-](\d{1,2})[.\/-](\d{4})/);
    if(m)return new Date(+m[3],+m[2]-1,+m[1]);
    m=s.match(/(\d{1,2})\s+([а-яё]+)\s+(\d{4})/i);
    if(m&&monthMap[m[2]]!==undefined)return new Date(+m[3],monthMap[m[2]],+m[1]);
    m=s.match(/(\d{1,2})\s+([а-яё]+)(?:\s+в\s+\d{1,2}:\d{2})?/i);
    if(m&&monthMap[m[2]]!==undefined){
      const now=new Date();
      let d=new Date(now.getFullYear(),monthMap[m[2]],+m[1]);
      if(d>new Date(now.getTime()+2*864e5))d=new Date(now.getFullYear()-1,monthMap[m[2]],+m[1]);
      return d;
    }
    if(/сегодня|today/.test(s))return new Date();
    if(/вчера|yesterday/.test(s))return new Date(Date.now()-864e5);
    m=s.match(/^(\d+)\s*(мин|минута|минуты|минут|ч|час|часа|часов|дн|день|дня|дней|нед|неделя|недели|недель)\.?$/);
    if(m){
      const u=m[2],ms=/мин/.test(u)?6e4:/^ч$|час/.test(u)?36e5:/нед/.test(u)?6048e5:864e5;
      return new Date(Date.now()-+m[1]*ms);
    }
    return null;
  }

  function loadState(){try{return JSON.parse(localStorage.getItem(STATE_KEY)||'null')}catch{return null}}
  function saveState(rec){
    const prev=loadState()||{};
    const next={
      ...prev,
      collector_version:VERSION,
      group:GROUP,
      checkpoint:{
        post_date:rec.date.toISOString().slice(0,10),
        post_iso:rec.date.toISOString(),
        post_url:rec.url,
        post_id:rec.id,
        preview:rec.preview,
        saved_at:new Date().toISOString()
      }
    };
    localStorage.setItem(STATE_KEY,JSON.stringify(next));
  }

  function topArticles(){
    return [...document.querySelectorAll('[role="article"]')]
      .filter(a=>!a.parentElement?.closest?.('[role="article"]'));
  }

  function postMeta(article){
    const ar=article.getBoundingClientRect();
    if(ar.bottom<-250||ar.top>innerHeight*2.2||ar.height<100)return null;
    const links=[...article.querySelectorAll('a[href*="/posts/"],a[href*="/permalink/"]')];
    const candidates=[];
    for(const a of links){
      const r=a.getBoundingClientRect();
      if(r.top<ar.top-10||r.top>ar.top+190)continue;
      const d=parseDate([a.getAttribute('aria-label'),a.getAttribute('title'),a.innerText,a.textContent].filter(Boolean).join(' '));
      if(!d||isNaN(d))continue;
      const url=(a.href||'').split('?')[0];
      const id=(url.match(/\/(?:posts|permalink)\/(\d+)/)||[])[1];
      if(id)candidates.push({date:d,url,id,y:r.top});
    }
    if(!candidates.length)return null;
    candidates.sort((a,b)=>a.y-b.y);
    const m=candidates[0];
    const preview=norm(text(article).split('\n').slice(0,6).join(' ')).slice(0,180);
    return {...m,article,preview,top:ar.top};
  }

  function clickSafe(el){
    if(!el||clicked.has(el)||!visible(el))return false;
    clicked.add(el);
    try{el.click();return true}catch{return false}
  }

  function expandPost(article){
    let n=0;
    for(const el of article.querySelectorAll('div[role="button"],span[role="button"],button')){
      const s=text(el);
      if(n<2&&MORE_TEXT.test(s)){ if(clickSafe(el))n++; }
    }
    return n;
  }

  function expandComments(article){
    let n=0;
    const els=[...article.querySelectorAll('div[role="button"],span[role="button"],button,a')];
    for(const el of els){
      const s=text(el);
      if(!s||s.length>140)continue;
      if(COMMENT_EXPAND.test(s)){
        if(clickSafe(el))n++;
        if(n>=3)break;
      }
    }
    return n;
  }

  function roleArticle(el){return el?.closest?.('[role="article"]')||null}
  function parentArticle(article){
    if(!article)return null;
    let p=article.parentElement;
    while(p){if(p.matches?.('[role="article"]'))return p;p=p.parentElement}
    return null;
  }

  function stripMeta(s){
    let lines=norm(s).split('\n').map(norm).filter(Boolean);
    lines=lines.filter(x=>
      !/^·$/.test(x)&&
      !/^\d+\s*(мин|ч|час|дн|день|дня|дней|нед)\.?$/i.test(x)&&
      !/^(Нравится|Ответить|Поделиться|Like|Reply|Share)$/i.test(x)&&
      !/^(Автор|Администратор)$/i.test(x)&&
      !COMMENT_EXPAND.test(x)
    );
    if(lines.length&&TATIANA.test(lines[0]))lines.shift();
    return norm(lines.join('\n'));
  }

  function dedupeText(s){
    s=norm(s);
    let lines=s.split('\n').map(norm).filter(Boolean);
    if(lines.length>=2&&lines.length%2===0){
      const h=lines.length/2,a=norm(lines.slice(0,h).join('\n')),b=norm(lines.slice(h).join('\n'));
      if(a===b)return a;
    }
    const out=[];
    for(const l of lines)if(out[out.length-1]!==l)out.push(l);
    return norm(out.join('\n'));
  }

  function questionScore(s){
    let n=0;
    if(s.length>45)n+=2;
    if(s.length>120)n+=2;
    if(s.length>250)n+=1;
    if(/[?？]/.test(s))n+=4;
    if(/подскаж|вопрос|положен|положено|имею право|можно ли|что делать|как поступить|как получить|закон|выплат|пособ|льгот|увол|аренд|инвалид|пенси/i.test(s))n+=3;
    if(TATIANA.test(s))n-=10;
    if(/комментировать как|ответить как|смотреть другие|посмотреть другие/i.test(s))n-=5;
    return n;
  }

  function getCommentArticle(marker){
    let a=roleArticle(marker);
    if(!a)return null;
    if(text(a).length<40){
      const p=parentArticle(a);
      if(p)a=p;
    }
    return a;
  }

  function questionCandidates(postRoot,commentArticle){
    const commentTop=commentArticle?.getBoundingClientRect?.().top ?? Infinity;
    let els=[...postRoot.querySelectorAll('[dir="auto"]')].filter(visible);
    if(!els.length)els=[...postRoot.querySelectorAll('div,span')].filter(visible);
    const out=[];
    for(const e of els){
      const r=e.getBoundingClientRect();
      if(r.bottom>commentTop+5)continue;
      const nearest=roleArticle(e);
      if(nearest&&nearest!==postRoot)continue;
      const s=dedupeText(stripMeta(text(e)));
      if(s.length<35||s.length>6500||TATIANA.test(s))continue;
      const score=questionScore(s);
      if(score<2)continue;
      out.push({element:e,text:s,score,distance:Math.max(0,commentTop-r.bottom)});
    }
    out.sort((a,b)=>b.score!==a.score?b.score-a.score:a.distance-b.distance);
    return out;
  }

  function cleanTatianaAnswer(commentArticle){
    let s=stripMeta(text(commentArticle));
    s=s.replace(/^Татьяна\s+Берлин\s*/i,'').replace(/^Tatiana\s+Berlin\s*/i,'');
    return dedupeText(s);
  }

  function containsMore(root){
    return [...root.querySelectorAll('span,div,[role="button"]')].some(e=>visible(e)&&MORE_TEXT.test(text(e)));
  }

  function collectFromPost(rec){
    const postRoot=rec.article;
    const markers=[...postRoot.querySelectorAll('span,div,a')].filter(e=>{
      if(!visible(e))return false;
      const s=text(e);
      return s.length>0&&s.length<100&&TATIANA.test(s);
    });
    if(!markers.length)return;

    for(const marker of markers){
      const commentArticle=getCommentArticle(marker);
      if(!commentArticle||commentArticle===postRoot)continue;
      const answer=cleanTatianaAnswer(commentArticle);
      if(answer.length<30)continue;
      const qs=questionCandidates(postRoot,commentArticle);
      if(!qs.length){
        const k=rec.id+'|no-question|'+answer.slice(0,80);
        if(!pairKeys.has(k)){
          pairKeys.add(k);
          skipped.push({post_id:rec.id,post_date:rec.date.toISOString().slice(0,10),post_url:rec.url,reason:'Найден ответ Татьяны, но не найден уверенный текст вопроса.'});
        }
        continue;
      }
      const q=qs[0];
      const question=dedupeText(q.text);
      const key=question.slice(0,350)+'|'+answer.slice(0,350);
      if(pairKeys.has(key))continue;
      pairKeys.add(key);
      const reasons=[];
      let status='ok';
      if(containsMore(q.element)){status='incomplete';reasons.push('Вопрос содержит свернутый текст «Ещё».')}
      if(containsMore(commentArticle)){status='incomplete';reasons.push('Ответ Татьяны содержит свернутый текст «Ещё».')}
      cases.push({
        question,
        tatiana_answer:answer,
        post_date:rec.date.toISOString().slice(0,10),
        post_url:rec.url,
        post_id:rec.id,
        source_url:rec.url,
        status,
        reason:reasons.join(' ')
      });
    }
  }

  function scanVisible(){
    const records=[];
    for(const article of topArticles()){
      const rec=postMeta(article);
      if(!rec)continue;
      records.push(rec);
      if(!sessionPosts.has(rec.id))sessionPosts.set(rec.id,rec);
      expandPost(article);
      expandComments(article);
      collectFromPost(rec);
    }
    records.sort((a,b)=>a.top-b.top);
    if(records.length){
      let candidates=records;
      if(frontier){
        const near=records.filter(x=>Math.abs((frontier.date-x.date)/864e5)<=75);
        if(near.length)candidates=near;
      }
      const x=candidates[candidates.length-1];
      if(!frontier||x.date<frontier.date){
        frontier=x;
        saveState(x);
      }
    }
    render();
    return records;
  }

  function stop(msg='Остановлено'){
    running=false;
    if(timer)clearTimeout(timer);
    timer=null;
    render(msg);
  }

  function tick(){
    if(!running)return;
    scanVisible();
    if(cases.filter(x=>x.status==='ok').length>=targetAccepted){
      stop('✓ Набрано '+targetAccepted+' готовых пар');
      return;
    }
    if(frontier&&targetDate&&frontier.date<=targetDate){
      stop('✓ Достигнута целевая дата');
      return;
    }
    scrollBy(0,Math.max(innerHeight*0.9,650));
    timer=setTimeout(tick,1350);
  }

  function start(){
    targetAccepted=Math.max(1,Math.min(500,Number(countInput.value)||10));
    targetDate=dateInput.value?new Date(dateInput.value+'T23:59:59'):null;
    running=true;
    render('Собираю...');
    tick();
  }

  function exportJson(){
    const state=loadState();
    const ok=cases.filter(x=>x.status==='ok').length;
    const incomplete=cases.filter(x=>x.status==='incomplete').length;
    const output={
      collector_version:VERSION,
      captured_at:new Date().toISOString(),
      page_url:location.href,
      checkpoint:state?.checkpoint||null,
      cases,
      skipped,
      summary:{
        scanned_posts:sessionPosts.size,
        total:cases.length,
        ok,
        incomplete,
        skipped:skipped.length
      }
    };
    const blob=new Blob([JSON.stringify(output,null,2)],{type:'application/json;charset=utf-8'});
    const url=URL.createObjectURL(blob),a=document.createElement('a');
    a.href=url;
    a.download='tatiana_fb_'+new Date().toISOString().replace(/[:.]/g,'-')+'.json';
    document.body.appendChild(a);a.click();a.remove();
    setTimeout(()=>URL.revokeObjectURL(url),1500);
    render('JSON сохранён');
  }

  function reset(){
    stop();
    localStorage.removeItem(STATE_KEY);
    frontier=null;sessionPosts.clear();cases.length=0;skipped.length=0;pairKeys.clear();
    render('Сессия и checkpoint очищены');
  }

  function render(msg=''){
    const state=loadState(),ok=cases.filter(x=>x.status==='ok').length,inc=cases.filter(x=>x.status==='incomplete').length;
    status.innerHTML=(msg?'<b>'+esc(msg)+'</b><br>':'')+
      'Просмотрено постов: <b>'+sessionPosts.size+'</b><br>'+
      'Готовых пар: <b>'+ok+'</b> · неполных: <b>'+inc+'</b><br>'+
      'Checkpoint: <b>'+(state?.checkpoint?.post_date||'нет')+'</b>'+
      (state?.checkpoint?.post_id?'<br><small>post '+esc(state.checkpoint.post_id)+'</small>':'');
    const recent=cases.slice(-12).reverse();
    list.innerHTML=recent.length?recent.map((x,i)=>
      '<div style="padding:6px 0;border-bottom:1px solid #ddd">'+
      '<b>'+esc(x.post_date)+'</b> · '+esc(x.question).slice(0,120)+
      '<br><small>'+esc(x.tatiana_answer).slice(0,110)+'</small>'+
      '<br><a target="_blank" href="'+esc(x.post_url)+'">post '+esc(x.post_id)+'</a> · <b>'+esc(x.status)+'</b>'+
      '</div>'
    ).join(''):'<small>Пары пока не найдены.</small>';
  }

  const panel=document.createElement('div');
  panel.id=UI_ID;
  panel.style='position:fixed;top:12px;right:12px;width:390px;max-height:92vh;overflow:auto;z-index:2147483647;background:#fff;color:#111;border:2px solid #1877f2;border-radius:10px;padding:12px;font:14px Arial;box-shadow:0 4px 18px #0005';
  panel.innerHTML=
    '<b style="font-size:17px">FB COLLECTOR '+VERSION+'</b><span id="fc-x" style="float:right;cursor:pointer;font-size:20px">✕</span>'+
    '<div style="margin-top:9px;display:grid;grid-template-columns:1fr 1fr;gap:7px">'+
      '<label>Собрать пар<input id="fc-count" type="number" min="1" max="500" value="10" style="width:100%;box-sizing:border-box;padding:6px;margin-top:3px"></label>'+
      '<label>Не старше даты<input id="fc-date" type="date" style="width:100%;box-sizing:border-box;padding:6px;margin-top:3px"></label>'+
    '</div>'+
    '<div style="display:flex;gap:6px;margin-top:8px"><button id="fc-start" style="flex:1;padding:7px">▶ Старт</button><button id="fc-stop" style="flex:1;padding:7px">■ Стоп</button></div>'+
    '<div style="display:flex;gap:6px;margin-top:6px"><button id="fc-export" style="flex:1;padding:7px">Скачать JSON</button><button id="fc-reset" style="flex:1;padding:7px">Сбросить</button></div>'+
    '<div id="fc-status" style="margin-top:9px;line-height:1.45"></div>'+
    '<details open style="margin-top:8px"><summary style="cursor:pointer;font-weight:700">Последние найденные пары</summary><div id="fc-list" style="margin-top:5px;max-height:330px;overflow:auto"></div></details>';
  document.body.appendChild(panel);
  const status=panel.querySelector('#fc-status'),list=panel.querySelector('#fc-list'),
    countInput=panel.querySelector('#fc-count'),dateInput=panel.querySelector('#fc-date');
  panel.querySelector('#fc-start').onclick=start;
  panel.querySelector('#fc-stop').onclick=()=>stop();
  panel.querySelector('#fc-export').onclick=exportJson;
  panel.querySelector('#fc-reset').onclick=reset;
  panel.querySelector('#fc-x').onclick=()=>{stop();panel.style.display='none'};
  window.__RIGHTS_FB_COLLECTOR={panel,start,stop,scan:scanVisible,exportJson,version:VERSION};
  scanVisible();
})();