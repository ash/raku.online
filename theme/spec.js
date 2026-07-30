// spec.js — tiny bits of page chrome. The runnable editors are handled entirely
// by raku.js (loaded after this); this wires the mobile nav toggle and reveals
// the current page in the sidebar.
(function () {
  'use strict';
  var nav = document.querySelector('.sidebar');

  var toggle = document.querySelector('.nav-toggle');
  if (toggle) {
    toggle.addEventListener('click', function () {
      document.body.classList.toggle('nav-open');
    });
    // Close the drawer after following a link on mobile.
    if (nav) nav.addEventListener('click', function (e) {
      if (e.target.tagName === 'A') document.body.classList.remove('nav-open');
    });
  }

  // Accordion sidebar: clicking a section title opens it and closes the others,
  // so only one section is expanded at a time. The current page's section starts
  // open (marked server-side).
  var cats = document.querySelectorAll('.nav-cat');
  function eachCat(fn) { Array.prototype.forEach.call(cats, fn); }
  eachCat(function (cat) {
    var btn = cat.querySelector('.nav-cat-title');
    if (!btn) return;
    btn.addEventListener('click', function () {
      var wasOpen = cat.classList.contains('open');
      eachCat(function (c) {
        c.classList.remove('open');
        var b = c.querySelector('.nav-cat-title');
        if (b) b.setAttribute('aria-expanded', 'false');
      });
      if (!wasOpen) {
        cat.classList.add('open');
        btn.setAttribute('aria-expanded', 'true');
      }
    });
  });

  // Copy buttons on static (non-runnable) examples: copy the sibling code
  // block's text. navigator.clipboard needs a secure context (the site is
  // https); the execCommand fallback covers file:// previews.
  document.addEventListener('click', function (e) {
    var btn = e.target.closest ? e.target.closest('.copy-btn') : null;
    if (!btn) return;
    var box = btn.parentElement && btn.parentElement.querySelector('pre code');
    if (!box) return;
    var text = box.textContent;
    function done(ok) {
      if (!ok) return;
      btn.classList.add('copied');
      var label = btn.textContent;
      btn.textContent = 'Copied';
      setTimeout(function () { btn.classList.remove('copied'); btn.textContent = label; }, 1400);
    }
    function fallback() {
      var ta = document.createElement('textarea');
      ta.value = text;
      ta.style.position = 'fixed';
      ta.style.opacity = '0';
      document.body.appendChild(ta);
      ta.select();
      var ok = false;
      try { ok = document.execCommand('copy'); } catch (err) { ok = false; }
      document.body.removeChild(ta);
      done(ok);
    }
    if (navigator.clipboard && navigator.clipboard.writeText) {
      // a rejected write (permission policy) still gets the legacy path
      navigator.clipboard.writeText(text).then(function () { done(true); }, fallback);
    } else {
      fallback();
    }
  });

  // Scroll the nav list (not the page, and not the pinned head) so the current
  // page's entry — and its siblings in the same section — are in view on load.
  var scroller = document.querySelector('.sidebar-nav');
  var active = scroller && scroller.querySelector('a.active');
  if (active && scroller) {
    var a = active.getBoundingClientRect();
    var n = scroller.getBoundingClientRect();
    // Only adjust when the active item isn't already comfortably visible.
    if (a.top < n.top + 8 || a.bottom > n.bottom - 8) {
      scroller.scrollTop += (a.top - n.top) - (scroller.clientHeight - active.offsetHeight) / 2;
    }
  }
})();
