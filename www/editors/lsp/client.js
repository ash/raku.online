// client.js — a language-server client for a plain <textarea> editor.
//
// The pages that use it (/play/ and /editors/lsp/) have the same kind of
// editor: a transparent, non-wrapping, monospaced textarea over a coloured
// <pre>. This adds what VS Code would: mistakes underlined, a card on hover,
// a completion list, and go to definition. The server is `rakupp --lsp`
// compiled to WebAssembly, in its own worker (worker.js beside this file), so a
// running program elsewhere on the page never waits for it and it never waits
// for a running program.
//
//   const lsp = RakuLsp.attach({ textarea, workerUrl, ... });
//   lsp.changed();          // call after every edit the page makes itself
//
// Options, all but the first two optional:
//   textarea, workerUrl
//   uri            the document's name in the protocol ('file:///main.raku')
//   lazy           start the server on first focus or edit, not at once
//   onMessage(dir, msg, body, seq, method)   every message, 'out' or 'in'
//   onServerTime(seq, ms)                    how long the server took
//   onDiagnostics(list)
//   onStatus(state, text)   state: 'loading' | 'ready' | 'error' | 'off'
//
// Edits are sent as one didChange after a pause in typing. While a check is
// running no other is sent: edits made meanwhile go in the next one. And a
// file that takes the server a while to check (a 2,000-line interpreter) waits
// for a longer pause, so typing in it stays smooth.

