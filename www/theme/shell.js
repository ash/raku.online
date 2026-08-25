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

  var SECTIONS = [
    { href: '/play/',   label: 'Play',   hue: 'play'   },
    { href: '/tour/',   label: 'Tour',   hue: 'tour'   },
    { href: '/drills/', label: 'Drills', hue: 'drills' },
    { href: '/spec/',   label: 'Spec',   hue: 'spec'   },
    { href: '/grid/',   label: 'Grid',   hue: 'grid'   },
    { href: '/faq/',    label: 'FAQ',    hue: 'faq'    },
    { href: '/book/',   label: 'Book',   hue: 'book'   },
    { href: '/ecosystem/', label: 'Modules', hue: 'eco' }
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
    SECTIONS.forEach(function (s) {
      var a = el('a', { class: 'shell-tab', href: s.href, 'data-hue': s.hue }, s.label);
      if (path === s.href || path.indexOf(s.href) === 0) a.setAttribute('aria-current', 'page');
      nav.appendChild(a);
    });
    bar.appendChild(nav);

    bar.appendChild(el('span', { class: 'shell-spacer' }));

    // course.raku.org is a separate project on a separate domain, so it is
    // marked as leaving the site rather than dressed up as another tab.
    var course = el('a', { class: 'shell-out', href: 'https://course.raku.org' }, 'Course');
    course.appendChild(el('span', { class: 'arr' }, '↗'));
    bar.appendChild(course);

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
