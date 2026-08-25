/* Rakugrid — the interactive layer.
 *
 * Three page kinds get behaviour: the home page draws the one-pixel-per-test
 * ribbons and the atom quick-find; an atom page fetches its JSON and renders
 * either a 2D matrix (when the atom is a ladder cross) or an incrementally
 * rendered record list, both opening the same record drawer; a family page
 * gets sortable columns. The divergence/ruling/crash pages are static HTML.
 *
 * Everything is built with DOM nodes, not innerHTML: the payload is whatever
 * the engines printed, and it must never be interpreted as markup.
 */
(function () {
  'use strict';

  var BASE = window.__SITE_BASE || '/grid';
  var V = window.__GRID_V || '';
  var PAGE = document.body.getAttribute('data-grid-page');

  var ST_NAME = { a: 'agree', f: 'fixed', d: 'differs', c: 'crash', r: 'ruled', n: 'no data' };
  var ST_KEYS = ['a', 'f', 'd', 'c', 'r', 'n'];

  function $(sel, root) { return (root || document).querySelector(sel); }

  function el(tag, attrs) {
    var node = document.createElement(tag);
    if (attrs) {
      for (var k in attrs) {
        if (k === 'text') node.textContent = attrs[k];
        else if (k === 'class') node.className = attrs[k];
        else node.setAttribute(k, attrs[k]);
      }
    }
    for (var i = 2; i < arguments.length; i++) {
      var kid = arguments[i];
      if (kid == null) continue;
      node.appendChild(typeof kid === 'string' ? document.createTextNode(kid) : kid);
    }
    return node;
  }

  function fetchJSON(path) {
    return fetch(BASE + path + '?v=' + V).then(function (r) {
      if (!r.ok) throw new Error(r.status + ' for ' + path);
      return r.json();
    });
  }

  // The status palette lives in CSS so the theme switch owns it; the canvas
  // reads it back and repaints when the theme changes.
  var colorCache = null;
  function colors() {
    if (colorCache) return colorCache;
    var cs = getComputedStyle(document.documentElement);
    colorCache = {};
    ST_KEYS.forEach(function (k) {
      colorCache[k] = cs.getPropertyValue('--st-' + k).trim() || '#888';
    });
    return colorCache;
  }

  new MutationObserver(function () {
    colorCache = null;
    repaintRibbons();
  }).observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme-active'] });

  function commify(n) {
    return String(n).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  }

  // Same abbreviation the harness's matrix command uses: X::Numeric::DivideByZero
  // shows as !DBZ in a cell, with the legend giving the full name.
  function shortObs(o) {
    if (!o) return '·';
    if (o.indexOf('ERR:') === 0) return abbrevErr(o.slice(4));
    return o.length > 12 ? o.slice(0, 11) + '…' : o;
  }
  function abbrevErr(full) {
    var last = full.split('::').pop();
    var caps = last.replace(/[^A-Z]/g, '');
    return '!' + (caps || last.slice(0, 3).toUpperCase());
  }
  function comparable(o) {
    return o.indexOf('rejected:') === 0 ? 'rejected' : o;
  }

  function decodeRLE(rle) {
    var out = [];
    var m, re = /(\d+)([a-z])/g;
    while ((m = re.exec(rle))) {
      var n = +m[1];
      for (var i = 0; i < n; i++) out.push(m[2]);
    }
    return out;
  }

  // ---- shareable playground links (same encoding the playground itself uses)

  var b64uEnc = function (bytes) {
    var s = '';
    for (var i = 0; i < bytes.length; i += 0x8000)
      s += String.fromCharCode.apply(null, bytes.subarray(i, i + 0x8000));
    return btoa(s).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  };
  function playLink(code) {
    if (typeof CompressionStream === 'undefined') return Promise.reject(new Error('no CompressionStream'));
    var stream = new Blob([new TextEncoder().encode(code)]).stream()
      .pipeThrough(new CompressionStream('deflate-raw'));
    return new Response(stream).arrayBuffer().then(function (buf) {
      return '/play/#code=' + b64uEnc(new Uint8Array(buf)) + '&run=1';
    });
  }

  function copyText(text, btn) {
    var done = function () {
      if (!btn) return;
      var old = btn.textContent;
      btn.textContent = 'copied';
      setTimeout(function () { btn.textContent = old; }, 900);
    };
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(done, done);
    } else done();
  }

  /* ================================================================ home */

  var RIBBONS = [];       // one entry per canvas: everything needed to repaint
  var HIGHLIGHT = {};     // status → true when the legend filters

  function anyHighlight() {
    for (var k in HIGHLIGHT) if (HIGHLIGHT[k]) return true;
    return false;
  }

  function homePage() {
    fetchJSON('/data/ribbon.json').then(function (ribbon) {
      var byFam = {};
      ribbon.families.forEach(function (f) { byFam[f.family] = f.atoms; });
      document.querySelectorAll('canvas.ribbon').forEach(function (cv) {
        var atoms = byFam[cv.getAttribute('data-family')];
        if (atoms) setupRibbon(cv, atoms);
      });
      repaintRibbons();
      window.addEventListener('resize', debounce(function () {
        RIBBONS.forEach(layoutRibbon);
        repaintRibbons();
      }, 150));
    }).catch(function () { /* the static page stands on its own */ });

    fetchJSON('/data/atoms.json').then(setupSearch).catch(function () {});

    document.querySelectorAll('.ribbon-legend .st-chip').forEach(function (chip) {
      chip.setAttribute('aria-pressed', 'false');
      chip.addEventListener('click', function () {
        var st = chip.getAttribute('data-st');
        HIGHLIGHT[st] = !HIGHLIGHT[st];
        chip.setAttribute('aria-pressed', HIGHLIGHT[st] ? 'true' : 'false');
        repaintRibbons();
      });
    });
  }

  function debounce(fn, ms) {
    var t;
    return function () { clearTimeout(t); t = setTimeout(fn, ms); };
  }

  function setupRibbon(cv, atoms) {
    // Each atom contributes its cells plus one separator cell. The linear cell
    // index is what hover and click resolve through.
    var total = 0;
    var spans = [];
    atoms.forEach(function (a) {
      var sts = decodeRLE(a.rle);
      var counts = {};
      sts.forEach(function (s) { counts[s] = (counts[s] || 0) + 1; });
      spans.push({ start: total, end: total + sts.length, atom: a, sts: sts, counts: counts });
      total += sts.length + 1;   // the gap
    });
    var R = { cv: cv, spans: spans, total: total,
              px: total < 4000 ? 6 : total < 40000 ? 3 : 2 };
    layoutRibbon(R);
    RIBBONS.push(R);

    cv.addEventListener('mousemove', function (ev) { ribbonHover(R, ev); });
    cv.addEventListener('mouseleave', function () { tipbox(null); cvCursor(R, null); });
    cv.addEventListener('click', function (ev) {
      var span = ribbonSpanAt(R, ev);
      if (span) location.href = BASE + '/atom/' + span.atom.name.split('/')[0] + '/' + span.atom.s + '/';
    });
  }

  function layoutRibbon(R) {
    var wCSS = R.cv.parentNode.clientWidth || 900;
    R.cols = Math.max(40, Math.floor(wCSS / R.px));
    R.rows = Math.max(1, Math.ceil(R.total / R.cols));
    var dpr = window.devicePixelRatio || 1;
    R.cv.width = R.cols * R.px * dpr;
    R.cv.height = R.rows * R.px * dpr;
    R.cv.style.width = (R.cols * R.px) + 'px';
    R.cv.style.height = (R.rows * R.px) + 'px';
    R.dpr = dpr;
  }

  function repaintRibbons() {
    var C = colors();
    var filtering = anyHighlight();
    RIBBONS.forEach(function (R) {
      var ctx = R.cv.getContext('2d');
      ctx.setTransform(R.dpr, 0, 0, R.dpr, 0, 0);
      ctx.clearRect(0, 0, R.cols * R.px, R.rows * R.px);
      R.spans.forEach(function (span) {
        for (var i = 0; i < span.sts.length; i++) {
          var st = span.sts[i];
          var cell = span.start + i;
          var x = (cell % R.cols) * R.px;
          var y = Math.floor(cell / R.cols) * R.px;
          ctx.globalAlpha = (!filtering || HIGHLIGHT[st]) ? 1 : 0.10;
          ctx.fillStyle = C[st];
          ctx.fillRect(x, y, R.px, R.px);
        }
      });
      ctx.globalAlpha = 1;
    });
  }

  function ribbonSpanAt(R, ev) {
    var rect = R.cv.getBoundingClientRect();
    var col = Math.floor((ev.clientX - rect.left) / R.px);
    var row = Math.floor((ev.clientY - rect.top) / R.px);
    if (col < 0 || col >= R.cols) return null;
    var cell = row * R.cols + col;
    for (var i = 0; i < R.spans.length; i++) {
      if (cell >= R.spans[i].start && cell < R.spans[i].end) return R.spans[i];
    }
    return null;
  }

  var tipEl = null;
  function tipbox(content, ev) {
    if (!content) {
      if (tipEl) tipEl.remove();
      tipEl = null;
      return;
    }
    if (!tipEl) {
      tipEl = el('div', { class: 'ribbon-tipbox' });
      document.body.appendChild(tipEl);
    }
    tipEl.textContent = '';
    tipEl.appendChild(content);
    var x = Math.min(ev.clientX + 14, window.innerWidth - tipEl.offsetWidth - 10);
    var y = Math.min(ev.clientY + 16, window.innerHeight - tipEl.offsetHeight - 10);
    tipEl.style.left = x + 'px';
    tipEl.style.top = y + 'px';
  }

  function cvCursor(R, span) {
    R.cv.style.cursor = span ? 'pointer' : 'crosshair';
  }

  function ribbonHover(R, ev) {
    var span = ribbonSpanAt(R, ev);
    cvCursor(R, span);
    if (!span) { tipbox(null); return; }
    var frag = document.createDocumentFragment();
    frag.appendChild(el('b', { text: span.atom.name }));
    var parts = [commify(span.sts.length) + ' tests'];
    ST_KEYS.forEach(function (k) {
      if (k !== 'a' && span.counts[k]) parts.push(commify(span.counts[k]) + ' ' + ST_NAME[k]);
    });
    frag.appendChild(el('div', { class: 'tip-counts', text: parts.join(' · ') }));
    tipbox(frag, ev);
  }

  function setupSearch(rows) {
    var input = $('#atom-search');
    var list = $('#atom-search-hits');
    if (!input || !list) return;
    var sel = -1;

    function hide() { list.hidden = true; sel = -1; }
    function render(q) {
      list.textContent = '';
      q = q.trim().toLowerCase();
      if (!q) { hide(); return; }
      var hits = [];
      for (var i = 0; i < rows.length; i++) {
        var pos = rows[i][0].toLowerCase().indexOf(q);
        if (pos >= 0) hits.push([pos === 0 ? 0 : 1, -rows[i][3], rows[i]]);
      }
      hits.sort(function (a, b) { return a[0] - b[0] || a[1] - b[1]; });
      hits.slice(0, 20).forEach(function (h) {
        var r = h[2];
        var right = commify(r[3]) + ' tests';
        var a = el('a', { href: BASE + '/atom/' + r[1] + '/' + r[2] + '/' }, r[0]);
        var n = el('span', { class: 'hit-n' }, right);
        if (r[4]) n.appendChild(el('em', { text: ' · ' + commify(r[4]) + ' differ' }));
        a.appendChild(n);
        list.appendChild(el('li', null, a));
      });
      list.hidden = !list.children.length;
    }

    input.addEventListener('input', function () { render(input.value); });
    input.addEventListener('keydown', function (ev) {
      var items = list.querySelectorAll('a');
      if (ev.key === 'Escape') { hide(); return; }
      if (!items.length) return;
      if (ev.key === 'ArrowDown' || ev.key === 'ArrowUp') {
        ev.preventDefault();
        sel = (sel + (ev.key === 'ArrowDown' ? 1 : -1) + items.length) % items.length;
        items.forEach(function (a, i) { a.classList.toggle('sel', i === sel); });
        items[sel].scrollIntoView({ block: 'nearest' });
      } else if (ev.key === 'Enter' && sel >= 0) {
        ev.preventDefault();
        location.href = items[sel].getAttribute('href');
      }
    });
    input.addEventListener('blur', function () { setTimeout(hide, 200); });
  }

  /* ================================================================ atom */

  // The record array layout emitted by build.raku:
  // [id, cell, code, expect, status, obs-per-engine, ruling|0, extra|0]
  var F_ID = 0, F_CELL = 1, F_CODE = 2, F_EXPECT = 3, F_ST = 4, F_OBS = 5, F_RULING = 6, F_EXTRA = 7;

  function lastObs(data, rec, kind) {
    var out = null;
    for (var i = 0; i < data.engines.length; i++) {
      if (data.kinds[i] === kind && rec[F_OBS][i] != null) out = rec[F_OBS][i];
    }
    return out;
  }

  function atomPage() {
    var app = $('#grid-app');
    if (!app) return;
    var key = app.getAttribute('data-atom');
    fetchJSON('/data/atom/' + key + '.json').then(function (data) {
      app.textContent = '';
      renderAtom(app, data);
      var m = location.hash.match(/^#t=(\d+)$/);
      if (m) {
        var i = +m[1];
        if (data.records[i]) {
          revealRecord(app, data, i);
          openDrawer(data, i);
        }
      }
    }).catch(function (e) {
      app.textContent = '';
      app.appendChild(el('p', { class: 'grid-loading', text: 'Could not load the grid data (' + e.message + ').' }));
    });
  }

  function cellSplit(cell) {
    var i = cell.lastIndexOf(' | ');
    return i < 0 ? null : [cell.slice(0, i), cell.slice(i + 3)];
  }

  function renderAtom(app, data) {
    var matrixInfo = null;
    if (data.axes && data.cols) {
      var axesSet = {}, colsSet = {};
      data.axes.forEach(function (a) { axesSet[a] = 1; });
      data.cols.forEach(function (c) { colsSet[c] = 1; });
      var map = {};        // row NUL col → record index
      var placed = [];
      var leftover = [];
      data.records.forEach(function (rec, i) {
        var parts = rec[F_CELL] ? cellSplit(rec[F_CELL]) : null;
        if (parts && axesSet[parts[0]] && colsSet[parts[1]]) {
          map[parts[0] + '\u0000' + parts[1]] = i;
          placed.push(i);
        } else {
          leftover.push(i);
        }
      });
      if (placed.length && placed.length >= data.records.length * 0.5) {
        matrixInfo = { map: map, leftover: leftover };
      }
    }

    if (matrixInfo) {
      renderMatrix(app, data, matrixInfo.map);
      if (matrixInfo.leftover.length) {
        app.appendChild(el('h3', { class: 'leftover-h', text: matrixInfo.leftover.length + ' records outside the cross' }));
        renderList(app, data, matrixInfo.leftover);
      }
    } else {
      renderList(app, data, data.records.map(function (_, i) { return i; }));
    }
  }

  function renderMatrix(app, data, map) {
    var wrap = el('div', { class: 'matrix-wrap' });
    var table = el('table', { class: 'matrix' });
    var thead = el('thead');
    var hr = el('tr', null, el('th', { text: '' }));
    data.cols.forEach(function (c) { hr.appendChild(el('th', { text: c, title: c })); });
    thead.appendChild(hr);
    table.appendChild(thead);

    var legend = {};   // !ABC → full ERR name
    var tbody = el('tbody');
    data.axes.forEach(function (a) {
      var tr = el('tr', null, el('th', { text: a, title: a }));
      data.cols.forEach(function (c) {
        var i = map[a + '\u0000' + c];
        if (i == null) {
          tr.appendChild(el('td', { class: 'st-n', text: '·' }));
          return;
        }
        var rec = data.records[i];
        var ref = lastObs(data, rec, 'ref') || '';
        var txt = shortObs(ref);
        if (ref.indexOf('ERR:') === 0) legend[txt] = ref.slice(4);
        var td = el('td', { class: 'st-' + rec[F_ST], 'data-i': i, text: txt,
                            title: rec[F_CODE] + '  →  ' + (ref || '(no reference)') });
        tr.appendChild(td);
      });
      tbody.appendChild(tr);
    });
    table.appendChild(tbody);
    wrap.appendChild(table);
    app.appendChild(wrap);

    wrap.addEventListener('click', function (ev) {
      var td = ev.target.closest('td[data-i]');
      if (td) openDrawer(data, +td.getAttribute('data-i'));
    });

    var keys = Object.keys(legend).sort();
    if (keys.length) {
      var p = el('p', { class: 'matrix-legend' }, 'thrown: ');
      keys.forEach(function (k, i) {
        if (i) p.appendChild(document.createTextNode(' · '));
        p.appendChild(el('code', { text: k + ' = ' + legend[k] }));
      });
      app.appendChild(p);
    }
  }

  /* the incremental record list */

  function renderList(app, data, indexes) {
    var state = { data: data, all: indexes, filtered: indexes.slice(), shown: 0, q: '', st: {} };

    var bar = el('div', { class: 'rec-toolbar' });
    var input = el('input', { type: 'search', placeholder: 'filter by code or observation…', autocomplete: 'off' });
    bar.appendChild(input);
    var counts = {};
    indexes.forEach(function (i) { var s = data.records[i][F_ST]; counts[s] = (counts[s] || 0) + 1; });
    ST_KEYS.forEach(function (k) {
      if (!counts[k]) return;
      var chip = el('button', { class: 'st-chip st-' + k, 'data-st': k, 'aria-pressed': 'false' },
                    el('i'), ST_NAME[k] + ' ', el('span', { text: commify(counts[k]) }));
      chip.addEventListener('click', function () {
        state.st[k] = !state.st[k];
        chip.setAttribute('aria-pressed', state.st[k] ? 'true' : 'false');
        refilter();
      });
      bar.appendChild(chip);
    });
    app.appendChild(bar);

    var wrap = el('div', { class: 'rec-wrap' });
    var table = el('table', { class: 'rec-list' });
    table.appendChild(el('thead', null, el('tr', null,
      el('th', { text: 'id' }), el('th', { text: 'code' }), el('th', { text: 'asserted' }),
      el('th', { text: 'reference' }), el('th', { text: 'rakupp' }), el('th', { text: '' }))));
    var tbody = el('tbody');
    table.appendChild(tbody);
    wrap.appendChild(table);
    var more = el('div', { class: 'rec-more', text: '' });
    wrap.appendChild(more);
    app.appendChild(wrap);

    var CHUNK = 400;
    function renderChunk() {
      var end = Math.min(state.shown + CHUNK, state.filtered.length);
      for (var k = state.shown; k < end; k++) {
        var i = state.filtered[k];
        var rec = state.data.records[i];
        var ref = lastObs(state.data, rec, 'ref');
        var pp = lastObs(state.data, rec, 'pp');
        var same = ref != null && pp != null && comparable(ref) === comparable(pp);
        var tr = el('tr', { 'data-i': i },
          el('td', { class: 'mono', text: rec[F_ID] }),
          el('td', { class: 'mono rc-code', text: rec[F_CODE], title: rec[F_CODE] }),
          el('td', { class: 'mono rc-obs', text: rec[F_EXPECT], title: rec[F_EXPECT] }),
          el('td', { class: 'mono rc-obs', text: ref == null ? '·' : ref, title: ref || '' }),
          el('td', { class: 'mono rc-obs' + (same ? '' : ' differs'), text: pp == null ? '·' : (same ? '·' : pp), title: pp || '' }),
          el('td', null, el('i', { class: 'st-dot st-' + rec[F_ST], title: ST_NAME[rec[F_ST]] })));
        tbody.appendChild(tr);
      }
      state.shown = end;
      more.textContent = state.shown < state.filtered.length
        ? 'showing ' + commify(state.shown) + ' of ' + commify(state.filtered.length) + ' — scroll for more'
        : (state.filtered.length === state.all.length
            ? '' : commify(state.filtered.length) + ' of ' + commify(state.all.length) + ' match');
    }

    function refilter() {
      tbody.textContent = '';
      state.shown = 0;
      var q = state.q.toLowerCase();
      var anySt = ST_KEYS.some(function (k) { return state.st[k]; });
      state.filtered = state.all.filter(function (i) {
        var rec = state.data.records[i];
        if (anySt && !state.st[rec[F_ST]]) return false;
        if (!q) return true;
        if (rec[F_CODE].toLowerCase().indexOf(q) >= 0) return true;
        if (rec[F_EXPECT].toLowerCase().indexOf(q) >= 0) return true;
        for (var e = 0; e < rec[F_OBS].length; e++) {
          if (rec[F_OBS][e] != null && rec[F_OBS][e].toLowerCase().indexOf(q) >= 0) return true;
        }
        return false;
      });
      renderChunk();
    }

    input.addEventListener('input', debounce(function () {
      state.q = input.value;
      refilter();
    }, 120));

    new IntersectionObserver(function (entries) {
      if (entries[0].isIntersecting && state.shown < state.filtered.length) renderChunk();
    }, { root: wrap }).observe(more);

    tbody.addEventListener('click', function (ev) {
      var tr = ev.target.closest('tr[data-i]');
      if (tr) openDrawer(state.data, +tr.getAttribute('data-i'));
    });

    renderChunk();
  }

  function revealRecord(app, data, i) {
    var cell = app.querySelector('[data-i="' + i + '"]');
    if (cell) {
      cell.classList.add('hl');
      cell.scrollIntoView({ block: 'center', inline: 'center' });
    }
  }

  /* the drawer */

  var drawerEls = null;
  function closeDrawer() {
    if (!drawerEls) return;
    drawerEls.forEach(function (n) { n.remove(); });
    drawerEls = null;
    if (location.hash.indexOf('#t=') === 0) history.replaceState(null, '', location.pathname);
    document.removeEventListener('keydown', escClose);
  }
  function escClose(ev) {
    if (ev.key === 'Escape') closeDrawer();
  }

  function openDrawer(data, i) {
    closeDrawer();
    var rec = data.records[i];
    var back = el('div', { class: 'drawer-back' });
    back.addEventListener('click', closeDrawer);
    var d = el('aside', { class: 'drawer', role: 'dialog', 'aria-label': data.atom + ' #' + rec[F_ID] });

    var closeBtn = el('button', { class: 'd-close', 'aria-label': 'Close', text: '×' });
    closeBtn.addEventListener('click', closeDrawer);
    d.appendChild(closeBtn);

    d.appendChild(el('h2', { class: 'mono', text: data.atom + ' #' + rec[F_ID] }));
    d.appendChild(el('p', { class: 'd-status' },
      el('span', { class: 'st-chip st-' + rec[F_ST] }, el('i'), ST_NAME[rec[F_ST]]),
      rec[F_CELL] ? el('span', { class: 'mono', text: '  cell ' + rec[F_CELL] }) : null));

    d.appendChild(el('h3', { text: 'code' }));
    d.appendChild(el('pre', null, el('code', { text: rec[F_CODE] })));

    var actions = el('div', { class: 'd-actions' });
    var runBtn = el('button', { class: 'primary', text: 'Run in playground' });
    runBtn.addEventListener('click', function () {
      playLink(rec[F_CODE]).then(function (href) {
        window.open(href, '_blank');
      }).catch(function () { runBtn.disabled = true; runBtn.textContent = 'playground unavailable'; });
    });
    actions.appendChild(runBtn);
    var copyBtn = el('button', { text: 'Copy code' });
    copyBtn.addEventListener('click', function () { copyText(rec[F_CODE], copyBtn); });
    actions.appendChild(copyBtn);
    var isoBtn = el('button', { text: 'Copy isolate command' });
    var isoCmd = "raku bin/rakugrid isolate 'grid:" + data.atom + '#' + rec[F_ID] + "'";
    isoBtn.addEventListener('click', function () { copyText(isoCmd, isoBtn); });
    actions.appendChild(isoBtn);
    d.appendChild(actions);

    d.appendChild(el('h3', { text: 'asserted' }));
    d.appendChild(el('p', { class: 'd-expect mono', text: rec[F_EXPECT] || '—' }));

    d.appendChild(el('h3', { text: 'what the engines said' }));
    var refVal = lastObs(data, rec, 'ref');
    var refIdx = -1, ppIdx = -1;
    for (var e = 0; e < data.engines.length; e++) {
      if (rec[F_OBS][e] == null) continue;
      if (data.kinds[e] === 'ref') refIdx = e;
      else ppIdx = e;
    }
    var tbl = el('table', { class: 'd-engines' });
    for (var e2 = 0; e2 < data.engines.length; e2++) {
      var obs = rec[F_OBS][e2];
      if (obs == null) continue;
      var isRef = data.kinds[e2] === 'ref';
      var tag = e2 === refIdx ? 'reference' : e2 === ppIdx ? 'newest' : isRef ? 'older ref' : 'older';
      var differ = refVal != null && !isRef && comparable(obs) !== comparable(refVal);
      var crash = /^(CRASH|HANG|TIMEOUT):/.test(obs);
      var tr = el('tr', { class: (differ ? 'differ' : '') + (crash ? ' crash' : '') },
        el('td', { class: 'mono d-eng', text: data.engines[e2] }),
        el('td', { class: 'mono d-obs', text: obs }),
        el('td', null, el('span', { class: 'd-tag', text: tag })));
      tbl.appendChild(tr);
    }
    d.appendChild(tbl);

    if (rec[F_RULING]) {
      d.appendChild(el('h3', { text: 'ruling' }));
      var ru = rec[F_RULING];
      d.appendChild(el('div', { class: 'd-ruling' },
        el('span', { class: 'verdict-tag', text: ru.v }),
        document.createTextNode(' ' + ru.w),
        ru.d ? el('div', { class: 'note-line', text: 'ruled ' + ru.d }) : null));
    }

    var extras = [];
    if (data.defFrom) extras.push(['from', data.defFrom]);
    if (rec[F_EXTRA]) rec[F_EXTRA].forEach(function (kv) {
      if (kv[0] === 'from') extras = extras.filter(function (x) { return x[0] !== 'from'; });
      extras.push(kv);
    });
    if (extras.length) {
      d.appendChild(el('h3', { text: 'record fields' }));
      var dl = el('dl', { class: 'd-extra' });
      extras.forEach(function (kv) {
        dl.appendChild(el('div', null, el('dt', { text: kv[0] }), el('dd', { class: 'mono', text: kv[1] })));
      });
      d.appendChild(dl);
    }

    d.appendChild(el('h3', { text: 'reproduce' }));
    d.appendChild(el('p', { class: 'mono d-isolate', text: isoCmd }));

    document.body.appendChild(back);
    document.body.appendChild(d);
    drawerEls = [back, d];
    document.addEventListener('keydown', escClose);
    history.replaceState(null, '', location.pathname + '#t=' + i);
  }

  /* ================================================================ family */

  function familyPage() {
    var table = $('table[data-sortable]');
    if (!table) return;
    var tbody = table.tBodies[0];
    var ths = table.querySelectorAll('th[data-sort]');
    ths.forEach(function (th, col) {
      th.addEventListener('click', function () {
        var dir = th.getAttribute('data-dir') === 'asc' ? 'desc' : 'asc';
        ths.forEach(function (o) { o.removeAttribute('data-dir'); o.querySelector('.arrow') && o.querySelector('.arrow').remove(); });
        th.setAttribute('data-dir', dir);
        th.appendChild(el('span', { class: 'arrow', text: dir === 'asc' ? ' ↑' : ' ↓' }));
        var rows = [].slice.call(tbody.rows);
        var num = th.getAttribute('data-sort') === 'num';
        rows.sort(function (a, b) {
          var x, y;
          if (num) {
            x = +a.cells[col].getAttribute('data-n') || 0;
            y = +b.cells[col].getAttribute('data-n') || 0;
          } else {
            x = a.cells[col].textContent.trim();
            y = b.cells[col].textContent.trim();
            return dir === 'asc' ? x.localeCompare(y) : y.localeCompare(x);
          }
          return dir === 'asc' ? x - y : y - x;
        });
        rows.forEach(function (r) { tbody.appendChild(r); });
      });
    });
  }

  /* ================================================================ boot */

  if (PAGE === 'home') homePage();
  else if (PAGE === 'atom') atomPage();
  else if (PAGE === 'family') familyPage();
})();
