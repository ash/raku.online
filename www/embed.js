// embed.js — drop the raku.online playground into any web page.
//
//   <script src="https://raku.online/embed.js"></script>
//
// Then any element that carries a `data-raku` attribute becomes a runnable Raku
// editor. Show code that turns editable-and-runnable:
//
//   <pre data-raku>say "Hello from an embedded editor!";</pre>
//
// …or an empty editor to type into:
//
//   <div data-raku data-run></div>
//
// Attributes (all optional):
//   data-run              run once as soon as the interpreter is ready
//   data-stdin="…"        preset standard input (and reveal the input box)
//   data-rows="N"         initial editor height in text rows (default: fit code)
//
// Multiple blocks per page share ONE WebAssembly interpreter (one download, one
// instance). Each editor lives in its own Shadow DOM, so the host page's CSS
// can't reach in and ours can't leak out — it looks the same on any site.
//
// The interpreter is Raku++ compiled to WebAssembly; nothing is sent anywhere,
// the program runs in the visitor's browser. See https://github.com/ash/raku.online
(function () {
  'use strict';

  // Where we were loaded from — every asset (worker, wasm) is fetched relative
  // to this, so the embed works from any host page.
  var script = document.currentScript
    || (function () { var s = document.getElementsByTagName('script'); return s[s.length - 1]; })();
  var BASE = new URL('.', script.src).href;         // e.g. https://raku.online/
  var VER = '?v=abc569f4';                            // cache tag, stamped by deploy.sh
  var SELECTOR = script.getAttribute('data-selector') || '[data-raku]';

  // ---- the shared interpreter worker -------------------------------------
  // Built from a Blob so it runs even when embed.js is served cross-origin
  // (a plain `new Worker('https://…')` is blocked; a Blob worker that
  // importScripts() the cross-origin engine is allowed). One worker serves
  // every block on the page; only one program runs at a time.
  function workerSource() {
    return [
      'var BASE=' + JSON.stringify(BASE) + ',V=' + JSON.stringify(VER) + ';',
      'importScripts(BASE+"rakujs.js"+V);',
      'var Module=null,inRun=false;',
      'function make(){return RakuJS({',
      '  locateFile:function(p){return BASE+p+V;},',
      '  print:function(t){if(inRun)postMessage({type:"out",text:t+"\\n",cls:""});else console.log(t);},',
      '  printErr:function(t){if(inRun)postMessage({type:"out",text:t+"\\n",cls:"err"});else console.warn(t);}',
      '}).then(function(m){Module=m;return m;});}',
      'var ready=make().then(function(m){postMessage({type:"ready",version:m.ccall("rakupp_version","string",[],[])});})',
      '  .catch(function(e){postMessage({type:"loaderror",message:String(e)});});',
      'onmessage=function(e){',
      '  if(e.data.type!=="run")return;',
      '  ready.then(function(){',
      '    if(!Module){postMessage({type:"loaderror",message:"not loaded"});return;}',
      '    postMessage({type:"start"});',
      '    var t0=performance.now(),rc;inRun=true;',
      '    try{rc=Module.ccall("rakupp_run","number",["string","string"],[e.data.src,e.data.stdin||""]);}',
      '    catch(err){Module=null;ready=make();inRun=false;',
      '      postMessage({type:"runerror",message:String(err),deep:(err instanceof RangeError)||/call stack/i.test(String(err))});return;}',
      '    inRun=false;',
      '    postMessage({type:"done",rc:rc,ms:Math.round(performance.now()-t0)});',
      '  });',
      '};'
    ].join('\n');
  }

  var worker = null, workerReady = false, current = null, queued = null;
  var RECURSION_MSG = 'Recursion too deep for the browser (a few hundred levels) — '
    + 'a WebAssembly stack limit, not a Raku one. Rewrite it iteratively, or run it natively.';

  function createWorker() {
    var url = URL.createObjectURL(new Blob([workerSource()], { type: 'application/javascript' }));
    worker = new Worker(url);
    workerReady = false;
    worker.onmessage = function (e) {
      var m = e.data, b = current;
      switch (m.type) {
        case 'ready': workerReady = true; if (queued) { var q = queued; queued = null; startRun(q); } break;
        case 'out': if (b) b.feed(m.text, m.cls); break;
        case 'done':
          if (b) { b.finish(m.rc, m.ms); }
          current = null; if (queued) { var n = queued; queued = null; startRun(n); }
          break;
        case 'runerror':
          if (b) { b.error(m.deep ? RECURSION_MSG : '[host error] ' + m.message); b.finish(1, 0); }
          current = null;
          // A crashed run left the module unknown; the worker already rebuilt it.
          if (queued) { var k = queued; queued = null; startRun(k); }
          break;
        case 'loaderror':
          if (b) { b.error('Could not load the interpreter — ' + m.message); b.finish(1, 0); }
          current = null;
          break;
      }
    };
    worker.onerror = function () {
      if (current) { current.error('[worker error]'); current.finish(1, 0); current = null; }
    };
  }
  function ensureWorker() { if (!worker) createWorker(); }
  function killWorker() {
    if (worker) { worker.terminate(); worker = null; workerReady = false; }
    current = null;
  }
  function startRun(block) {
    ensureWorker();
    current = block;
    block.starting();
    worker.postMessage({ type: 'run', src: block.getCode(), stdin: block.getStdin() });
  }
  // Public entry the blocks call. Serialize: if one is running, queue this one
  // (a newer request replaces an older queued one).
  function requestRun(block) {
    if (current === block) { stopRun(block); return; }   // clicking Run again = stop
    if (current) { queued = block; block.setStatus('queued…'); return; }
    startRun(block);
  }
  function stopRun(block) {
    if (current !== block && queued !== block) return;
    if (queued === block) { queued = null; block.reset(); return; }
    // The run lives in a synchronous ccall; the only way to stop it is to kill
    // the worker. A fresh one reloads lazily on the next run.
    killWorker();
    block.stopped();
  }

  // ---- one editor -------------------------------------------------------
  var STYLE = [
    ':host{all:initial;display:block;margin:1em 0;}',
    '*{box-sizing:border-box;}',
    '.wrap{--bg:#fbfbfc;--panel:#f1f2f4;--ink:#1b1d23;--muted:#5b616e;--accent:#d33682;',
    '  --accent2:#268bd2;--border:#d7dae0;',
    '  --mono:ui-monospace,"SF Mono",Menlo,Consolas,monospace;',
    '  border:1px solid var(--border);border-radius:8px;overflow:hidden;',
    '  background:var(--bg);color:var(--ink);',
    '  font:14px/1.5 system-ui,-apple-system,Segoe UI,Roboto,sans-serif;}',
    '@media (prefers-color-scheme:dark){.wrap{--bg:#1f2127;--panel:#2b2e37;--ink:#e6e6e6;',
    '  --muted:#9aa0ab;--border:#3a3f4b;}}',
    '.bar{display:flex;align-items:center;gap:8px;padding:6px 8px;background:var(--panel);',
    '  border-bottom:1px solid var(--border);}',
    '.bar .sp{flex:1;}',
    '.bar .st{color:var(--muted);font-size:12px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}',
    'button{font:inherit;color:var(--ink);background:var(--bg);border:1px solid var(--border);',
    '  border-radius:6px;padding:4px 10px;cursor:pointer;}',
    'button:hover{border-color:var(--muted);}',
    'button.run{background:var(--accent);color:#fff;border-color:transparent;font-weight:600;min-width:74px;}',
    'button.run.on{background:var(--bg);color:var(--accent);border-color:var(--accent);}',
    '.ed{position:relative;}',
    'pre.hl,textarea{margin:0;padding:10px 12px;border:0;font-family:var(--mono);font-size:13px;',
    '  line-height:1.5;tab-size:4;white-space:pre;overflow:auto;}',
    'pre.hl{position:absolute;inset:0;pointer-events:none;overflow:hidden;color:var(--ink);}',
    'textarea{position:relative;display:block;width:100%;resize:vertical;outline:0;',
    '  background:transparent;color:transparent;caret-color:var(--ink);min-height:2.5em;}',
    'textarea::selection{background:rgba(120,140,170,.35);}',
    '.io{border-top:1px solid var(--border);}',
    '.io .lbl{padding:3px 12px;font-size:10.5px;letter-spacing:.06em;text-transform:uppercase;',
    '  color:var(--muted);background:var(--panel);display:flex;align-items:center;}',
    '.io .lbl button{margin-left:auto;font-size:11px;padding:1px 8px;}',
    'textarea.in{color:var(--ink);min-height:2em;height:4em;}',
    'pre.out{margin:0;padding:10px 12px;font-family:var(--mono);font-size:12.5px;white-space:pre-wrap;',
    '  max-height:60vh;overflow:auto;}',
    'pre.out .err{color:var(--accent);}',
    'pre.out .meta{color:var(--muted);}',
    '.t-k{color:#0000ff;}.t-nb{color:#267f99;}.t-v{color:#001080;}.t-s{color:#a31515;}',
    '.t-m{color:#098658;}.t-c{color:#008000;}',
    '@media (prefers-color-scheme:dark){.t-k{color:#569cd6;}.t-nb{color:#4ec9b0;}.t-v{color:#9cdcfe;}',
    '  .t-s{color:#ce9178;}.t-m{color:#b5cea8;}.t-c{color:#6a9955;}}'
  ].join('');

  var esc = function (s) { return s.replace(/[&<>]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;' }[c]; }); };

  // Lightweight Raku tokenizer (same scheme as the full playground): instant,
  // approximate, good enough to give the editor structure.
  var KW = new Set(('my our has state sub method submethod multi proto if elsif else unless with without while until '
    + 'for loop given when default repeat return make take gather do class role grammar token rule regex enum subset '
    + 'use need require does but is start react whenever supply emit last next redo try and or not so andthen orelse '
    + 'BEGIN END self').split(' '));
  var NB = new Set(('Int UInt Str Num Rat Bool Array Hash List Seq Map Bag Set Pair Range Any Mu Cool Nil Whatever '
    + 'say print put note printf sprintf warn die map grep sort reverse join split first sum min max elems keys values '
    + 'pairs push pop shift unshift chars uc lc tc trim lines words comb get prompt slurp True False Inf NaN pi tau e now').split(' '));
  var RE = new RegExp([
    /(#[^\n]*)/.source,
    /("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*')/.source,
    /(\b0[xob][0-9a-fA-F_]+|\b\d[\d_]*(?:\.\d[\d_]*)?(?:[eE][+-]?\d+)?)/.source,
    /([$@%&][.!^*?=:~<]?(?:[A-Za-z_][\w'-]*|\d+|[/!_]))/.source,
    /([A-Za-z_][\w'-]*)/.source
  ].join('|'), 'g');
  function highlight(code) {
    var out = '', last = 0, m; RE.lastIndex = 0;
    while ((m = RE.exec(code))) {
      out += esc(code.slice(last, m.index));
      var t = m[0];
      var cls = m[1] !== undefined ? 'c' : m[2] !== undefined ? 's' : m[3] !== undefined ? 'm'
        : m[4] !== undefined ? 'v' : KW.has(t) ? 'k' : NB.has(t) ? 'nb' : '';
      out += cls ? '<span class="t-' + cls + '">' + esc(t) + '</span>' : esc(t);
      last = m.index + t.length;
    }
    return out + esc(code.slice(last));
  }

  // Does the program read standard input? Then reveal the input box up front.
  function readsStdin(code) { return /\$\*IN\b|(?:^|[^.\w])(?:get|prompt|lines)\b/.test(code); }

  var ANSI = /\x1b\[[0-9;?]*[A-Za-z]/g;

  function Block(srcEl, opts) {
    var code = opts.code != null ? opts.code : srcEl.textContent.replace(/^\n/, '').replace(/\s+$/, '');
    var host = document.createElement('div');
    host.className = 'rakupp-embed';
    if (srcEl.parentNode) srcEl.parentNode.replaceChild(host, srcEl);
    else document.body.appendChild(host);
    var root = host.attachShadow({ mode: 'open' });
    var st = document.createElement('style'); st.textContent = STYLE; root.appendChild(st);

    var wrap = document.createElement('div'); wrap.className = 'wrap'; root.appendChild(wrap);
    wrap.innerHTML =
      '<div class="bar"><button class="run">▶ Run</button><span class="sp"></span><span class="st"></span></div>'
      + '<div class="ed"><pre class="hl"></pre><textarea spellcheck="false" autocomplete="off" '
      + 'autocapitalize="off" wrap="off"></textarea></div>'
      + '<div class="io in-wrap" hidden><div class="lbl">Standard input</div>'
      + '<textarea class="in" spellcheck="false" autocomplete="off" wrap="off"></textarea></div>'
      + '<div class="io out-wrap" hidden><div class="lbl">Output<button class="copy">Copy</button></div>'
      + '<pre class="out"></pre></div>';

    var runBtn = wrap.querySelector('.run');
    var stEl = wrap.querySelector('.st');
    var ta = wrap.querySelector('textarea:not(.in)');
    var hl = wrap.querySelector('.hl');
    var inWrap = wrap.querySelector('.in-wrap');
    var inTa = wrap.querySelector('.in');
    var outWrap = wrap.querySelector('.out-wrap');
    var outEl = wrap.querySelector('.out');
    var copyBtn = wrap.querySelector('.copy');

    var self = this;
    ta.value = code;
    if (opts.rows) ta.style.height = (opts.rows * 1.5 + 1.3) + 'em';
    else { var n = Math.max(1, code.split('\n').length); ta.style.height = (n * 1.5 + 1.3) + 'em'; }
    function paint() { hl.innerHTML = highlight(ta.value); hl.scrollTop = ta.scrollTop; hl.scrollLeft = ta.scrollLeft; }
    paint();
    ta.addEventListener('input', paint);
    ta.addEventListener('scroll', function () { hl.scrollTop = ta.scrollTop; hl.scrollLeft = ta.scrollLeft; });
    // Tab inserts spaces; Ctrl/Cmd-Enter runs.
    ta.addEventListener('keydown', function (e) {
      if (e.key === 'Tab') { e.preventDefault(); document.execCommand('insertText', false, '    '); }
      else if ((e.metaKey || e.ctrlKey) && e.key === 'Enter') { e.preventDefault(); requestRun(self); }
    });

    if (opts.stdin != null) { inTa.value = opts.stdin; inWrap.hidden = false; }
    else if (readsStdin(code)) inWrap.hidden = false;

    runBtn.addEventListener('click', function () { requestRun(self); });
    copyBtn.addEventListener('click', function () {
      var text = (self._screen || []).filter(function (p) { return p[1] !== 'meta'; })
        .map(function (p) { return p[0]; }).join('');
      if (navigator.clipboard) navigator.clipboard.writeText(text).then(flash, flash); else flash();
      function flash() { copyBtn.textContent = 'Copied'; setTimeout(function () { copyBtn.textContent = 'Copy'; }, 1200); }
    });

    // ---- output screen (coalesced render, minimal ANSI screen-clear) ----
    this._screen = []; var chars = 0, pending = false, CAP = 200000;
    function render() { pending = false; outEl.innerHTML = self._screen.map(function (p) { return '<span class="' + p[1] + '">' + esc(p[0]) + '</span>'; }).join(''); outEl.scrollTop = outEl.scrollHeight; }
    function sched() { if (!pending) { pending = true; setTimeout(render, 16); } }
    function clear() { self._screen = []; chars = 0; sched(); }
    function push(text, cls) {
      if (!text || chars > CAP) return;
      chars += text.length; self._screen.push([text, cls || '']); sched();
    }
    this.feed = function (text, cls) {
      ANSI.lastIndex = 0; var lastI = 0, mm;
      while ((mm = ANSI.exec(text))) {
        push(text.slice(lastI, mm.index), cls);
        var f = mm[0][mm[0].length - 1];
        if (mm[0] === '\x1b[2J' || f === 'H' || f === 'f') clear();
        lastI = ANSI.lastIndex;
      }
      push(text.slice(lastI), cls);
    };
    this.error = function (msg) { push('\n' + msg + '\n', 'err'); };

    // ---- run lifecycle hooks the manager calls ----
    var running = false;
    function setRun(on) { running = on; runBtn.classList.toggle('on', on); runBtn.textContent = on ? '■ Stop' : '▶ Run'; }
    this.getCode = function () { return ta.value; };
    this.getStdin = function () { return inWrap.hidden ? '' : inTa.value; };
    this.setStatus = function (s) { stEl.textContent = s; };
    this.starting = function () { outWrap.hidden = false; clear(); setRun(true); stEl.textContent = 'running…'; };
    this.finish = function (rc, ms) { setRun(false); if (!self._screen.length) push('(no output)', 'meta'); push('\n— exit ' + rc + ' · ' + ms + ' ms —', 'meta'); stEl.textContent = 'exit ' + rc + ' · ' + ms + ' ms'; };
    this.stopped = function () { setRun(false); push('\n— stopped —', 'meta'); stEl.textContent = 'stopped'; };
    this.reset = function () { setRun(false); stEl.textContent = ''; };
  }

  // ---- boot -------------------------------------------------------------
  function enhance(el) {
    if (el.__rakupp) return; el.__rakupp = true;
    var opts = {};
    if (el.hasAttribute('data-stdin')) opts.stdin = el.getAttribute('data-stdin');
    if (el.hasAttribute('data-rows')) opts.rows = parseInt(el.getAttribute('data-rows'), 10) || 0;
    var autorun = el.hasAttribute('data-run');
    var block = new Block(el, opts);
    if (autorun) requestRun(block);
    return block;
  }
  function enhanceAll(root) {
    (root || document).querySelectorAll(SELECTOR).forEach(enhance);
  }

  // Programmatic API for pages that build editors dynamically.
  window.RakuEmbed = { enhance: enhance, enhanceAll: enhanceAll };

  if (document.readyState === 'loading')
    document.addEventListener('DOMContentLoaded', function () { enhanceAll(); });
  else enhanceAll();
})();
