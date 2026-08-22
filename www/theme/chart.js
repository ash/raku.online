// chart.js — the site's one line-chart renderer, shared by every page that draws
// a time series (the dashboard's Roast/conformance/module charts and the Rules
// sub-site's verdict history). Extracted from dashboard.js so the two are the
// SAME chart — same marks, same crosshair, same tooltip, same data table —
// rather than two drawings that drift apart.
//
// Theme-aware: every colour comes from a CSS variable, so the light/dark toggle
// restyles a drawn chart with no re-render. No external dependencies.
//
// Exposes window.SpecChart = { lineChart, niceMax, tickCount, fmt, el, div }.
// Load it BEFORE any script that calls it (document order is enough — every
// consumer is `defer`).
(function () {
  'use strict';

  var NS = 'http://www.w3.org/2000/svg';
  function el(name, attrs, parent) {
    var n = document.createElementNS(NS, name);
    for (var k in attrs) n.setAttribute(k, attrs[k]);
    if (parent) parent.appendChild(n);
    return n;
  }
  function div(cls, parent, text) {
    var n = document.createElement('div');
    n.className = cls;
    if (text != null) n.textContent = text;
    if (parent) parent.appendChild(n);
    return n;
  }
  function fmt(n) { return String(n).replace(/\B(?=(\d{3})+(?!\d))/g, ','); }

  // One shared tooltip element for every chart, created on first use so a page
  // that loads this module without drawing anything adds nothing to the DOM.
  var tip = null;
  function showTip(html, x, y) {
    if (!tip) { tip = div('dash-tip', document.body); }
    tip.innerHTML = html;
    tip.hidden = false;
    var r = tip.getBoundingClientRect();
    var left = Math.min(x + 14, window.innerWidth - r.width - 8);
    tip.style.left = (left + window.scrollX) + 'px';
    tip.style.top = (y - r.height - 12 + window.scrollY) + 'px';
  }
  function hideTip() { if (tip) tip.hidden = true; }

  // ---- line chart -------------------------------------------------------
  // opts: { labels: [x labels], series: [{name, cls, dash?, values: [num|null]}],
  //         yMax, yFmt(v), tipRow(seriesIdx, ptIdx) -> string, height? }
  // Mark spec: 2px lines, small round markers, hairline grid, 0-based y axis.
  // Interaction: nearest-point crosshair + tooltip. Identity: legend chips for
  // >=2 series plus a direct label at each line's end (ink text, colored dot).
  // Round a data maximum up to a "nice" axis maximum (1/2/2.5/4/5/8 × 10^k) —
  // the tightest nice ceiling, so lines fill the plot instead of sitting in
  // the bottom half under empty headroom.
  function niceMax(v) {
    var p = Math.pow(10, Math.floor(Math.log10(v)));
    var m = v / p;
    var f = m <= 1 ? 1 : m <= 2 ? 2 : m <= 2.5 ? 2.5 : m <= 4 ? 4 : m <= 5 ? 5 : m <= 8 ? 8 : 10;
    return f * p;
  }
  // Prefer a tick count whose step is itself nice (integers on small axes).
  function tickCount(yMax) {
    var counts = [5, 4], best = 4;
    for (var i = 0; i < counts.length; i++) {
      var s = yMax / counts[i];
      var m = s / Math.pow(10, Math.floor(Math.log10(s)));
      if ([1, 2, 2.5, 5].some(function (f) { return Math.abs(m - f) < 1e-9; })) { best = counts[i]; break; }
    }
    return best;
  }

  function lineChart(host, opts) {
    // inherit the replaced chart's accessible name unless the caller gave one
    if (!opts.label) {
      var was = host.querySelector('svg[aria-label]');
      if (was) opts.label = was.getAttribute('aria-label');
    }
    host.textContent = '';
    var n = opts.labels.length;
    var W = opts.width || 720, H = opts.height || 240;
    var padL = 46, padR = 30, padT = 12, padB = 26;
    var iw = W - padL - padR, ih = H - padT - padB;
    var X = function (i) { return padL + (n === 1 ? iw / 2 : i * iw / (n - 1)); };
    var Y = function (v) { return padT + ih - (v / opts.yMax) * ih; };

    if (opts.series.length > 1) {
      var leg = div('dash-legend', host);
      opts.series.forEach(function (s) {
        var chip = div('dash-chip', leg);
        div('dash-swatch ' + s.cls + (s.dash ? ' dashed' : ''), chip);
        var t = document.createElement('span');
        t.textContent = s.name;
        chip.appendChild(t);
      });
    }

    // role="img" prunes the subtree from the accessibility tree, so the chart is
    // only as accessible as its NAME plus the data table below it. Take the name
    // from the caller, or from the aria-label of whatever static SVG we are
    // replacing — dropping it was a regression on the Rules page, which shipped
    // one on its build-time chart.
    var svg = el('svg', { viewBox: '0 0 ' + W + ' ' + H, 'class': 'dash-svg', role: 'img' }, host);
    if (opts.label) svg.setAttribute('aria-label', opts.label);

    // grid + y ticks (recessive hairlines, muted ink)
    var ticks = tickCount(opts.yMax);
    for (var t = 0; t <= ticks; t++) {
      var v = opts.yMax * t / ticks;
      var y = Y(v);
      el('line', { x1: padL, x2: W - padR, y1: y, y2: y, 'class': 'dash-grid' }, svg);
      el('text', { x: padL - 6, y: y + 3.5, 'text-anchor': 'end', 'class': 'dash-tick' }, svg)
        .textContent = opts.yFmt(v);
    }
    // x labels — thin them out when the chart is narrow
    // The axis gets the SHORT form of each label; the tooltip and the data
    // table get the full one. A dated bench sitting reads "Aug 22" on the axis
    // and "Aug 22 · 363c4b6" everywhere there is room for the commit, so two
    // sittings on one date stay tellable apart without crowding the ticks.
    var tickLabels = opts.tickLabels || opts.labels;
    var every = Math.max(1, Math.ceil(n / (opts.maxXLabels || n)));
    tickLabels.forEach(function (lab, i) {
      if (i % every && i !== n - 1) return;
      if (i === n - 1 && (n - 1) % every && n > 2) {
        // keep the final label from crowding its predecessor
        var prev = Math.floor((n - 2) / every) * every;
        if (X(i) - X(prev) < 46) return;
      }
      el('text', { x: X(i), y: H - 8, 'text-anchor': 'middle', 'class': 'dash-tick' }, svg)
        .textContent = lab;
    });

    // series lines + markers
    opts.series.forEach(function (s) {
      var d = '';
      s.values.forEach(function (v, i) {
        if (v == null) return;
        d += (d ? ' L' : 'M') + X(i).toFixed(1) + ' ' + Y(v).toFixed(1);
      });
      var line = el('path', { d: d, 'class': 'dash-line ' + s.cls }, svg);
      if (s.dash) line.classList.add('dashed');
      s.values.forEach(function (v, i) {
        if (v == null) return;
        el('circle', { cx: X(i), cy: Y(v), r: 3, 'class': 'dash-dot ' + s.cls }, svg);
      });
    });

    // crosshair (hidden until hover)
    var cross = el('line', { y1: padT, y2: padT + ih, 'class': 'dash-cross' }, svg);
    cross.style.display = 'none';

    svg.addEventListener('mousemove', function (e) {
      var r = svg.getBoundingClientRect();
      var mx = (e.clientX - r.left) * (W / r.width);
      var i = Math.round((mx - padL) / (n === 1 ? 1 : iw / (n - 1)));
      i = Math.max(0, Math.min(n - 1, i));
      cross.style.display = '';
      cross.setAttribute('x1', X(i));
      cross.setAttribute('x2', X(i));
      var rows = opts.series.map(function (s, si) {
        if (s.values[i] == null) return '';
        return '<div class="dash-tip-row"><span class="dash-swatch ' + s.cls +
               (s.dash ? ' dashed' : '') + '"></span>' + opts.tipRow(si, i) + '</div>';
      }).join('');
      showTip('<div class="dash-tip-head">' + opts.labels[i] + '</div>' + rows,
              e.clientX, e.clientY);
    });
    svg.addEventListener('mouseleave', function () {
      cross.style.display = 'none';
      hideTip();
    });

    // table view (the accessibility/relief channel)
    var det = document.createElement('details');
    det.className = 'dash-table';
    var sum = document.createElement('summary');
    sum.textContent = 'Data table';
    det.appendChild(sum);
    var tbl = document.createElement('table');
    var thead = '<tr><th></th>' + opts.series.map(function (s) {
      return '<th>' + s.name + '</th>';
    }).join('') + '</tr>';
    var rows = opts.labels.map(function (lab, i) {
      return '<tr><td>' + lab + '</td>' + opts.series.map(function (s, si) {
        return '<td>' + (s.values[i] == null ? '—' : opts.tipRow(si, i).replace(/^.*?: /, '')) + '</td>';
      }).join('') + '</tr>';
    }).join('');
    tbl.innerHTML = '<thead>' + thead + '</thead><tbody>' + rows + '</tbody>';
    det.appendChild(tbl);
    host.appendChild(det);
  }

  window.SpecChart = {
    lineChart: lineChart,
    niceMax: niceMax,
    tickCount: tickCount,
    fmt: fmt,
    el: el,
    div: div
  };
})();
