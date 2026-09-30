/* Pace charts. A chapter asks for a chart by name —
     <figure class="pc-fig" data-chart="roast"></figure>
   — and this draws it from the section's data.json, which build.raku cuts from
   the spec dashboard's history so the two pages plot the same numbers. Charts
   are plain SVG with a hover tooltip, redrawn when the theme or width changes.
   Colours come from the page's tokens: series are --s1..--s3, Rakudo is always
   the dashed neutral, because it is the reference line rather than a series. */
(function () {
  var BASE = window.__SITE_BASE || '';
  var NS = 'http://www.w3.org/2000/svg';
  var DATA = null;

  function css(n) { return getComputedStyle(document.documentElement).getPropertyValue(n).trim(); }
  function el(tag, attrs, parent) {
    var e = document.createElementNS(NS, tag);
    for (var k in attrs) e.setAttribute(k, attrs[k]);
    if (parent) parent.appendChild(e);
    return e;
  }
  function day(s) { return Date.parse(s + 'T00:00:00Z') / 864e5; }
  function fmtDate(d) {
    var t = new Date(d * 864e5);
    return t.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', timeZone: 'UTC' });
  }
  // The axis top rounded up to a round multiple of a power of ten, so the
  // four gridlines land on readable values.
  function niceMax(v) {
    if (!(v > 0)) return 1;
    var p = Math.pow(10, Math.floor(Math.log10(v)));
    var steps = [1, 2, 2.5, 4, 5, 8, 10];
    for (var i = 0; i < steps.length; i++) if (steps[i] * p >= v) return steps[i] * p;
    return 10 * p;
  }
  function fmtNum(v) { return v >= 1000 ? Math.round(v).toLocaleString('en-US') : (v >= 100 ? v.toFixed(0) : v.toFixed(1)); }

  function tipFor(fig) {
    var t = fig.querySelector('.pc-tip');
    if (!t) { t = document.createElement('div'); t.className = 'pc-tip'; fig.appendChild(t); }
    return {
      show: function (ev, html) {
        t.innerHTML = html;
        var r = fig.getBoundingClientRect();
        var x = ev.clientX - r.left + 12, y = ev.clientY - r.top + 12;
        if (x + t.offsetWidth > r.width - 4) x = ev.clientX - r.left - t.offsetWidth - 12;
        t.style.left = Math.max(4, x) + 'px'; t.style.top = y + 'px'; t.style.opacity = 1;
      },
      hide: function () { t.style.opacity = 0; }
    };
  }

  // One line chart on a time axis. series: [{name, color, dash, pts:[{x,y,label}]}]
  function lineChart(fig, series, o) {
    var holder = fig.querySelector('.pc-plot') || fig.appendChild(Object.assign(document.createElement('div'), { className: 'pc-plot' }));
    holder.innerHTML = '';
    var W = Math.max(280, holder.clientWidth || 600), H = o.height || 260;
    var L = o.left || 52, R = 14, T = 14, B = 28;
    var all = [].concat.apply([], series.map(function (s) { return s.pts; }));
    var x0 = Math.min.apply(null, all.map(function (p) { return p.x; }));
    var x1 = Math.max.apply(null, all.map(function (p) { return p.x; }));
    if (x1 === x0) x1 = x0 + 1;
    var y0 = o.yMin != null ? o.yMin : 0;
    var y1 = o.yMax != null ? o.yMax : niceMax(Math.max.apply(null, all.map(function (p) { return p.y; })) * 1.05);
    var X = function (v) { return L + (v - x0) / (x1 - x0) * (W - L - R); };
    var Y = function (v) { return T + (1 - (v - y0) / (y1 - y0)) * (H - T - B); };
    var svg = el('svg', { viewBox: '0 0 ' + W + ' ' + H, width: W, height: H, role: 'img', 'aria-label': o.label || '' }, holder);

    var ticks = o.yTicks || 4;
    for (var i = 0; i <= ticks; i++) {
      var v = y0 + (y1 - y0) * i / ticks, y = Y(v);
      el('line', { x1: L, x2: W - R, y1: y, y2: y, stroke: css('--pc-grid'), 'stroke-width': 1 }, svg);
      el('text', { x: L - 6, y: y + 4, 'text-anchor': 'end', class: 'pc-ax' }, svg).textContent = (o.yFmt || fmtNum)(v);
    }
    // month starts on the x axis
    var d = new Date(x0 * 864e5); d.setUTCDate(1); d.setUTCMonth(d.getUTCMonth() + 1);
    for (; d.getTime() / 864e5 <= x1; d.setUTCMonth(d.getUTCMonth() + 1)) {
      var xm = X(d.getTime() / 864e5);
      el('line', { x1: xm, x2: xm, y1: T, y2: H - B, stroke: css('--pc-grid'), 'stroke-width': 1 }, svg);
      el('text', { x: xm + 4, y: H - B + 16, class: 'pc-ax' }, svg).textContent = d.toLocaleDateString('en-GB', { month: 'short', timeZone: 'UTC' });
    }
    el('line', { x1: L, x2: W - R, y1: H - B, y2: H - B, stroke: css('--pc-rule'), 'stroke-width': 1 }, svg);

    (o.marks || []).forEach(function (m) {
      var xm = X(day(m.date));
      el('line', { x1: xm, x2: xm, y1: T, y2: H - B, stroke: css('--pc-ink-3'), 'stroke-dasharray': '2 3', 'stroke-width': 1 }, svg);
      var nearEdge = xm > W - R - 40;   // a label near the right edge reads leftwards
      el('text', { x: nearEdge ? xm - 4 : xm + 4, y: T + 10 + (m.row || 0) * 13,
                   'text-anchor': nearEdge ? 'end' : 'start', class: 'pc-ax pc-mark' }, svg).textContent = m.text;
    });

    series.forEach(function (s) {
      var col = s.color;
      var dAttr = s.pts.map(function (p, j) { return (j ? (s.step ? 'H' + X(p.x) + 'V' : 'L') : 'M') + (s.step && j ? Y(p.y) : X(p.x) + ' ' + Y(p.y)); }).join(' ');
      el('path', { d: dAttr, fill: 'none', stroke: col, 'stroke-width': 2, 'stroke-dasharray': s.dash ? '5 4' : '', 'stroke-linejoin': 'round' }, svg);
      if (!s.noDots) s.pts.forEach(function (p) {
        el('circle', { cx: X(p.x), cy: Y(p.y), r: 3.5, fill: col, stroke: css('--bg'), 'stroke-width': 1.5 }, svg);
      });
    });

    // one hover column per distinct x, reporting every series at that x
    var xs = {};
    series.forEach(function (s) { s.pts.forEach(function (p) { (xs[p.x] = xs[p.x] || []).push({ s: s, p: p }); }); });
    var keys = Object.keys(xs).map(Number).sort(function (a, b) { return a - b; });
    var tip = tipFor(fig);
    keys.forEach(function (k, j) {
      var left = j ? (X(keys[j - 1]) + X(k)) / 2 : L, right = j < keys.length - 1 ? (X(k) + X(keys[j + 1])) / 2 : W - R;
      var hit = el('rect', { x: left, y: T, width: Math.max(1, right - left), height: H - T - B, fill: 'transparent' }, svg);
      hit.addEventListener('mousemove', function (ev) {
        var rows = xs[k].map(function (e) {
          return '<span class="sw" style="background:' + e.s.color + '"></span>' + e.s.name + ' ' + (o.tipFmt || fmtNum)(e.p.y, e.p);
        });
        var lab = xs[k].map(function (e) { return e.p.label; }).filter(Boolean)[0];
        tip.show(ev, '<b>' + (lab ? lab + ' · ' : '') + fmtDate(k) + '</b><br>' + rows.join('<br>'));
      });
      hit.addEventListener('mouseleave', tip.hide);
    });

    var leg = fig.querySelector('.pc-legend');
    if (!leg && series.length > 1) {
      leg = document.createElement('div'); leg.className = 'pc-legend';
      fig.insertBefore(leg, holder);
    }
    if (leg) leg.innerHTML = series.map(function (s) {
      return '<span><i style="background:' + s.color + (s.dash ? ';height:2px;border-radius:0;vertical-align:3px;width:14px' : '') + '"></i>' + s.name + '</span>';
    }).join('');
  }

  // ---- recipes ------------------------------------------------------------

  var RECIPES = {
    // Roast: files passing and tests passing, both as a share of what was
    // declared on the day, from the first commit to now.
    roast: function (fig) {
      var files = [], tests = [];
      DATA.dev.forEach(function (r) {
        files.push({ x: day(r.date), y: 100 * r.files_pass / 1464, label: r.tag });
      });
      DATA.releases.forEach(function (r) {
        files.push({ x: day(r.date), y: 100 * r.files / r.filesTotal, label: r.tag });
        tests.push({ x: day(r.date), y: 100 * r.tests / r.testsTotal, label: r.tag });
      });
      (DATA.readings || []).forEach(function (r) {
        // a reading may carry files, tests, or both
        if (r.files_pass) files.push({ x: day(r.date), y: 100 * r.files_pass / r.files_total, label: r.tag });
        if (r.tests_pass) tests.push({ x: day(r.date), y: 100 * r.tests_pass / r.tests_total, label: r.tag });
      });
      var byX = function (a, b) { return a.x - b.x; };
      files.sort(byX); tests.sort(byX);
      lineChart(fig, [
        { name: 'files passing completely', color: css('--pc-s1'), pts: files },
        { name: 'tests passing', color: css('--pc-s2'), pts: tests }
      ], { yMin: 0, yMax: 100, yFmt: function (v) { return v.toFixed(0) + '%'; },
           tipFmt: function (v) { return v.toFixed(1) + '%'; }, label: 'Roast over time',
           marks: fig.dataset.marks === 'no' ? [] : [
             { date: '2026-07-22', text: 'v1.0' },
             { date: '2026-08-07', text: 'v2.0', row: 1 },
             { date: '2026-09-17', text: 'v4.0' },
             { date: '2026-09-29', text: 'v5.0', row: 1 }] });
    },

    // One kernel across every release, interpreted (and optionally native),
    // with the Rakudo that was current on each release's day as the dashed line.
    bench: function (fig) {
      var k = fig.dataset.kernel, lanes = (fig.dataset.lanes || 'interp,rakudo').split(',');
      var names = { interp: 'Raku++ interpreted', native: 'Raku++ --exe', rakudo: 'Rakudo' };
      var colors = { interp: css('--pc-s1'), native: css('--pc-s2'), rakudo: css('--pc-ink-3') };
      var series = lanes.map(function (lane) {
        var pts = DATA.releases.filter(function (r) { return r.bench[k] && r.bench[k][lane] != null; })
          .map(function (r) { return { x: day(r.date), y: r.bench[k][lane], label: r.tag }; });
        return { name: names[lane], color: colors[lane], dash: lane === 'rakudo', noDots: lane === 'rakudo', step: lane === 'rakudo', pts: pts };
      }).filter(function (s) { return s.pts.length; });
      lineChart(fig, series, { height: +fig.dataset.height || 220, yMin: 0,
        yFmt: function (v) { return v.toFixed(0) + ' ms'; }, tipFmt: function (v) { return fmtNum(v) + ' ms'; },
        label: k + ' across releases' });
    },

    conformance: function (fig) {
      lineChart(fig, [{ name: 'documentation examples identical on both engines', color: css('--pc-s1'),
        pts: DATA.conformance.map(function (r) { return { x: day(r.date), y: r.ok }; }) },
        { name: 'examples where Raku++ is the one that is wrong', color: css('--pc-s3'),
        pts: DATA.conformance.map(function (r) { return { x: day(r.date), y: r.differs }; }) }],
        { yMin: 0, label: 'Documentation conformance' });
    },

    ecosystem: function (fig) {
      lineChart(fig, [{ name: 'distributions passing their own test suites', color: css('--pc-s1'),
        pts: DATA.sweep.map(function (r) { return { x: day(r.date), y: r.n }; }) }],
        { yMin: 0, label: 'Ecosystem sweep',
          tipFmt: function (v, p) { return fmtNum(v); } });
    },

    'exe-size': function (fig) {
      var s = DATA.exeSize || [];
      var full = s.filter(function (r) { return r.full; }).map(function (r) { return { x: day(r.date), y: r.full / 1e6, label: r.tag }; });
      var slim = s.filter(function (r) { return r.slim; }).map(function (r) { return { x: day(r.date), y: r.slim / 1e6, label: r.tag }; });
      lineChart(fig, [{ name: '--exe', color: css('--pc-s1'), pts: full }, { name: '--exe --slim', color: css('--pc-s2'), pts: slim }],
        { yMin: 0, yFmt: function (v) { return v.toFixed(0) + ' MB'; }, tipFmt: function (v) { return v.toFixed(2) + ' MB'; },
          label: 'say "Hello" compiled' });
    }
  };

  function drawAll() {
    if (!DATA) return;
    document.querySelectorAll('.pc-fig[data-chart]').forEach(function (fig) {
      var r = RECIPES[fig.dataset.chart];
      if (r) r(fig);
    });
  }

  var figs = document.querySelectorAll('.pc-fig[data-chart]');
  if (figs.length) {
    fetch(BASE + '/data.json').then(function (r) { return r.json(); }).then(function (d) { DATA = d; drawAll(); });
    new MutationObserver(drawAll).observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme-active'] });
    var w = window.innerWidth;
    window.addEventListener('resize', function () { if (Math.abs(window.innerWidth - w) > 40) { w = window.innerWidth; drawAll(); } });
  }
})();
