// tour.js — page chrome for the tour: mobile nav, visited-lesson progress,
// the home page's Continue button, and ←/→ keyboard navigation. The runnable
// editors themselves are handled entirely by raku.js (loaded after this).
(function () {
  'use strict';
  var KEY = 'raku-tour-done';
  var TOUR = window.TOUR || { order: [], slug: null };

  function readDone() {
    try { return JSON.parse(localStorage.getItem(KEY) || '{}') || {}; }
    catch (e) { return {}; }
  }
  function writeDone(d) {
    try { localStorage.setItem(KEY, JSON.stringify(d)); } catch (e) {}
  }

  // Opening a lesson marks it visited.
  var done = readDone();
  if (TOUR.slug) {
    done[TOUR.slug] = 1;
    writeDone(done);
  }

  // Tick every visited lesson in the sidebar and the home overview.
  document.querySelectorAll('a[data-slug]').forEach(function (a) {
    if (done[a.getAttribute('data-slug')]) a.classList.add('done');
  });

  // Home page: offer to continue at the first unvisited lesson (only when some
  // progress exists and the tour isn't finished).
  var cont = document.getElementById('btn-continue');
  if (cont && TOUR.order.length) {
    var visited = TOUR.order.filter(function (s) { return done[s]; }).length;
    var next = TOUR.order.find(function (s) { return !done[s]; });
    if (visited > 0 && next) {
      cont.href = '/' + next + '/';
      cont.textContent = 'Continue at lesson ' + (TOUR.order.indexOf(next) + 1) + ' →';
      cont.hidden = false;
    }
  }

  // Reset progress — shown whenever any lesson is ticked; asks for a second
  // click (the label changes) instead of popping a dialog.
  var reset = document.getElementById('btn-reset');
  if (reset) {
    var anyDone = TOUR.order.some(function (s) { return done[s]; });
    reset.hidden = !anyDone;
    var armed = false;
    reset.addEventListener('click', function () {
      if (!armed) {
        armed = true;
        reset.textContent = 'Really reset?';
        reset.classList.add('armed');
        return;
      }
      try { localStorage.removeItem(KEY); } catch (e) {}
      document.querySelectorAll('a[data-slug].done').forEach(function (a) {
        a.classList.remove('done');
      });
      if (cont) cont.hidden = true;
      reset.hidden = true;
    });
  }

  // ←/→ walk the tour — but never while typing in an editor or input.
  document.addEventListener('keydown', function (e) {
    if (e.altKey || e.ctrlKey || e.metaKey || e.shiftKey) return;
    if (e.key !== 'ArrowLeft' && e.key !== 'ArrowRight') return;
    var t = e.target;
    if (t && t.closest && t.closest('[data-raku], .rakupp-embed, input, textarea, select, [contenteditable]')) return;
    if (!TOUR.slug) return;
    var i = TOUR.order.indexOf(TOUR.slug);
    if (i < 0) return;
    var dest = e.key === 'ArrowLeft' ? i - 1 : i + 1;
    if (dest < 0) { window.location.href = '/'; return; }
    if (dest >= TOUR.order.length) return;
    window.location.href = '/' + TOUR.order[dest] + '/';
  });

  // Mobile: hamburger toggles the sidebar drawer.
  var toggle = document.querySelector('.nav-toggle');
  var nav = document.querySelector('.sidebar');
  if (toggle) {
    toggle.addEventListener('click', function () {
      document.body.classList.toggle('nav-open');
    });
    if (nav) nav.addEventListener('click', function (e) {
      if (e.target.tagName === 'A') document.body.classList.remove('nav-open');
    });
  }

  // Keep the active lesson in view in the sidebar.
  var scroller = document.querySelector('.sidebar-nav');
  var active = scroller && scroller.querySelector('a.active');
  if (active && scroller) {
    var a = active.getBoundingClientRect();
    var n = scroller.getBoundingClientRect();
    if (a.top < n.top + 8 || a.bottom > n.bottom - 8) {
      scroller.scrollTop += (a.top - n.top) - (scroller.clientHeight - active.offsetHeight) / 2;
    }
  }
})();
