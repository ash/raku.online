/* Client-side search for the Raku++ spec — dependency-free. Loads
   /search-index.json once (on first focus/keystroke), ranks pages in the browser
   (every term must appear in title/slug/body; title & slug hits and term frequency
   drive the score, operators like ** ~~ Z= survive as searchable atoms), and renders
   a results panel under the sidebar box. Keyboard: "/" focuses, ↑/↓ move, Enter
   opens, Esc clears. Adapted from the raku-course search. */
(function () {
  'use strict';
  // Bust the index with the same cache tag stamped on this script's URL.
  var me = document.querySelector('script[src*="/theme/search.js"]');
  var VER = me ? (me.src.split('?v=')[1] || '') : '';
  // The Rules sub-site ships its own index and sets this before loading us;
  // the spec's own pages leave it unset and get the site-root index.
  var BASE = window.__SEARCH_INDEX || (window.__SITE_BASE || '') + '/search-index.json';
  var INDEX_URL = BASE + (VER ? '?v=' + VER : '');
  var docs = null, loading = false, loadErr = false, waiters = [];
  var box, input, panel, results = [], sel = -1, debounce;

  function ready(fn) {
    if (document.readyState !== 'loading') fn();
    else document.addEventListener('DOMContentLoaded', fn);
  }

  function load(cb) {
    if (docs) { cb && cb(); return; }
    if (cb) waiters.push(cb);
    if (loading) return;
    loading = true;
    fetch(INDEX_URL)
      .then(function (r) { if (!r.ok) throw 0; return r.json(); })
      .then(function (j) {
        docs = j.map(function (d) {
          return {
            u: d.u, t: d.t, b: d.b,
            tl: d.t.toLowerCase(), bl: d.b.toLowerCase(),
            ul: d.u.toLowerCase(),
            seg: d.u.replace(/\/$/, '').replace(/^.*\//, '').toLowerCase(),
            depth: d.u.replace(/^\/|\/$/g, '').split('/').length
          };
        });
        loading = false;
        waiters.forEach(function (f) { f(); });
        waiters = [];
      })
      .catch(function () { loading = false; loadErr = true; render(); });
  }

  function atoms(q) { return q.trim().split(/\s+/).filter(function (a) { return a.length; }); }
  function smart(q) { return /[A-Z]/.test(q); }
  var WORD = /[0-9A-Za-z]/;
  function startsWord(hay, idx) { return idx === 0 || !WORD.test(hay.charAt(idx - 1)); }
  function firstStart(hay, a) {
    var idx = hay.indexOf(a);
    while (idx >= 0) { if (startsWord(hay, idx)) return idx; idx = hay.indexOf(a, idx + 1); }
    return -1;
  }
  function countStarts(hay, a, cap) {
    var c = 0, idx = hay.indexOf(a);
    while (idx >= 0 && c < cap) { if (startsWord(hay, idx)) c++; idx = hay.indexOf(a, idx + a.length); }
    return c;
  }
  function wholeWord(hay, a, idx) {
    var after = idx + a.length;
    return after >= hay.length || !WORD.test(hay.charAt(after));
  }

  function search(q) {
    var as = atoms(q);
    if (!as.length) return [];
    var cs = smart(q);
    var lower = as.map(function (a) { return a.toLowerCase(); });
    var qaTB = cs ? as : lower;
    var slug = lower.join('-');
    var out = [];
    for (var i = 0; i < docs.length; i++) {
      var d = docs[i];
      var T = cs ? d.t : d.tl, B = cs ? d.b : d.bl;
      var score = 0, ok = true;
      for (var k = 0; k < qaTB.length; k++) {
        var aTB = qaTB[k];
        var tAt = firstStart(T, aTB);
        var uAt = firstStart(d.ul, aTB);
        var bc = countStarts(B, aTB, 31);
        if (tAt < 0 && uAt < 0 && bc === 0) { ok = false; break; }
        if (tAt >= 0) score += 10 + (tAt === 0 ? 6 : 0) + (wholeWord(T, aTB, tAt) ? 8 : 0);
        if (uAt >= 0) score += 12 + (wholeWord(d.ul, aTB, uAt) ? 18 : 0);
        score += bc;
      }
      if (ok) {
        if (d.seg === slug) score += 60;
        if (T === (cs ? as.join(' ') : slug.replace(/-/g, ' '))) score += 40;
        score += Math.max(0, 5 - d.depth);
        out.push({ d: d, s: score });
      }
    }
    out.sort(function (a, b) { return b.s - a.s || a.d.depth - b.d.depth; });
    return out.slice(0, 25).map(function (o) { return o.d; });
  }

  function snippet(d, q) {
    var as = atoms(q), cs = smart(q), B = cs ? d.b : d.bl, pos = -1;
    for (var k = 0; k < as.length; k++) {
      var a = cs ? as[k] : as[k].toLowerCase();
      var p = firstStart(B, a);
      if (p >= 0 && (pos < 0 || p < pos)) pos = p;
    }
    if (pos < 0) return d.b.slice(0, 140);
    var start = Math.max(0, pos - 50), end = Math.min(d.b.length, pos + 90);
    return (start > 0 ? '…' : '') + d.b.slice(start, end) + (end < d.b.length ? '…' : '');
  }

  function esc(s) {
    return s.replace(/[&<>"]/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c];
    });
  }
  function markHTML(text, q) {
    var as = atoms(q);
    if (!as.length) return esc(text);
    var cs = smart(q), hay = cs ? text : text.toLowerCase(), ranges = [];
    for (var k = 0; k < as.length; k++) {
      var a = cs ? as[k] : as[k].toLowerCase();
      if (!a) continue;
      var idx = hay.indexOf(a);
      while (idx >= 0) {
        if (startsWord(hay, idx)) ranges.push([idx, idx + a.length]);
        idx = hay.indexOf(a, idx + a.length);
      }
    }
    if (!ranges.length) return esc(text);
    ranges.sort(function (x, y) { return x[0] - y[0]; });
    var merged = [ranges[0].slice()];
    for (var r = 1; r < ranges.length; r++) {
      var last = merged[merged.length - 1];
      if (ranges[r][0] <= last[1]) last[1] = Math.max(last[1], ranges[r][1]);
      else merged.push(ranges[r].slice());
    }
    var out = '', cur = 0;
    for (var m = 0; m < merged.length; m++) {
      out += esc(text.slice(cur, merged[m][0])) + '<mark>' + esc(text.slice(merged[m][0], merged[m][1])) + '</mark>';
      cur = merged[m][1];
    }
    return out + esc(text.slice(cur));
  }

  function crumb(u) {
    return u.replace(/^\/|\/$/g, '').replace(/\//g, ' › ');
  }

  // Position the panel as a fixed overlay under the input. It's re-parented to
  // <body> (see init) so no transformed/overflow ancestor — the sidebar becomes
  // both on the mobile breakpoint — can clip it.
  function place() {
    var r = input.getBoundingClientRect();
    var vw = window.innerWidth || document.documentElement.clientWidth || 360;
    var left = Math.max(8, r.left);
    var w = Math.min(420, vw - left - 12);
    if (w < 240) { w = Math.min(vw - 16, 340); left = Math.max(8, (vw - w) / 2); }
    panel.style.top = (r.bottom + 6) + 'px';
    panel.style.left = left + 'px';
    panel.style.width = w + 'px';
  }

  function render() {
    if (!panel) return;
    if (loadErr) { panel.innerHTML = '<div class="ss-msg">Search is unavailable.</div>'; place(); panel.hidden = false; return; }
    var q = input.value.trim();
    if (!q) { panel.hidden = true; panel.innerHTML = ''; results = []; sel = -1; return; }
    if (!docs) { panel.innerHTML = '<div class="ss-msg">Loading…</div>'; place(); panel.hidden = false; return; }
    results = search(q); sel = -1;
    if (!results.length) {
      panel.innerHTML = '<div class="ss-msg">No matches for “' + esc(q) + '”.</div>'; place(); panel.hidden = false; return;
    }
    var html = '';
    for (var i = 0; i < results.length; i++) {
      var d = results[i];
      html += '<a class="ss-hit" href="' + d.u + '">' +
        '<span class="ss-t">' + markHTML(d.t, q) + '</span>' +
        '<span class="ss-c">' + esc(crumb(d.u)) + '</span>' +
        '<span class="ss-s">' + markHTML(snippet(d, q), q) + '</span></a>';
    }
    panel.innerHTML = html; place(); panel.hidden = false;
  }

  function setSel(n) {
    var hits = panel.querySelectorAll('.ss-hit');
    if (!hits.length) return;
    if (sel >= 0 && hits[sel]) hits[sel].classList.remove('sel');
    sel = (n + hits.length) % hits.length;
    hits[sel].classList.add('sel');
    hits[sel].scrollIntoView({ block: 'nearest' });
  }

  function onInput() {
    if (!docs) load(render);
    clearTimeout(debounce);
    debounce = setTimeout(render, 110);
  }

  ready(function () {
    box = document.querySelector('.site-search');
    if (!box) return;
    input = box.querySelector('input');
    panel = box.querySelector('.ss-results');
    // Lift the panel out of the sidebar so its fixed positioning is always
    // viewport-relative (the sidebar is transformed/overflow-clipped on mobile).
    document.body.appendChild(panel);

    input.addEventListener('focus', function () { load(render); });
    input.addEventListener('input', onInput);
    input.addEventListener('keydown', function (e) {
      if (e.key === 'ArrowDown') { e.preventDefault(); setSel(sel + 1); }
      else if (e.key === 'ArrowUp') { e.preventDefault(); setSel(sel - 1); }
      else if (e.key === 'Enter') {
        var hits = panel.querySelectorAll('.ss-hit');
        var h = hits[sel < 0 ? 0 : sel];
        if (h) { e.preventDefault(); window.location.href = h.getAttribute('href'); }
      } else if (e.key === 'Escape') {
        input.value = ''; panel.innerHTML = ''; panel.hidden = true; input.blur();
      }
    });
    document.addEventListener('click', function (e) {
      if (!box.contains(e.target) && !panel.contains(e.target)) panel.hidden = true;
    });
    window.addEventListener('resize', function () { if (!panel.hidden) place(); });
    document.addEventListener('keydown', function (e) {
      if (e.key === '/' && document.activeElement &&
          !/^(INPUT|TEXTAREA|SELECT)$/.test(document.activeElement.tagName) &&
          !document.activeElement.isContentEditable) {
        e.preventDefault();
        document.body.classList.add('nav-open');   // reveal the sidebar on mobile
        input.focus();
      }
    });
  });
})();