(function () {
'use strict';

const QUICK_PAUSE = 250;    // ms of no typing before a check
const SLOW_PAUSE = 1000;    // ... when the last check took longer than SLOW_CHECK
const SLOW_CHECK = 150;

const esc = s => s.replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

const CSS = `
.rl-diag { position: absolute; inset: 0; margin: 0; border: 0; overflow: hidden; pointer-events: none;
  color: transparent !important; background: transparent !important; white-space: pre; box-sizing: border-box; }
.rl-diag .e, .rl-diag .w, .rl-diag .i {
  text-decoration-line: underline; text-decoration-style: wavy;
  text-decoration-thickness: 1.5px; text-decoration-skip-ink: none; text-underline-offset: 3px; }
.rl-diag .e { text-decoration-color: #e5484d; }
.rl-diag .w { text-decoration-color: #d39e00; }
.rl-diag .i { text-decoration-color: #3e8ed0; }
.rl-diag .flash { background: rgba(255, 200, 0, .35); border-radius: 2px; }
.rl-tip, .rl-complete {
  position: absolute; z-index: 20; color: var(--fg, var(--ink, #1c1e24));
  background: var(--card-bg, var(--panel, #fff));
  border: 1px solid var(--border, #d0d4dc); border-radius: 6px; box-shadow: 0 6px 24px rgba(0,0,0,.18);
  font: 13px/1.45 system-ui, -apple-system, sans-serif; text-align: left; }
.rl-tip[hidden], .rl-complete[hidden] { display: none; }
.rl-tip { max-width: min(30rem, calc(100% - 8px)); max-height: 16rem; overflow: auto; padding: .45rem .7rem; }
.rl-tip p { margin: .3rem 0; }
.rl-tip .rl-problem { display: flex; gap: .4rem; margin: .1rem 0 .3rem; }
.rl-tip .rl-problem + :not(.rl-problem) { border-top: 1px solid var(--border, #d0d4dc); padding-top: .35rem; }
.rl-tip .rl-sev { font-weight: 700; }
.rl-tip .rl-sev.e { color: #e5484d; }
.rl-tip .rl-sev.w { color: #d39e00; }
.rl-tip pre, .rl-cdoc pre { margin: .3rem 0; padding: .35rem .5rem; background: var(--code-bg, rgba(127,127,127,.12));
  border-radius: 4px; white-space: pre-wrap; font: 12px/1.4 ui-monospace, Menlo, monospace; }
.rl-tip code, .rl-cdoc code { font: 12px ui-monospace, Menlo, monospace; background: var(--code-bg, rgba(127,127,127,.12));
  padding: 0 .25em; border-radius: 3px; }
.rl-tip pre code, .rl-cdoc pre code { background: none; padding: 0; }
.rl-tip hr { border: 0; border-top: 1px solid var(--border, #d0d4dc); margin: .4rem 0; }
.rl-complete { display: flex; flex-direction: column; overflow: hidden; width: min(27rem, calc(100% - 8px)); }
.rl-complete ul { list-style: none; margin: 0; padding: .2rem 0; max-height: 11rem; overflow-y: auto; }
.rl-complete li { display: flex; gap: .5rem; align-items: baseline; padding: .12rem .55rem; cursor: pointer;
  white-space: nowrap; font: 12px/1.5 ui-monospace, Menlo, monospace; }
.rl-complete li.sel { background: rgba(80, 140, 255, .18); }
.rl-complete .kind { flex: none; width: 1.2rem; text-align: center; font-size: 11px; opacity: .65; }
.rl-complete .lbl { flex: 1; overflow: hidden; text-overflow: ellipsis; }
.rl-complete .lbl b { color: var(--accent, #c8402b); font-weight: 600; }
.rl-complete .det { opacity: .6; font-size: 11px; overflow: hidden; text-overflow: ellipsis; max-width: 12rem; }
.rl-cdoc { border-top: 1px solid var(--border, #d0d4dc); padding: .3rem .6rem; max-height: 7rem; overflow: auto; }
.rl-cdoc:empty { display: none; }
.rl-cdoc p { margin: .25rem 0; }
`;
let cssAdded = false;
function addCss() {
  if (cssAdded) return;
  cssAdded = true;
  const st = document.createElement('style');
  st.textContent = CSS;
  document.head.appendChild(st);
}

// ---------------------------------------------------------------------------
// Positions. LSP counts lines from 0 and characters in UTF-16 code units,
// which is how a JavaScript string indexes: a position is a line number plus
// an index into that line.
// ---------------------------------------------------------------------------
function posToIndex(text, p) {
  let i = 0;
  for (let l = 0; l < p.line; l++) {
    const nl = text.indexOf('\n', i);
    if (nl < 0) return text.length;
    i = nl + 1;
  }
  const end = text.indexOf('\n', i);
  return Math.min(i + p.character, end < 0 ? text.length : end);
}
function indexToPos(text, idx) {
  const before = text.slice(0, idx);
  const line = (before.match(/\n/g) || []).length;
  return { line, character: idx - (before.lastIndexOf('\n') + 1) };
}
// Visual column <-> index within a line (a column is one code point).
function colToIndex(line, col) {
  let i = 0, c = 0;
  while (i < line.length && c < col) { i += line.codePointAt(i) > 0xffff ? 2 : 1; c++; }
  return i;
}
function indexToCol(line, idx) { return [...line.slice(0, idx)].length; }
function inRange(p, r) {
  const after = (a, b) => a.line > b.line || (a.line === b.line && a.character >= b.character);
  return after(p, r.start) && !after(p, r.end);
}

// Markdown, as much as the server writes: fenced code, inline code, bold,
// italics, rules and paragraphs.
function markdown(md) {
  const out = [];
  md.split(/```[a-z0-9]*\n([\s\S]*?)```/).forEach((part, i) => {
    if (i % 2) { out.push(`<pre><code>${esc(part.replace(/\n$/, ''))}</code></pre>`); return; }
    for (const para of part.split(/\n\s*\n/)) {
      const t = para.trim();
      if (!t) continue;
      if (/^-{3,}$/.test(t)) { out.push('<hr>'); continue; }
      out.push('<p>' + esc(t)
        .replace(/`([^`]+)`/g, '<code>$1</code>')
        .replace(/\*\*([^*]+)\*\*/g, '<b>$1</b>')
        .replace(/\*([^*\s][^*]*)\*/g, '<i>$1</i>')
        .replace(/\n/g, '<br>') + '</p>');
    }
  });
  return out.join('');
}
function markup(c) {
  if (!c) return '';
  if (typeof c === 'string') return markdown(c);
  if (Array.isArray(c)) return c.map(markup).join('');
  return c.kind === 'markdown' ? markdown(c.value) : `<p>${esc(c.value)}</p>`;
}

const KIND = { 2: ['m', 'method'], 3: ['ƒ', 'function'], 4: ['ƒ', 'constructor'], 5: ['·', 'field'],
  6: ['$', 'variable'], 7: ['C', 'class'], 8: ['R', 'role'], 9: ['M', 'module'], 10: ['.', 'property'],
  13: ['E', 'enum'], 14: ['k', 'keyword'], 20: ['e', 'enum member'], 21: ['c', 'constant'],
  22: ['S', 'struct'], 25: ['T', 'type'] };

function attach(opts) {
  addCss();
  const src = opts.textarea;
  const box = src.parentElement;                 // positioned; the overlays go in here
  const URI = opts.uri || 'file:///main.raku';
  const cb = name => opts[name] || (() => {});
  const onMessage = cb('onMessage'), onServerTime = cb('onServerTime');
  const onDiagnostics = cb('onDiagnostics'), onStatus = cb('onStatus');

  // ---- overlays ----
  const diag = document.createElement('pre');
  diag.className = 'rl-diag';
  diag.setAttribute('aria-hidden', 'true');
  box.insertBefore(diag, src);                   // behind the transparent textarea
  const tip = document.createElement('div');
  tip.className = 'rl-tip';
  tip.hidden = true;
  const complete = document.createElement('div');
  complete.className = 'rl-complete';
  complete.hidden = true;
  complete.innerHTML = '<ul></ul><div class="rl-cdoc"></div>';
  const clist = complete.firstChild, cdoc = complete.lastChild;
  box.append(tip, complete);

  // The underline layer copies the textarea's metrics, so its text sits
  // exactly under the textarea's.
  let cw = 8, lh = 20, padL = 12, padT = 12;
  function measure() {
    const cs = getComputedStyle(src);
    for (const p of ['fontFamily', 'fontSize', 'fontWeight', 'lineHeight', 'letterSpacing', 'tabSize',
                     'paddingTop', 'paddingRight', 'paddingBottom', 'paddingLeft'])
      diag.style[p] = cs[p];
    const probe = document.createElement('span');
    probe.textContent = 'M'.repeat(100);
    probe.style.cssText = 'position:absolute;visibility:hidden;white-space:pre';
    diag.appendChild(probe);
    cw = probe.getBoundingClientRect().width / 100 || cw;
    probe.remove();
    lh = parseFloat(cs.lineHeight) || parseFloat(cs.fontSize) * 1.5;
    padL = parseFloat(cs.paddingLeft);
    padT = parseFloat(cs.paddingTop);
  }
  function pointToPos(clientX, clientY) {
    const r = src.getBoundingClientRect();
    const x = clientX - r.left - padL + src.scrollLeft;
    const y = clientY - r.top - padT + src.scrollTop;
    const lines = src.value.split('\n');
    const line = Math.floor(y / lh);
    if (line < 0 || line >= lines.length || x < 0) return null;
    const col = Math.floor(x / cw);
    const text = lines[line];
    if (col >= [...text].length) return null;    // past the end of the line
    return { line, character: colToIndex(text, col) };
  }
  function posToPoint(p) {
    const line = src.value.split('\n')[p.line] || '';
    return {
      x: src.offsetLeft + padL + indexToCol(line, p.character) * cw - src.scrollLeft,
      y: src.offsetTop + padT + p.line * lh - src.scrollTop,
    };
  }
  function place(el, p, gap) {
    const pt = posToPoint(p);
    el.hidden = false;
    const below = pt.y + lh + gap;
    const room = box.clientHeight;
    el.style.top = (below + el.offsetHeight > room ? Math.max(gap, pt.y - el.offsetHeight - gap) : below) + 'px';
    el.style.left = Math.max(gap, Math.min(pt.x, box.clientWidth - el.offsetWidth - gap)) + 'px';
  }

  // ---- underlines ----
  let diagnostics = [];
  function paintDiagnostics(flash) {
    const text = src.value;
    const marks = diagnostics.map(d => {
      const a = posToIndex(text, d.range.start);
      let b = posToIndex(text, d.range.end);
      if (b <= a) b = Math.min(a + 1, text.length);
      return { a, b, cls: d.severity === 1 ? 'e' : d.severity === 2 ? 'w' : 'i' };
    });
    if (flash) marks.push({ a: flash.a, b: Math.max(flash.b, flash.a + 1), cls: 'flash' });
    marks.sort((m, n) => m.a - n.a);
    let html = '', at = 0;
    for (const m of marks) {
      const a = Math.max(m.a, at);
      if (a >= m.b) continue;
      html += esc(text.slice(at, a)) + `<span class="${m.cls}">${esc(text.slice(a, m.b))}</span>`;
      at = m.b;
    }
    diag.innerHTML = html + esc(text.slice(at)) + '\n';
    syncScroll();
  }
  function syncScroll() {
    diag.scrollTop = src.scrollTop;
    diag.scrollLeft = src.scrollLeft;
  }
  src.addEventListener('scroll', () => { syncScroll(); hideTip(); closeCompletion(); });

  // ---- the server ----
  let worker = null, ready = false, enabled = true, nextId = 1, version = 1;
  let pending = new Map();      // request id -> { method, resolve }
  let serverCaps = {};
  let seqOut = 0;
  let hlSeq = 0;
  const hlWaiting = new Map();  // highlight seq -> resolve

  function start() {
    if (worker || !enabled) return;
    ready = false;
    pending = new Map();
    nextId = 1;
    onStatus('loading', 'loading the server…');
    worker = new Worker(opts.workerUrl);
    worker.onmessage = onWorker;
    worker.onerror = e => onStatus('error', 'the server failed to load: ' + (e.message || 'unknown error'));
  }
  function stop() {
    if (worker) worker.terminate();
    worker = null;
    ready = false;
    inFlight = 0;
    sent = null;
    for (const p of pending.values()) p.resolve(null);
    pending = new Map();
    diagnostics = [];
    paintDiagnostics();
    onDiagnostics(diagnostics);
    hideTip();
    closeCompletion();
  }
  function onWorker(e) {
    const d = e.data;
    if (d.type === 'ready') {
      ready = true;
      onStatus('ready', `rakupp ${d.version}, WebAssembly`);
      handshake();
    } else if (d.type === 'loaderror' || d.type === 'servererror') {
      onStatus('error', 'server error: ' + d.message);
    } else if (d.type === 'lsp') {
      onServerTime(d.for, d.ms);
      for (const body of d.bodies) receive(body);
      if (d.for === checkSeq) checkDone(d.ms);
    } else if (d.type === 'highlight') {
      const resolve = hlWaiting.get(d.seq);
      hlWaiting.delete(d.seq);
      if (resolve) resolve(d.html);
    }
  }
  function send(msg) {
    const body = JSON.stringify(msg);
    const seq = ++seqOut;
    onMessage('out', msg, body, seq, msg.method);
    worker.postMessage({ type: 'lsp', body, seq });
    return seq;
  }
  function request(method, params) {
    if (!ready) return Promise.resolve(null);
    const id = nextId++;
    return new Promise(resolve => {
      pending.set(id, { method, resolve });
      send({ jsonrpc: '2.0', id, method, params });
    });
  }
  function notify(method, params) {
    return ready ? send({ jsonrpc: '2.0', method, params }) : 0;
  }
  function receive(body) {
    const msg = JSON.parse(body);
    if (msg.id !== undefined && !msg.method) {
      const p = pending.get(msg.id);
      pending.delete(msg.id);
      onMessage('in', msg, body, 0, p ? p.method : '?');
      if (p) p.resolve(msg.error ? null : msg.result);
      return;
    }
    onMessage('in', msg, body, 0, msg.method);
    if (msg.method === 'textDocument/publishDiagnostics' && msg.params.uri === URI) {
      diagnostics = msg.params.diagnostics || [];
      paintDiagnostics();
      onDiagnostics(diagnostics);
    }
  }
  async function handshake() {
    const result = await request('initialize', {
      processId: null,
      clientInfo: { name: 'raku.online' },
      rootUri: null,
      capabilities: {
        textDocument: {
          hover: { contentFormat: ['markdown', 'plaintext'] },
          completion: { completionItem: { documentationFormat: ['markdown', 'plaintext'] } },
          publishDiagnostics: {},
        },
      },
    });
    serverCaps = (result && result.capabilities) || {};
    notify('initialized', {});
    version = 1;
    sent = src.value;
    checkSeq = notify('textDocument/didOpen', {
      textDocument: { uri: URI, languageId: 'raku', version, text: sent },
    });
    inFlight = performance.now();
  }

  // ---- checking: one at a time, newest text wins ----
  // `sent` is the text the server has. Comparing with it, rather than keeping
  // a flag that edits set, means the order of the page's input handlers and
  // ours cannot matter.
  let sent = null, timer = null, inFlight = 0, checkSeq = 0, pause = QUICK_PAUSE;
  function changed() {
    paintDiagnostics();
    // Not started yet (a lazy client starts on focus), or starting: the
    // handshake opens the document with whatever text is there by then.
    if (!enabled || !ready) return;
    clearTimeout(timer);
    timer = setTimeout(sendChange, pause);
  }
  function sendText() {
    clearTimeout(timer);
    sent = src.value;
    checkSeq = notify('textDocument/didChange', {
      textDocument: { uri: URI, version: ++version },
      contentChanges: [{ text: sent }],
    });
    inFlight = performance.now();
  }
  function sendChange() {
    // A running check sends the rest when it ends.
    if (ready && sent !== null && !inFlight && src.value !== sent) sendText();
  }
  function checkDone(ms) {
    inFlight = 0;
    pause = ms > SLOW_CHECK ? SLOW_PAUSE : QUICK_PAUSE;
    if (src.value !== sent) { clearTimeout(timer); timer = setTimeout(sendChange, pause); }
  }
  // A request must see the current text: send any edit now, even mid-check
  // (the worker answers in order, so the request still comes after it).
  function flush() {
    if (ready && sent !== null && src.value !== sent) sendText();
  }
  const docPosition = p => ({ textDocument: { uri: URI }, position: p });

  // ---- hover: the server's card, with any problem at that spot on top ----
  let hoverTimer = null, hoverSeq = 0, hoverAt = null, tipRange = null;
  src.addEventListener('mousemove', e => {
    const p = pointToPos(e.clientX, e.clientY);
    if (p && hoverAt && p.line === hoverAt.line && p.character === hoverAt.character) return;
    clearTimeout(hoverTimer);
    if (!tip.hidden && tipRange && !(p && inRange(p, tipRange))) hideTip();
    if (!p || !ready || !complete.hidden) return;
    hoverTimer = setTimeout(() => doHover(p), 400);
  });
  src.addEventListener('mouseleave', () => {
    clearTimeout(hoverTimer);
    setTimeout(() => { if (!tip.matches(':hover')) hideTip(); }, 200);
  });
  tip.addEventListener('mouseleave', hideTip);
  async function doHover(p) {
    hoverAt = p;
    flush();
    const seq = ++hoverSeq;
    const res = await request('textDocument/hover', docPosition(p));
    if (seq !== hoverSeq) return;
    const here = diagnostics.filter(d => inRange(p, d.range) ||
      (d.range.start.line === p.line && d.range.start.character === p.character));
    if (!here.length && !(res && res.contents)) return;
    tip.innerHTML = here.map(d => {
      const s = d.severity === 1 ? 'e' : 'w';
      return `<div class="rl-problem"><span class="rl-sev ${s}">${s === 'e' ? '●' : '▲'}</span><span>${esc(d.message)}</span></div>`;
    }).join('') + (res && res.contents ? markup(res.contents) : '');
    tipRange = (res && res.range) || (here[0] && here[0].range) ||
      { start: p, end: { line: p.line, character: p.character + 1 } };
    place(tip, tipRange.start, 4);
  }
  function hideTip() { tip.hidden = true; tipRange = null; hoverAt = null; }

  // ---- completion ----
  let comp = null, compSeq = 0;
  async function triggerCompletion() {
    flush();
    hideTip();
    const caret = src.selectionStart;
    const seq = ++compSeq;
    const res = await request('textDocument/completion', docPosition(indexToPos(src.value, caret)));
    if (seq !== compSeq || src.selectionStart < caret) return;
    const items = Array.isArray(res) ? res : (res && res.items) || [];
    if (!items.length) { closeCompletion(); return; }
    const first = items.find(i => i.textEdit);
    const start = first ? posToIndex(src.value, first.textEdit.range.start) : wordStart(caret);
    items.sort((a, b) => (a.sortText || a.label).localeCompare(b.sortText || b.label));
    comp = { items, start, sel: 0, shown: [], typed: '' };
    refilter();
  }
  function wordStart(i) {
    const t = src.value;
    while (i > 0 && /[\w\-'$@%&]/.test(t[i - 1])) i--;
    return i;
  }
  function refilter() {
    if (!comp) return;
    const caret = src.selectionStart;
    if (caret < comp.start) { closeCompletion(); return; }
    const typed = src.value.slice(comp.start, caret).toLowerCase();
    const pre = [], sub = [];
    for (const it of comp.items) {
      const f = (it.filterText || it.label).toLowerCase();
      if (f.startsWith(typed)) pre.push(it);
      else if (typed.length > 1 && f.includes(typed)) sub.push(it);
    }
    comp.shown = pre.concat(sub).slice(0, 200);
    comp.typed = typed;
    const only = comp.shown.length === 1 && (comp.shown[0].filterText || comp.shown[0].label).toLowerCase() === typed;
    if (!comp.shown.length || only) { closeCompletion(); return; }
    comp.sel = Math.min(comp.sel, comp.shown.length - 1);
    renderCompletion();
  }
  function renderCompletion() {
    clist.innerHTML = '';
    comp.shown.forEach((it, i) => {
      const li = document.createElement('li');
      if (i === comp.sel) li.className = 'sel';
      const [sym, name] = KIND[it.kind] || ['·', 'text'];
      const lab = it.label, n = comp.typed.length;
      const hit = n && lab.toLowerCase().startsWith(comp.typed)
        ? `<b>${esc(lab.slice(0, n))}</b>${esc(lab.slice(n))}` : esc(lab);
      li.innerHTML = `<span class="kind" title="${name}">${sym}</span><span class="lbl">${hit}</span>` +
        (it.detail ? `<span class="det">${esc(it.detail)}</span>` : '');
      li.addEventListener('mousedown', e => { e.preventDefault(); comp.sel = i; accept(); });
      clist.appendChild(li);
    });
    const sel = comp.shown[comp.sel];
    cdoc.innerHTML = sel && sel.documentation ? markup(sel.documentation) : '';
    place(complete, indexToPos(src.value, comp.start), 2);
    const selLi = clist.children[comp.sel];
    if (selLi) selLi.scrollIntoView({ block: 'nearest' });
  }
  function accept() {
    const it = comp.shown[comp.sel];
    const text = it.textEdit ? it.textEdit.newText : (it.insertText || it.label);
    const from = comp.start;
    closeCompletion();
    src.focus();
    src.setSelectionRange(from, src.selectionStart);
    // insertText keeps the browser's undo history and fires the page's input handler.
    if (!document.execCommand('insertText', false, text)) {
      src.setRangeText(text, from, src.selectionEnd, 'end');
      src.dispatchEvent(new Event('input', { bubbles: true }));
    }
  }
  function closeCompletion() { comp = null; complete.hidden = true; }

  // ---- go to definition ----
  function selectRange(range) {
    const text = src.value;
    const a = posToIndex(text, range.start), b = posToIndex(text, range.end);
    src.focus();
    src.setSelectionRange(a, b);
    const y = range.start.line * lh;
    if (y < src.scrollTop || y > src.scrollTop + src.clientHeight - 2 * lh)
      src.scrollTop = Math.max(0, y - src.clientHeight / 3);
    paintDiagnostics({ a, b });
    setTimeout(() => paintDiagnostics(), 900);
  }
  async function goToDefinition(p) {
    flush();
    hideTip();
    const res = await request('textDocument/definition', docPosition(p));
    const loc = Array.isArray(res) ? res[0] : res;
    if (loc && loc.range) selectRange(loc.range);
  }
  src.addEventListener('mousedown', e => {
    if (!(e.metaKey || e.ctrlKey) || !ready) return;
    const p = pointToPos(e.clientX, e.clientY);
    if (!p) return;
    e.preventDefault();
    goToDefinition(p);
  });

  // ---- typing ----
  // A lazy client wakes at the first sign of a person at the editor. Focus
  // alone is not enough: a window without focus gets no focus events.
  const wake = () => { if (enabled && !worker) start(); };
  for (const ev of ['focus', 'pointerdown', 'keydown', 'input']) src.addEventListener(ev, wake);
  src.addEventListener('input', e => {
    hideTip();
    if (!ready) return;
    const ch = e.data && e.data.slice(-1);
    const triggers = (serverCaps.completionProvider && serverCaps.completionProvider.triggerCharacters) || [];
    if (ch && triggers.includes(ch)) { triggerCompletion(); return; }
    if (comp) { refilter(); return; }
    // Like VS Code's quick suggestions: two letters of a word open the list.
    if (ch && /\w/.test(ch) && e.inputType === 'insertText') {
      const word = src.value.slice(0, src.selectionStart).match(/[\w-]+$/);
      if (word && word[0].length === 2) triggerCompletion();
    }
  });
  // Capture on the editor box, so the list gets Enter, Tab and Escape before
  // the page's own handlers (new-line indent, Tab indent, Stop).
  box.addEventListener('keydown', e => {
    if (e.target !== src) return;
    if (comp && !complete.hidden) {
      const k = e.key;
      if (k === 'ArrowDown' || k === 'ArrowUp') {
        comp.sel = (comp.sel + (k === 'ArrowDown' ? 1 : comp.shown.length - 1)) % comp.shown.length;
        renderCompletion();
      } else if (k === 'Enter' || k === 'Tab') {
        accept();
      } else if (k === 'Escape') {
        closeCompletion();
      } else {
        return;
      }
      e.preventDefault();
      e.stopImmediatePropagation();
      return;
    }
    if (e.key === 'Escape' && !tip.hidden) { hideTip(); return; }
    if (!ready) return;
    if (e.key === ' ' && e.ctrlKey) {
      e.preventDefault(); e.stopImmediatePropagation(); triggerCompletion();
    } else if (e.key === 'F12') {
      e.preventDefault(); e.stopImmediatePropagation();
      goToDefinition(indexToPos(src.value, src.selectionStart));
    }
  }, true);
  src.addEventListener('click', () => { if (comp && src.selectionStart < comp.start) closeCompletion(); });
  src.addEventListener('blur', () => setTimeout(closeCompletion, 150));
  window.addEventListener('resize', measure);

  measure();
  paintDiagnostics();
  if (!opts.lazy) start();

  return {
    changed,
    setEnabled(on) {
      enabled = on;
      if (!on) { stop(); onStatus('off', 'off'); }
      else if (!opts.lazy || document.activeElement === src) start();
    },
    async restart() {
      if (ready) {
        flush();
        await request('shutdown', null);
        notify('exit', null);
      }
      await new Promise(r => setTimeout(r, 50));
      stop();
      start();
    },
    highlight(text) {
      if (!ready) return Promise.resolve(null);
      const seq = ++hlSeq;
      return new Promise(resolve => {
        hlWaiting.set(seq, resolve);
        worker.postMessage({ type: 'highlight', src: text, seq });
      });
    },
    selectRange,
    measure,
    get diagnostics() { return diagnostics; },
    get ready() { return ready; },
  };
}

window.RakuLsp = { attach };
})();
