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
    { href: '/spec/',   label: 'Spec',   hue: 'spec'   }
  ];

  // Stamped by build.sh from `rakupp --version` so the bar can never claim a
  // version the deployed engine is not.
  var ENGINE = 'Raku++ __RAKUPP_VERSION__';

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

    // The theme switcher floats over the bar's right end; keep clear of it.
    bar.appendChild(el('span', { class: 'shell-pad' }));

    document.body.insertBefore(bar, document.body.firstChild);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', build);
  } else {
    build();
  }
})();
