/* app.js — Raku Drills.
 *
 * Screens: home (pick a level) → drill (one question at a time, checked the
 * moment you answer) → results. Progress lives in localStorage.
 *
 * Question types follow the Final Test of the Complete Raku Course —
 * choice / multi / boolean / input — plus `fill`, where you type the missing
 * few characters straight into the snippet. A `fill` is accepted either because
 * it matches a known-good answer or because running the completed program with
 * Raku.js produces the expected output, so alternative spellings still pass.
 */
(function () {
  'use strict';

  /* ── levels ─────────────────────────────────────────────────────── */
  const LEVELS = [
    { id: 'A1', name: 'Breakthrough', blurb: 'Sigils, say, numbers and strings, if and for.' },
    { id: 'A2', name: 'Waystage', blurb: 'Subs, arrays and hashes, the everyday methods.' },
    { id: 'B1', name: 'Threshold', blurb: 'Signatures, multis, blocks, first regexes, classes.' },
    { id: 'B2', name: 'Vantage', blurb: 'Containers, metaoperators, roles, laziness, adverbs.' },
    { id: 'C1', name: 'Effective', blurb: 'Phasers, custom operators, the MOP, grammars, exceptions.' },
    { id: 'C2', name: 'Mastery', blurb: 'Grammars with actions, concurrency, metamodel, native calls.' },
  ];
  const SESSION_LEN = 15;

  /* ── tiny helpers ───────────────────────────────────────────────── */
  const $ = (id) => document.getElementById(id);
  const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  const md = (s) => esc(s).replace(/`([^`]+)`/g, (_, c) => '<code>' + c + '</code>');
  const norm = (s) => String(s).trim().toLowerCase().replace(/\s+/g, ' ');

  function hash(str) {           // djb2 — stable ids that survive reordering
    let h = 5381;
    for (let i = 0; i < str.length; i++) h = ((h << 5) + h + str.charCodeAt(i)) | 0;
    return (h >>> 0).toString(36);
  }
  function shuffle(a) {
    for (let i = a.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }
    return a;
  }

  /* ── data ───────────────────────────────────────────────────────── */
  const DRILLS = (window.DRILLS || []).map((d) => Object.assign({}, d, {
    id: d.level + '-' + hash(d.q + (d.code || '')),
  }));
  const byLevel = (lv) => DRILLS.filter((d) => d.level === lv);

  /* ── progress ───────────────────────────────────────────────────── */
  const PKEY = 'rakuDrills.progress.v1';
  const TKEY = 'rakuDrills.theme';

  let progress = load();
  function load() {
    try {
      const p = JSON.parse(localStorage.getItem(PKEY));
      if (p && p.drills) return p;
    } catch (e) { /* fall through to a fresh record */ }
    return { drills: {}, sessions: 0 };
  }
  function save() {
    try { localStorage.setItem(PKEY, JSON.stringify(progress)); } catch (e) { /* private mode */ }
  }
  function rec(id) {
    return progress.drills[id] || (progress.drills[id] = { seen: 0, ok: 0, ko: 0 });
  }
  function record(id, correct) {
    const r = rec(id);
    r.seen++;
    if (correct) r.ok++; else r.ko++;
    r.last = correct ? 1 : 0;
    save();
  }
  // Mastered = answered right the last time and right at least twice overall.
  const mastered = (d) => { const r = progress.drills[d.id]; return !!r && r.last === 1 && r.ok >= 2; };
  function levelStats(lv) {
    const ds = byLevel(lv);
    const done = ds.filter((d) => progress.drills[d.id]).length;
    return { total: ds.length, seen: done, mastered: ds.filter(mastered).length };
  }

  /* ── state ──────────────────────────────────────────────────────── */
  let session = [];      // drills in this run
  let idx = 0;
  let answered = false;
  let score = 0;
  let misses = [];
  let picked = new Set();
  let boolPick = null;
  let checking = false;

  /* ── theme ──────────────────────────────────────────────────────── */
  // Owned by /theme/boot.js, which resolves it before first paint and is driven
  // from the site bar, so every section of raku.online switches the same way.
  function initTheme() {}
  // The theme is owned by /theme/boot.js and switched from the site bar.

  /* ── screens ────────────────────────────────────────────────────── */
  function show(name) {
    for (const s of ['home', 'drill', 'results']) $(s).hidden = s !== name;
    window.scrollTo(0, 0);
  }

  /* ── home ───────────────────────────────────────────────────────── */
  function renderHome() {
    $('levelGrid').innerHTML = LEVELS.map((lv) => {
      const s = levelStats(lv.id);
      const pct = s.total ? Math.round((s.mastered / s.total) * 100) : 0;
      // Mastery needs two correct answers, so a card that only reported it sat
      // at 0/25 through a whole first session and read as nothing being saved.
      // The lighter bar and the "seen" count show the work that has been done.
      const seenPct = s.total ? Math.round((s.seen / s.total) * 100) : 0;
      const seen = s.seen ? `<span>${s.seen} seen · ${s.mastered}/${s.total} mastered</span>`
                          : `<span>${s.mastered}/${s.total} mastered</span>`;
      return `<button class="level-card" data-level="${lv.id}">
        <div class="lv-row"><span class="lv-id">${lv.id}</span><span class="lv-name">${esc(lv.name)}</span></div>
        <p class="lv-blurb">${esc(lv.blurb)}</p>
        <div class="bar"><u style="width:${seenPct}%"></u><i style="width:${pct}%"></i></div>
        <div class="lv-foot">${seen}<span>${pct}%</span></div>
      </button>`;
    }).join('');
    for (const el of $('levelGrid').querySelectorAll('.level-card')) {
      el.onclick = () => startSession(byLevel(el.dataset.level), el.dataset.level);
    }

    const seen = Object.keys(progress.drills).length;
    const ok = Object.values(progress.drills).reduce((n, r) => n + r.ok, 0);
    const ko = Object.values(progress.drills).reduce((n, r) => n + r.ko, 0);
    const acc = ok + ko ? Math.round((ok / (ok + ko)) * 100) : 0;
    $('overallStats').innerHTML =
      `<div><b>${DRILLS.length}</b>drills in the bank</div>
       <div><b>${seen}</b>attempted</div>
       <div><b>${DRILLS.filter(mastered).length}</b>mastered</div>
       <div><b>${acc}%</b>accuracy</div>
       <div><b>${progress.sessions}</b>sessions</div>`;
  }

  $('mixBtn').onclick = () => startSession(DRILLS.slice(), 'Mixed');
  $('weakBtn').onclick = () => {
    const weak = DRILLS.filter((d) => { const r = progress.drills[d.id]; return r && !mastered(d); });
    startSession(weak.length ? weak : DRILLS.slice(), 'Weak spots');
  };
  $('resetBtn').onclick = () => {
    if (!confirm('Erase all progress on this device?')) return;
    progress = { drills: {}, sessions: 0 };
    save();
    renderHome();
  };

  /* ── session ────────────────────────────────────────────────────── */
  function startSession(pool, label) {
    if (!pool.length) return;
    // Unseen first, then the ones you got wrong, then the rest.
    const weight = (d) => {
      const r = progress.drills[d.id];
      if (!r) return 0;
      if (r.last === 0) return 1;
      return mastered(d) ? 3 : 2;
    };
    const sorted = shuffle(pool.slice()).sort((a, b) => weight(a) - weight(b));
    session = shuffle(sorted.slice(0, Math.min(SESSION_LEN, sorted.length)));
    idx = 0; score = 0; misses = [];
    session.label = label;
    session.pool = pool;   // so "Drill again" draws from the same set
    show('drill');
    renderQuestion();
  }

  function renderQuestion() {
    const d = session[idx];
    answered = false; checking = false;
    picked = new Set(); boolPick = null;

    $('progressFill').style.width = ((idx / session.length) * 100) + '%';
    $('qLevel').textContent = d.level;
    $('qTopic').textContent = d.topic || '';
    $('qCount').textContent = (idx + 1) + ' / ' + session.length;
    $('qScore').textContent = score ? score + ' ✓' : '';
    $('qText').innerHTML = md(d.q);
    $('verdict').hidden = true;
    $('nextBtn').hidden = true;
    $('checkBtn').hidden = false;
    $('checkBtn').disabled = true;
    $('checkBtn').textContent = 'Check';
    $('playground').hidden = true;
    $('playBtn').textContent = '▶ Playground';
    // Nothing to run for a bare question, and some topics need full Rakudo.
    $('playBtn').hidden = !!d.noRun || !playSource(d).trim();

    const area = $('answerArea');
    area.innerHTML = '';

    // ── the snippet (fill drills weave inputs into it) ──
    const codeWrap = $('qCode');
    if (d.type === 'fill') {
      codeWrap.hidden = false;
      const width = Math.max(4, ...(d.accept || ['']).map((a) => a.length)) + 2;
      codeWrap.innerHTML = RakuHL.renderCodeWithBlanks(d.code || '',
        () => `<input class="fill-input" id="fillIn" size="${width}" spellcheck="false"
                 autocomplete="off" autocapitalize="off" autocorrect="off">`);
      const inp = $('fillIn');
      inp.oninput = () => { $('checkBtn').disabled = !inp.value.trim(); };
      inp.onkeydown = (e) => { if (e.key === 'Enter') { e.preventDefault(); onCheck(); } };
      setTimeout(() => inp.focus(), 30);
      if (d.hint) area.innerHTML = `<p class="hint">${md(d.hint)}</p>`;
    } else {
      codeWrap.hidden = !d.code;
      if (d.code) codeWrap.innerHTML = RakuHL.renderCode(d.code);
    }

    // ── the answer widget ──
    if (d.type === 'boolean') {
      area.innerHTML = `<div class="bool-row">
        <button class="opt" data-bool="true"><span class="key">1</span><span>True</span></button>
        <button class="opt" data-bool="false"><span class="key">2</span><span>False</span></button>
      </div>`;
      for (const b of area.querySelectorAll('[data-bool]')) {
        b.onclick = () => {
          if (answered) return;
          boolPick = b.dataset.bool === 'true';
          for (const o of area.querySelectorAll('.opt')) o.classList.remove('sel');
          b.classList.add('sel');
          $('checkBtn').disabled = false;
        };
      }
    } else if (d.type === 'choice' || d.type === 'multi') {
      if (d.type === 'multi') area.innerHTML = '<p class="hint">Select every line that applies.</p>';
      d.options.forEach((opt, i) => {
        const b = document.createElement('button');
        b.className = 'opt';
        b.dataset.i = i;
        b.innerHTML = `<span class="key">${i + 1}</span><span>${md(opt)}</span>`;
        b.onclick = () => toggle(i, b);
        area.appendChild(b);
      });
    } else if (d.type === 'input') {
      area.innerHTML = `<input class="text-input" id="textIn" spellcheck="false"
        autocomplete="off" autocapitalize="off" autocorrect="off" placeholder="type your answer">`;
      const inp = $('textIn');
      inp.oninput = () => { $('checkBtn').disabled = !inp.value.trim(); };
      inp.onkeydown = (e) => { if (e.key === 'Enter') { e.preventDefault(); onCheck(); } };
      setTimeout(() => inp.focus(), 30);
    }

    // playground source for this drill
    $('pgSrc').value = playSource(d);
    $('pgOut').innerHTML = '<span class="muted">Output appears here.</span>';
  }

  function toggle(i, btn) {
    if (answered) return;
    const d = session[idx];
    if (d.type === 'choice') {
      picked = new Set([i]);
      for (const o of $('answerArea').querySelectorAll('.opt')) o.classList.remove('sel');
      btn.classList.add('sel');
    } else {
      if (picked.has(i)) { picked.delete(i); btn.classList.remove('sel'); }
      else { picked.add(i); btn.classList.add('sel'); }
    }
    $('checkBtn').disabled = picked.size === 0;
  }

  /* The program the Playground starts from: an explicit `run`, or the snippet
   * with its blank already filled in with a correct answer. */
  function playSource(d) {
    if (d.run) return d.run;
    let src = d.code || '';
    if (d.type === 'fill') src = src.split('___').join((d.accept && d.accept[0]) || '');
    return src;
  }

  /* ── checking ───────────────────────────────────────────────────── */
  async function onCheck() {
    if (answered || checking) return;
    const d = session[idx];
    let correct = false, note = '';

    if (d.type === 'boolean') {
      if (boolPick === null) return;
      correct = boolPick === !!d.answer;
    } else if (d.type === 'choice' || d.type === 'multi') {
      if (!picked.size) return;
      const want = new Set([].concat(d.answer));
      correct = picked.size === want.size && [...picked].every((i) => want.has(i));
    } else if (d.type === 'input') {
      const v = $('textIn').value;
      if (!v.trim()) return;
      correct = (d.accept || [].concat(d.answer)).some((a) => norm(a) === norm(v));
    } else if (d.type === 'fill') {
      const inp = $('fillIn');
      const v = inp.value;
      if (!v.trim()) return;
      correct = (d.accept || []).some((a) => a.trim() === v.trim() || norm(a) === norm(v));
      // Not a listed answer — but does it actually work? Ask the interpreter.
      if (!correct && d.expect != null && Engine.ready) {
        checking = true;
        $('checkBtn').textContent = 'Running…';
        $('checkBtn').disabled = true;
        const res = await Engine.run((d.code || '').split('___').join(v), { timeoutMs: 8000 });
        checking = false;
        if (res.ok && res.text.trim() === String(d.expect).trim()) {
          correct = true;
          note = 'Not the answer we had in mind, but it runs and prints the right thing.';
        } else if (res.ok) {
          note = 'Your version runs, but prints:\n' + (res.text.trim() || '(nothing)');
        } else if (res.error) {
          note = 'Your version does not compile:\n' + firstLine(res.text || res.error);
        }
      }
      inp.classList.add(correct ? 'right' : 'wrong');
      inp.disabled = true;
    }

    answered = true;
    if (correct) score++;
    else misses.push(d);
    record(d.id, correct);
    reveal(d, correct, note);
  }

  function firstLine(s) {
    return String(s).split('\n').filter((l) => l.trim()).slice(0, 3).join('\n');
  }

  function reveal(d, correct, note) {
    // lock and colour the options
    const opts = [...$('answerArea').querySelectorAll('.opt')];
    if (d.type === 'boolean') {
      opts.forEach((o) => {
        o.classList.add('locked');
        const val = o.dataset.bool === 'true';
        if (val === !!d.answer) o.classList.add('right');
        else if (boolPick === val) o.classList.add('wrong');
      });
    } else if (d.type === 'choice' || d.type === 'multi') {
      const want = new Set([].concat(d.answer));
      opts.forEach((o, i) => {
        o.classList.add('locked');
        o.classList.remove('sel');
        if (want.has(i)) o.classList.add('right');
        else if (picked.has(i)) o.classList.add('wrong');
      });
    } else if (d.type === 'input') {
      $('textIn').disabled = true;
      $('textIn').classList.add(correct ? 'right' : 'wrong');
    }

    const answerText = expected(d);
    const v = $('verdict');
    v.className = 'verdict ' + (correct ? 'ok' : 'bad');
    v.hidden = false;
    v.innerHTML =
      `<div class="v-head">${correct ? '✓ Correct' : '✗ Not quite'}</div>` +
      (correct || !answerText ? '' : `<p><b>Answer:</b> <code>${esc(answerText)}</code></p>`) +
      (d.explain ? `<p>${md(d.explain)}</p>` : '') +
      (note ? `<div class="ran">${esc(note)}</div>` : '');

    $('checkBtn').hidden = true;
    $('nextBtn').hidden = false;
    $('nextBtn').textContent = idx === session.length - 1 ? 'See results →' : 'Next →';
    $('nextBtn').focus();
  }

  function expected(d) {
    if (d.type === 'fill' || d.type === 'input') return (d.accept || [d.answer])[0];
    if (d.type === 'boolean') return d.answer ? 'True' : 'False';
    const want = [].concat(d.answer);
    return want.map((i) => (i + 1) + ') ' + String(d.options[i]).replace(/`/g, '')).join('   ');
  }

  $('checkBtn').onclick = onCheck;
  $('nextBtn').onclick = () => {
    if (idx === session.length - 1) return finishSession();
    idx++;
    renderQuestion();
    window.scrollTo(0, 0);
  };
  $('quitBtn').onclick = () => { renderHome(); show('home'); };

  /* ── results ────────────────────────────────────────────────────── */
  function finishSession() {
    progress.sessions++;
    save();
    const pct = Math.round((score / session.length) * 100);
    $('resultRing').style.setProperty('--pct', pct + '%');
    $('resultPct').textContent = pct + '%';
    $('resultTitle').textContent =
      pct === 100 ? 'Flawless.' : pct >= 80 ? 'Strong run.' : pct >= 50 ? 'Getting there.' : 'Worth another pass.';
    $('resultLine').textContent =
      `${score} of ${session.length} correct · ${session.label}`;

    $('missList').innerHTML = misses.length
      ? '<h3 style="margin:8px 0 4px;font-size:15px">What slipped</h3>' + misses.map((d) => `
        <div class="miss-item">
          <div class="mi-top"><span class="chip level">${d.level}</span><span class="chip topic">${esc(d.topic || '')}</span></div>
          <div>${md(d.q)}</div>
          ${d.code ? `<pre>${RakuHL.highlight(d.code)}</pre>` : ''}
          <p class="fix"><b>Answer:</b> <code>${esc(expected(d))}</code> — ${md(d.explain || '')}</p>
        </div>`).join('')
      : '';

    $('reviewBtn').hidden = !misses.length;
    show('results');
  }

  $('againBtn').onclick = () => startSession(session.pool || DRILLS.slice(), session.label);
  $('reviewBtn').onclick = () => startSession(misses.slice(), 'Review');
  $('homeBtn').onclick = () => { renderHome(); show('home'); };

  /* ── playground ─────────────────────────────────────────────────── */
  $('playBtn').onclick = () => {
    const pg = $('playground');
    pg.hidden = !pg.hidden;
    $('playBtn').textContent = pg.hidden ? '▶ Playground' : '▼ Playground';
    if (!pg.hidden) { Engine.init(); pg.scrollIntoView({ behavior: 'smooth', block: 'nearest' }); }
  };
  $('pgReset').onclick = () => { $('pgSrc').value = playSource(session[idx]); };
  $('pgStop').onclick = () => Engine.cancel();
  $('pgRun').onclick = runPlayground;
  $('pgSrc').addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && (e.metaKey || e.ctrlKey)) { e.preventDefault(); runPlayground(); }
    if (e.key === 'Tab') {
      e.preventDefault();
      const t = e.target, s = t.selectionStart;
      t.value = t.value.slice(0, s) + '  ' + t.value.slice(t.selectionEnd);
      t.selectionStart = t.selectionEnd = s + 2;
    }
  });

  async function runPlayground() {
    const out = $('pgOut');
    out.textContent = '';
    $('pgRun').disabled = true;
    $('pgStop').hidden = false;
    const res = await Engine.run($('pgSrc').value, {
      timeoutMs: 15000,
      onOut: (text, cls) => {
        const s = document.createElement('span');
        if (cls) s.className = cls;
        s.textContent = text;
        out.appendChild(s);
        out.scrollTop = out.scrollHeight;
      },
    });
    $('pgRun').disabled = false;
    $('pgStop').hidden = true;
    const meta = document.createElement('div');
    meta.className = 'meta';
    meta.textContent = res.ok
      ? `— exit ${res.rc} · ${res.ms} ms`
      : `— ${res.error}`;
    if (!res.ok) meta.classList.add('err');
    out.appendChild(meta);
    if (!out.textContent.trim()) out.innerHTML = '<span class="muted">(no output)</span>';
  }

  /* ── engine status chip ─────────────────────────────────────────── */
  Engine.onStatus((st, ver, err) => {
    const chip = $('engineChip');
    chip.className = 'chip engine ' + st;
    $('engineText').textContent =
      st === 'ready' ? (ver ? 'Raku++ ' + ver : 'engine ready')
        : st === 'busy' ? 'running…'
          : st === 'error' ? 'engine off'
            : 'engine…';
    chip.title = st === 'error' ? err : 'Raku.js — the Raku++ interpreter in WebAssembly';
  });

  /* ── keyboard ───────────────────────────────────────────────────── */
  document.addEventListener('keydown', (e) => {
    if ($('drill').hidden) return;
    const tag = document.activeElement && document.activeElement.tagName;
    if (tag === 'INPUT' || tag === 'TEXTAREA') return;
    if (e.key === 'Enter') {
      e.preventDefault();
      answered ? $('nextBtn').click() : onCheck();
      return;
    }
    if (/^[1-9]$/.test(e.key) && !answered) {
      const opts = $('answerArea').querySelectorAll('.opt');
      const b = opts[+e.key - 1];
      if (b) { e.preventDefault(); b.click(); }
    }
  });

  /* ── go ─────────────────────────────────────────────────────────── */
  initTheme();
  renderHome();
  show('home');
  Engine.init();   // start loading the 5.6 MB wasm right away
})();
