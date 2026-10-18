/* shell.js — the site-wide bar for raku.online.
 *
 * Every page includes this and gets the same navigation, so the markup lives in
 * exactly one place rather than being pasted into two Raku generators and four
 * hand-written pages. shell.css reserves the bar's height up front, so injecting
 * it here shifts nothing.
 *
 * The active section is read from the path: /play/… highlights Play, and so on.
 * Nothing else about the host page is touched — the tour and spec keep their own
 * sidebars, the playground keeps its toolbar. This bar only answers "which room
 * am I in".
 */
(function () {
  'use strict';

  // Eighteen sections no longer fit in one row even on a laptop, so all but the
  // two "get started" tabs and Support live in groups: a group is one button in
  // the bar that opens a panel of its sections, each with a line saying what is
  // behind it. A group lights up in the colour of whichever of its sections you
  // are in, so the bar still answers "which room am I in" at a glance.
  var SECTIONS = [
    { href: '/play/',   label: 'Play',   hue: 'play'   },
    // Next to Play on purpose: those two are the whole of "get started", and
    // they are the pair — Play runs it with nothing installed, Install takes it
    // home. Everything after them is a room you go to once you have one or the
    // other. /install.sh is a file, not a section, and does not light this up.
    { href: '/install/', label: 'Install', hue: 'install' },
    { label: 'Learn', items: [
      { href: '/tour/',     label: 'Tour',     hue: 'tour',   note: 'Eighteen short lessons, live code' },
      { href: '/drills/',   label: 'Drills',   hue: 'drills', note: 'Practice questions' },
      { href: '/cookbook/', label: 'Cookbook', hue: 'cook',   note: 'Whole tasks, worked end to end' },
      { href: '/faq/',      label: 'FAQ',      hue: 'faq',    note: 'Task-shaped answers' },
      // course.raku.org is a separate project on a separate domain, so it is
      // marked as leaving the site rather than dressed up as another section.
      { href: 'https://course.raku.org', label: 'Course', out: true, note: 'course.raku.org' }
    ] },
    // The rooms that show the language in use. The hub is the first entry, and
    // the group stays lit in all of them, so it reads as one place with shelves.
    { label: 'In use', items: [
      { href: '/in-use/',   label: 'Overview', hue: 'inuse', note: 'Adoptions, and everything below' },
      { href: '/examples/', label: 'Examples', hue: 'inuse', note: 'Raku by example, one program a page' },
      { href: '/showcase/', label: 'Showcase', hue: 'inuse', note: 'Projects built on Raku++' },
      { href: '/live/',     label: 'Live',     hue: 'inuse', note: 'Existing tools, run unmodified' },
      { href: '/webraku/',  label: 'Webraku',  hue: 'inuse', note: 'Web apps in one Raku program, live' }
    ] },
    // Raku inside something else: your editor, software you use rather than
    // write (a web page, a WordPress blog, a spreadsheet), and finally another
    // language's program through librakupp. /embed/ is a prefix match, so it
    // stays lit on /embed/js/ and /embed/wordpress/ as well.
    { label: 'Integrate', items: [
      { href: '/editors/',  label: 'Editors', hue: 'editors',  note: 'VS Code, Emacs, Neovim, Jupyter, agents' },
      { href: '/embed/',    label: 'Embed',   hue: 'embed',    note: 'Web pages, WordPress, spreadsheets' },
      { href: '/bindings/', label: 'SDK',     hue: 'bindings', note: 'Python, JS, Go, Rust, C++, Wolfram' }
    ] },
    { label: 'Reference', items: [
      { href: '/spec/',    label: 'Spec',    hue: 'spec', note: 'The Raku++ specification' },
      { href: '/modules/', label: 'Modules', hue: 'eco',  note: 'raku.land distributions that run' },
      { href: '/grid/',    label: 'Grid',    hue: 'grid', note: 'Every recorded test on every engine' },
      { href: '/map/',     label: 'Map',     hue: 'map',  note: 'Rakudo and Raku++, program by program' }
    ] },
    // Pace is the project's history, chapter by chapter, so it opens the reading
    // shelf: the story first, then the books. Deep is Raku Behind the Docs, the
    // verified-behaviour book, built in its own repository and copied in by
    // `build.sh deep`.
    { label: 'Read', items: [
      { href: '/pace/', label: 'Pace', hue: 'pace', note: 'The project, chapter by chapter' },
      { href: '/book/', label: 'Book', hue: 'book', note: 'Raku++ Internals, the compiler book' },
      { href: '/deep/', label: 'Deep', hue: 'deep', note: 'Raku Behind the Docs' }
    ] },
    // Last, as the way out of the reading rooms: where to ask when something
    // breaks — GitHub issues, or DeepSoft's commercial support.
    { href: '/support/', label: 'Support', hue: 'support' }
  ];

  // Deliberately not stamped at build time. The version that matters is the one
  // in www/rakujs.wasm, which is not extractable from the artifact and drifts
  // from whatever rakupp is on PATH — a newer CLI can build the site long before
  // the WebAssembly is rebuilt, and the bar would then name a version nobody is
  // running. raku.js publishes the real one when the engine reports ready; until
  // then, and on pages that load no engine, the chip just says Raku++.
  var ENGINE = 'Raku++';

  function el(tag, attrs, text) {
    var n = document.createElement(tag);
    for (var k in attrs) if (attrs[k] != null) n.setAttribute(k, attrs[k]);
    if (text != null) n.appendChild(document.createTextNode(text));
    return n;
  }

  function here(path, href) {
    return path === href || path.indexOf(href) === 0;
  }

  function hue(n, h) { if (h) n.style.setProperty('--h', 'var(--hue-' + h + ')'); }

  // One entry in a group's panel: a dot in the section's colour, its name, and
  // a line on what is behind it.
  function item(s, path) {
    var a = el('a', { class: 'shell-item', href: s.href });
    hue(a, s.hue);
    a.appendChild(el('span', { class: 'dot', 'aria-hidden': 'true' }, s.out ? '↗' : null));
    a.appendChild(el('span', { class: 't' }, s.label));
    if (s.note) a.appendChild(el('span', { class: 'd' }, s.note));
    if (s.out) a.classList.add('out');
    else if (here(path, s.href)) a.setAttribute('aria-current', 'page');
    return a;
  }

  function build() {
    if (document.querySelector('.shell')) return;      // already there

    var path = location.pathname;
    var bar = el('nav', { class: 'shell', 'aria-label': 'Site' });

    var mark = el('a', { class: 'shell-mark', href: '/' });
    mark.appendChild(document.createTextNode('Raku'));
    mark.appendChild(el('span', { class: 'tld' }, '.online'));
    // Only the root itself is "the home page"; /play/ is not.
    if (path === '/' || path === '/index.html') mark.setAttribute('aria-current', 'page');
    bar.appendChild(mark);

    var nav = el('div', { class: 'shell-nav' });
    var groups = [];
    SECTIONS.forEach(function (s, i) {
      if (!s.items) {
        var a = el('a', { class: 'shell-tab', href: s.href }, s.label);
        hue(a, s.hue);
        if (here(path, s.href)) a.setAttribute('aria-current', 'page');
        nav.appendChild(a);
        return;
      }
      // The panel is a child of the bar, not of the button's row: the row
      // scrolls sideways on phones, and anything inside an overflow box is
      // clipped by it. open() lines the panel up under its button instead.
      var id = 'shell-menu-' + i;
      var btn = el('button', { class: 'shell-tab shell-group', type: 'button',
                               'aria-expanded': 'false', 'aria-controls': id }, s.label);
      btn.appendChild(el('span', { class: 'caret', 'aria-hidden': 'true' }));
      var panel = el('div', { class: 'shell-menu', id: id });
      panel.hidden = true;
      s.items.forEach(function (it) {
        var a = item(it, path);
        if (a.getAttribute('aria-current')) {
          btn.setAttribute('aria-current', 'page');
          hue(btn, it.hue);
        }
        panel.appendChild(a);
      });
      nav.appendChild(btn);
      groups.push({ btn: btn, panel: panel });
    });
    bar.appendChild(nav);
    groups.forEach(function (g) { bar.appendChild(g.panel); });

    bar.appendChild(el('span', { class: 'shell-spacer' }));

    var engine = el('a', { class: 'shell-engine', href: '/rakupp/' }, ENGINE);
    if (path.indexOf('/rakupp/') === 0) engine.setAttribute('aria-current', 'page');
    bar.appendChild(engine);

    function name(v) { engine.textContent = v ? ENGINE + ' ' + v : ENGINE; }
    if (window.__RAKUPP_VERSION) name(window.__RAKUPP_VERSION);
    else window.addEventListener('rakupp:ready', function (e) {
      name(e.detail && e.detail.version);
    });

    document.body.insertBefore(bar, document.body.firstChild);

    // Give the theme switcher one home. Every page already ships the same
    // .theme-switch markup and the inline boot script has bound its listeners
    // by now (it registers its DOMContentLoaded handler from <head>, before
    // this deferred script registers ours), so moving the node keeps them —
    // listeners live on the element, not on its position in the document.
    var sw = document.querySelector('.theme-switch');
    if (sw) bar.appendChild(sw);

    // The groups behave like a desktop menu bar: a click opens one, and while
    // one is open, pointing at another switches to it. Escape, a click
    // anywhere else, or tabbing away closes it.
    var open = null;

    function close(refocus) {
      if (!open) return;
      open.panel.hidden = true;
      open.btn.setAttribute('aria-expanded', 'false');
      if (refocus) open.btn.focus();
      open = null;
    }

    function show(g) {
      if (open === g) return;
      close();
      g.panel.hidden = false;
      g.btn.setAttribute('aria-expanded', 'true');
      var r = g.btn.getBoundingClientRect();
      var w = g.panel.offsetWidth;
      g.panel.style.left = Math.max(8, Math.min(r.left, window.innerWidth - w - 8)) + 'px';
      open = g;
    }

    function links(g) { return Array.prototype.slice.call(g.panel.querySelectorAll('a')); }

    groups.forEach(function (g) {
      g.btn.addEventListener('click', function () {
        if (open === g) close(); else show(g);
      });
      g.btn.addEventListener('mouseenter', function () {
        if (open && open !== g) show(g);
      });
      g.btn.addEventListener('keydown', function (e) {
        if (e.key === 'ArrowDown') {
          e.preventDefault();
          show(g);
          links(g)[0].focus();
        }
      });
      g.panel.addEventListener('keydown', function (e) {
        if (e.key !== 'ArrowDown' && e.key !== 'ArrowUp') return;
        e.preventDefault();
        var all = links(g), k = all.indexOf(document.activeElement);
        k = e.key === 'ArrowDown' ? Math.min(k + 1, all.length - 1) : k - 1;
        if (k < 0) g.btn.focus(); else all[k].focus();
      });
      [g.btn, g.panel].forEach(function (n) {
        n.addEventListener('focusout', function (e) {
          var to = e.relatedTarget;
          if (open === g && to && !g.btn.contains(to) && !g.panel.contains(to)) close();
        });
      });
    });

    document.addEventListener('click', function (e) {
      if (open && !open.btn.contains(e.target) && !open.panel.contains(e.target)) close();
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && open) close(true);
    });
    // The panel is placed once, under its button; if the row scrolls or the
    // window changes width it would be left pointing at the wrong place.
    nav.addEventListener('scroll', function () { close(); });
    window.addEventListener('resize', function () { close(); });

    // The tab row scrolls on narrow screens; make sure the section you are in
    // is not the one hiding past the edge. Last, so the row is measured with
    // the theme switcher already in the bar. block:'nearest' keeps the page's
    // own scroll position untouched.
    var cur = nav.querySelector('[aria-current="page"]');
    if (cur && cur.scrollIntoView) cur.scrollIntoView({ block: 'nearest', inline: 'nearest' });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', build);
  } else {
    build();
  }
})();
