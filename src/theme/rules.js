// rules.js — the Rules sub-site adds a second level to the sidebar: a topic
// contains precedence-level sections, and a section contains constructs. The
// topic accordion is spec.js's job; this only toggles the sections inside the
// open topic, and points search.js at the Rules index instead of the spec's.
(function () {
  'use strict';

  document.querySelectorAll('.nav-sec-title').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var sec = btn.closest('.nav-sec');
      if (sec) sec.classList.toggle('open');
    });
  });

  // The verdict-history chart on /rules/divergences/. The page ships a static
  // SVG that stands on its own; when chart.js is present we replace it with the
  // site's shared interactive chart, so this graph behaves exactly like the ones
  // on /dashboard/ — crosshair, hover tooltip, data table. lineChart() clears the
  // host first, so the static fallback is what a reader without JS keeps.
  var hist = document.getElementById('rules-history');
  if (hist && window.SpecChart) {
    var raw = hist.getAttribute('data-history');
    var data = null;
    try { data = JSON.parse(raw); } catch (e) { data = null; }
    if (data && data.labels && data.labels.length > 1 && data.series) {
      // Names, order and colour CLASS all come from the page — the generator owns
      // that list (rules.raku's @series) so the interactive chart, the static
      // fallback under it and the dot legend above it can never disagree.
      var series = data.series.map(function (s) {
        return { name: s.key, cls: s.cls, values: s.values };
      });
      var max = 0;
      series.forEach(function (s) {
        s.values.forEach(function (v) { if (v > max) max = v; });
      });
      window.SpecChart.lineChart(hist, {
        labels: data.labels,
        series: series,
        yMax: window.SpecChart.niceMax(max || 1),
        yFmt: function (v) { return window.SpecChart.fmt(Math.round(v)); },
        height: 240, maxXLabels: 6,
        tipRow: function (si, i) {
          return series[si].name + ': ' + window.SpecChart.fmt(series[si].values[i]) + ' examples';
        }
      });
    }
  }

  // Reveal the open section on load even when it is far down a long list
  // (the operators topic alone runs to a couple of hundred entries).
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
