/* boot.js — theme resolution, shared by every hand-written page.
   Must run before first paint (it sets html[data-theme-active]), so it is a
   blocking script in <head>, not deferred. The generated sites inline the
   same logic from their page-shell. */
(function () {
  var KEY = 'raku-theme';
  var mql = window.matchMedia('(prefers-color-scheme: dark)');
  var ICON = { system: '◐', light: '☀', dark: '☾' };
  function stored() { try { return localStorage.getItem(KEY) || 'system'; } catch (e) { return 'system'; } }
  function effective(s) { return (s === 'dark' || (s === 'system' && mql.matches)) ? 'dark' : 'light'; }
  function apply(s) {
    var d = document.documentElement;
    d.setAttribute('data-theme', s);
    d.setAttribute('data-theme-active', effective(s));
    var btn = document.querySelector('.theme-btn');
    if (btn) btn.textContent = ICON[s] || ICON.system;
    document.querySelectorAll('.theme-menu [data-theme-set]').forEach(function (el) {
      el.setAttribute('aria-checked', el.getAttribute('data-theme-set') === s ? 'true' : 'false');
    });
  }
  apply(stored());
  mql.addEventListener('change', function () { if (stored() === 'system') apply('system'); });
  window.__setTheme = function (s) { try { localStorage.setItem(KEY, s); } catch (e) {} apply(s); };
  document.addEventListener('DOMContentLoaded', function () {
    apply(stored());
    var sw = document.querySelector('.theme-switch');
    if (!sw) return;
    var btn = sw.querySelector('.theme-btn'), menu = sw.querySelector('.theme-menu');
    function open(o) { menu.hidden = !o; btn.setAttribute('aria-expanded', o ? 'true' : 'false'); }
    btn.addEventListener('click', function (e) { e.stopPropagation(); open(menu.hidden); });
    menu.addEventListener('click', function (e) {
      var b = e.target.closest('[data-theme-set]');
      if (b) { window.__setTheme(b.getAttribute('data-theme-set')); open(false); btn.focus(); }
    });
    document.addEventListener('click', function (e) { if (!sw.contains(e.target)) open(false); });
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && !menu.hidden) { e.stopPropagation(); open(false); btn.focus(); } });
  });
})();
