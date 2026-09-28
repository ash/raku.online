// All Corners of Raku — page behaviour: theme menu, predict mode, on-demand
// editors, reading progress, the corners filter. Everything that is stored
// lives in this browser only, and every storage call may throw.
(function () {
  'use strict';

  function load(key, dflt) { try { var v = localStorage.getItem(key); return v == null ? dflt : v; } catch (e) { return dflt; } }
  function save(key, v) { try { localStorage.setItem(key, v); } catch (e) {} }

  // ---- theme menu --------------------------------------------------------
  var sw = document.querySelector('.theme-switch');
  if (sw) {
    var btn = sw.querySelector('.theme-btn'), menu = sw.querySelector('.theme-menu');
    var ICON = { system: '◐', light: '☀', dark: '☾' };
    function mark() {
      var s = document.documentElement.getAttribute('data-theme') || 'system';
      btn.textContent = ICON[s] || ICON.system;
      menu.querySelectorAll('[data-theme-set]').forEach(function (b) {
        b.setAttribute('aria-checked', b.getAttribute('data-theme-set') === s ? 'true' : 'false');
      });
    }
    function open(o) { menu.hidden = !o; btn.setAttribute('aria-expanded', o ? 'true' : 'false'); }
    btn.addEventListener('click', function (e) { e.stopPropagation(); open(menu.hidden); });
    menu.addEventListener('click', function (e) {
      var b = e.target.closest('[data-theme-set]');
      if (!b) return;
      var s = b.getAttribute('data-theme-set');
      save('raku-theme', s);
      window.__applyTheme(s);
      mark(); open(false); btn.focus();
    });
    document.addEventListener('click', function (e) { if (!sw.contains(e.target)) open(false); });
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && !menu.hidden) open(false); });
    mark();
  }

  // ---- contents drawer on narrow screens ---------------------------------
  var tog = document.querySelector('.nav-toggle');
  if (tog) {
    tog.addEventListener('click', function (e) { e.stopPropagation(); document.body.classList.toggle('nav-open'); });
    document.addEventListener('click', function (e) {
      if (document.body.classList.contains('nav-open') && !e.target.closest('nav.toc')) document.body.classList.remove('nav-open');
    });
    document.querySelectorAll('nav.toc a').forEach(function (a) {
      if (a.parentNode.classList.contains('has-corners')) return;   // folds instead, see below
      a.addEventListener('click', function () { document.body.classList.remove('nav-open'); });
    });
  }

  // ---- predict mode ------------------------------------------------------
  var pt = document.getElementById('predict-toggle');
  if (pt) {
    pt.checked = load('corners-predict', '0') === '1';
    pt.addEventListener('change', function () {
      save('corners-predict', pt.checked ? '1' : '0');
      document.documentElement.classList.toggle('predict-on', pt.checked);
      if (!pt.checked) document.querySelectorAll('.out.revealed').forEach(function (o) { o.classList.remove('revealed'); });
    });
  }
  document.addEventListener('click', function (e) {
    var r = e.target.closest('.reveal');
    if (r) r.closest('.out').classList.add('revealed');
  });

  // ---- editors on demand -------------------------------------------------
  // The code is shown pre-highlighted; ▶ Run turns that block into a live
  // raku.online editor (Raku++ in WebAssembly) and runs it.
  function whenEmbed(fn, tries) {
    if (window.RakuEmbed) return fn();
    if ((tries || 0) > 100) return;
    setTimeout(function () { whenEmbed(fn, (tries || 0) + 1); }, 100);
  }
  document.addEventListener('click', function (e) {
    var b = e.target.closest('figure.ex .run');
    if (!b) return;
    var box = b.closest('.code'), pre = box.querySelector('pre.src');
    b.disabled = true; b.textContent = '…';
    whenEmbed(function () {
      var host = document.createElement('div');
      if (pre.hasAttribute('data-stdin')) host.setAttribute('data-stdin', pre.getAttribute('data-stdin'));
      // Say which engine the reader is now running.
      var cap = document.createElement('div');
      cap.className = 'engine-cap';
      cap.textContent = 'Raku++, running in your browser';
      box.appendChild(cap);
      box.appendChild(host);
      box.classList.add('live');
      b.remove();
      window.RakuEmbed.enhance(host, { code: pre.textContent, run: true, hide: 'playground' });
    });
  });

  // ---- reading progress --------------------------------------------------
  var done = {};
  try { done = JSON.parse(load('corners-done', '{}')) || {}; } catch (e) { done = {}; }
  function paintDone() {
    document.querySelectorAll('[data-slug]').forEach(function (el) {
      if (el.matches('li')) el.classList.toggle('done', !!done[el.getAttribute('data-slug')]);
    });
  }
  document.querySelectorAll('input[data-done]').forEach(function (cb) {
    var slug = cb.getAttribute('data-done');
    cb.checked = !!done[slug];
    cb.addEventListener('change', function () {
      if (cb.checked) done[slug] = 1; else delete done[slug];
      save('corners-done', JSON.stringify(done));
      paintDone();
    });
  });
  paintDone();

  // ---- fold the current chapter's corners --------------------------------
  // One choice for the whole book: folded here, folded on the next chapter.
  var fold = document.querySelector('nav.toc .toc-fold');
  function setFold(f) {
    document.documentElement.classList.toggle('toc-folded', f);
    if (!fold) return;
    fold.setAttribute('aria-expanded', f ? 'false' : 'true');
    fold.setAttribute('aria-label', f ? "Show this chapter's corners" : "Hide this chapter's corners");
    fold.title = f ? 'Show the corners' : 'Hide the corners';
  }
  if (fold) {
    setFold(load('corners-toc-folded', '0') === '1');
    // The chapter being read is already open, so its title in the contents
    // folds and unfolds its corners rather than reloading the page. A
    // modified click still does what the reader asked for (a new tab).
    var title = fold.parentNode.querySelector(':scope > a');
    if (title) title.addEventListener('click', function (e) {
      if (e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;
      e.preventDefault();
      fold.click();
    });
    fold.addEventListener('click', function (e) {
      e.preventDefault();
      var f = !document.documentElement.classList.contains('toc-folded');
      setFold(f);
      save('corners-toc-folded', f ? '1' : '0');
    });
  }

  // ---- the corner being read, marked in the contents ---------------------
  var links = {};
  document.querySelectorAll('.toc-corners a').forEach(function (a) { links[a.getAttribute('href').slice(1)] = a; });
  var corners = document.querySelectorAll('section.corner');
  if (corners.length && 'IntersectionObserver' in window) {
    var active = null;
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        if (!en.isIntersecting) return;
        var a = links[en.target.id];
        if (!a || a === active) return;
        if (!a.offsetParent) return;
        if (active) active.classList.remove('active');
        active = a; a.classList.add('active');
        // Keep the active entry in view by scrolling the sidebar alone, and
        // only while the sidebar is on screen: scrollIntoView would also
        // scroll the page, sideways when the drawer is hidden off-canvas.
        var toc = document.querySelector('nav.toc');
        if (getComputedStyle(toc).position === 'fixed' && !document.body.classList.contains('nav-open')) return;
        var r = a.getBoundingClientRect(), t = toc.getBoundingClientRect();
        if (r.top < t.top + 40 || r.bottom > t.bottom - 40) toc.scrollTop += (r.top - t.top) - t.height / 2;
      });
    }, { rootMargin: '-60px 0px -70% 0px' });
    corners.forEach(function (c) { io.observe(c); });
  }

  // ---- corners index filter ----------------------------------------------
  var q = document.getElementById('corner-search');
  if (q) {
    var tag = '';
    function apply() {
      var needle = q.value.trim().toLowerCase();
      document.querySelectorAll('.ci-chapter').forEach(function (ch) {
        var any = false;
        ch.querySelectorAll('li').forEach(function (li) {
          var tags = (li.getAttribute('data-tags') || '').split(' ');
          var ok = (!tag || tags.indexOf(tag) >= 0) && (!needle || li.textContent.toLowerCase().indexOf(needle) >= 0);
          li.hidden = !ok; if (ok) any = true;
        });
        ch.hidden = !any;
      });
    }
    q.addEventListener('input', apply);
    document.querySelectorAll('.chip').forEach(function (c) {
      c.addEventListener('click', function () {
        document.querySelectorAll('.chip').forEach(function (x) { x.classList.remove('on'); });
        c.classList.add('on'); tag = c.getAttribute('data-tag'); apply();
      });
    });
  }
})();
