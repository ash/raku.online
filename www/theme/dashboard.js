// dashboard.js — renders /dashboard.json into stat tiles and SVG line charts.
// Only runs on the dashboard page (guarded on the container). The drawing is
// chart.js's job (window.SpecChart), which must be loaded first; this file is
// the dashboard's DATA layer — what to fetch, which series, how to label them.
(function () {
  'use strict';
  var tiles = document.getElementById('dash-tiles');
  if (!tiles) return;

  var me = document.currentScript || [].slice.call(document.scripts).pop();
  // The DATA's tag when the page carries one, else this script's own. Falling
  // back to our own ?v= means the THEME hash, which does not move when only the
  // numbers change — so a data-only release left the URL identical and every
  // returning visitor kept a cached dashboard. The page stamps __DASH_VER from
  // the content of dashboard.json (see sites/spec/build.raku).
  var ver = window.__DASH_VER ||
            (me && me.src.match(/\?v=([0-9a-f]+)/) || [])[1];

  // The chart renderer lives in chart.js so the Rules sub-site draws the SAME
  // chart from the same code. This page only supplies data. chart.js is a hard
  // dependency (this file has no drawing of its own left), so say so out loud
  // rather than leaving a blank page to be puzzled over — and see the theme-asset
  // check in .github/workflows/pages.yml, which stops a missing one from shipping.
  var SC = window.SpecChart;
  if (!SC) {
    console.error('dashboard.js: /theme/chart.js did not load — no charts or tiles');
    return;
  }
  var el = SC.el, div = SC.div, fmt = SC.fmt;
  var lineChart = SC.lineChart, niceMax = SC.niceMax;

  fetch((window.__SITE_BASE || '') + '/dashboard.json' + (ver ? '?v=' + ver : ''))
    .then(function (r) { return r.json(); })
    .then(function (data) {
      var rel = data.releases;
      var last = rel[rel.length - 1];

      // ---- stat tiles --------------------------------------------------
      function tile(n, l) {
        var t = div('conf-stat', tiles);
        div('conf-stat-n', t, n);
        div('conf-stat-l', t, l);
      }
      tile((100 * last.tests_pass / last.tests_total).toFixed(1) + '%',
           'declared Roast tests passing — ' + fmt(last.tests_pass) + ' / ' + fmt(last.tests_total));
      tile(fmt(last.files_pass) + ' / ' + fmt(last.files_total), 'Roast files fully passing');
      // The one ecosystem number: the whole-ecosystem sweep. The curated battery
      // that measuring started with stays a per-release gate in the rakupp
      // repo, not a public statistic.
      var sweep = data.sweep || [];
      var lastSweep = sweep.length ? sweep[sweep.length - 1] : null;
      if (lastSweep) tile(fmt(lastSweep.n) + ' / ' + fmt(lastSweep.total), 'Raku ecosystem dists passing their own suites');
      // Only the version-tagged entries count: the series also carries dated
      // points for past `main` sittings (a re-measure between releases), which
      // are readings, not releases.
      var releases = rel.filter(function (r) { return /^v[0-9]/.test(r.tag); });
      tile(String(releases.length), 'releases tracked (plus main)');

      // ---- Roast charts ------------------------------------------------
      // Two measures on two scales — so two charts, never one dual axis.
      // Tests passing is a share (%); fully-passing files is a COUNT: as a
      // share of the suite the strict all-or-nothing bar reads as "failing",
      // which is the wrong impression — the count rising is the fact.
      // Both series are prefixed with the pre-release daily points mined from
      // ROAST.md's git history; the % series starts only where the modern
      // "declared" denominator applies (the miner already filtered the rest).
      var dev = data.dev || [];
      var span = dev.concat(rel);
      var devCount = dev.length;
      // A point between releases is a DATE, and a date can hold more than one
      // sitting — so where the generator recorded which commit was measured,
      // the label carries it next to the date. Releases are named by their tag
      // and need no hash. The axis shows the short form (see tickLabels).
      function fullLabel(r) {
        return r.commit ? r.tag + ' \u00b7 ' + r.commit : r.tag;
      }
      var tagLabels = rel.map(fullLabel);
      var tagTicks = rel.map(function (r) { return r.tag; });
      var spanLabels = span.map(fullLabel);
      var spanTicks = span.map(function (r) { return r.tag; });
      var testsPct = span.map(function (r) {
        return r.tests_total ? 100 * r.tests_pass / r.tests_total : null;
      });
      var filesN = span.map(function (r) { return r.files_pass; });
      var roast = document.getElementById('dash-roast');
      roast.textContent = '';
      function preTag(i) { return i < devCount ? ' · pre-release' : ''; }

      var cardA = div('dash-bench-card', roast);
      div('dash-card-title', cardA, 'declared tests passing');
      lineChart(div('dash-chart', cardA), {
        labels: spanLabels,
        tickLabels: spanTicks,
        series: [{ name: 'declared tests passing', cls: 's1', values: testsPct }],
        yMax: 100,
        yFmt: function (v) { return v + '%'; },
        width: 380, height: 230, maxXLabels: 5,
        tipRow: function (si, i) {
          var r = span[i];
          var note = r && r.rebaselined ? ' · wider pre-2026-07-10 denominator' : '';
          return 'tests: ' + testsPct[i].toFixed(1) + '% (' + fmt(r.tests_pass) + ' / ' + fmt(r.tests_total) + ')' + preTag(i) + note;
        }
      });
      if (span.some(function (r) { return r && r.rebaselined; })) {
        div('dash-note', cardA,
          'The earliest declared-% point (2026-07-09) is measured against a wider ' +
          'denominator that was redefined the next day — the step to 2026-07-10 is that ' +
          're-baseline, not a real jump.');
      }

      var cardB = div('dash-bench-card', roast);
      div('dash-card-title', cardB, 'files fully passing (of ' + fmt(last.files_total) + ' in the suite)');
      lineChart(div('dash-chart', cardB), {
        labels: spanLabels,
        tickLabels: spanTicks,
        series: [{ name: 'files fully passing', cls: 's2', values: filesN }],
        yMax: niceMax(Math.max.apply(null, filesN.filter(function (v) { return v != null; }))),
        yFmt: function (v) { return fmt(Math.round(v)); },
        width: 380, height: 230, maxXLabels: 5,
        tipRow: function (si, i) {
          var r = span[i];
          return 'files: ' + fmt(r.files_pass) + (r.files_total ? ' of ' + fmt(r.files_total) : '') + preTag(i);
        }
      });

      // ---- documentation conformance over time --------------------------
      // The same verdicts the conformance page draws as dots, as a time series.
      // One point per snapshot run (tools/snapshot.raku), not per release.
      var conf = data.conformance || [];
      var confEl = document.getElementById('dash-conformance');
      if (confEl && conf.length) {
        var confSeries = [
          { key: 'ok',             name: 'ok — all three agree',   cls: 'sok' },
          { key: 'rakupp-differs', name: 'Raku++ differs',         cls: 'sbad' },
          { key: 'all-differ',     name: 'needs a human',          cls: 'shuman' },
          { key: 'doc-drift',      name: 'docs stale',             cls: 'sdrift' },
          { key: 'rakudo-differs', name: 'Rakudo differs',         cls: 'srdif' }
        ];
        var confMax = 0;
        confSeries.forEach(function (s) {
          conf.forEach(function (r) { if (r[s.key] > confMax) confMax = r[s.key]; });
        });
        lineChart(confEl, {
          labels: conf.map(function (r) { return r.date; }),
          series: confSeries.map(function (s) {
            return { name: s.name, cls: s.cls,
                     values: conf.map(function (r) { return r[s.key]; }) };
          }),
          yMax: niceMax(confMax),
          yFmt: function (v) { return fmt(Math.round(v)); },
          height: 240, maxXLabels: 6,
          tipRow: function (si, i) {
            var s = confSeries[si];
            return s.name + ': ' + fmt(conf[i][s.key]) + ' examples';
          }
        });
      } else if (confEl) {
        confEl.textContent = 'No conformance snapshots recorded yet.';
      }

      // ---- modules chart -----------------------------------------------
      // One line, one question: how many of the zef ecosystem's dists pass
      // their own test suites under Raku++. Linear from zero with nice
      // headroom — the level is the story; the tile carries the fraction.
      if (sweep.length) {
        var swMax = Math.max.apply(null, sweep.map(function (s) { return s.n; }));
        var pow = Math.pow(10, Math.floor(Math.log10(swMax)));
        var mant = swMax / pow;
        var niceCeil = (mant <= 1 ? 1 : mant <= 2 ? 2 : mant <= 2.5 ? 2.5 : mant <= 4 ? 4 : mant <= 5 ? 5 : mant <= 8 ? 8 : 10) * pow;
        lineChart(document.getElementById('dash-modules'), {
          labels: sweep.map(function (s) { return s.date.slice(5); }),
          series: [
            { name: 'dists passing their own suites', cls: 's1',
              values: sweep.map(function (s) { return s.n; }) }
          ],
          yMax: niceCeil,
          yFmt: function (v) { return fmt(Math.round(v)); },
          height: 220,
          tipRow: function (si, i) {
            return fmt(sweep[i].n) + ' / ' + fmt(sweep[i].total) +
                   ' dists passing their own suites (' + sweep[i].date + ')';
          }
        });
      }

      // ---- benchmark small multiples -----------------------------------
      var bench = document.getElementById('dash-bench');

      // A scale switch for the whole section. On a linear axis every one of
      // these charts is bounded by its Rakudo line, so the two Raku++ series
      // are squeezed into the bottom few percent and a real 3x gap between
      // them is drawn a few pixels apart — worst on exactly the kernels where
      // Raku++ leads by most, which are the ones shown first. A log axis makes
      // a ratio a distance, so "3x faster" looks the same whether the numbers
      // are 3 ms or 300 ms. Linear stays the default: it is the honest picture
      // of absolute time, and it is what the tables report.
      function scaleSwitch(host, state, onChange) {
        var wrap = div('dash-scale', host);
        var lab = document.createElement('span');
        lab.className = 'dash-scale-label';
        lab.textContent = 'scale';
        wrap.appendChild(lab);
        var group = div('dash-scale-group', wrap);
        group.setAttribute('role', 'group');
        group.setAttribute('aria-label', 'benchmark chart scale');
        [['linear', false], ['log', true]].forEach(function (opt) {
          var b = document.createElement('button');
          b.type = 'button';
          b.className = 'dash-scale-btn';
          b.textContent = opt[0];
          b.setAttribute('aria-pressed', String(opt[1] === state.log));
          b.addEventListener('click', function () {
            if (state.log === opt[1]) return;
            state.log = opt[1];
            [].slice.call(group.children).forEach(function (o, i) {
              o.setAttribute('aria-pressed', String((i === 1) === state.log));
            });
            onChange();
          });
          group.appendChild(b);
        });
      }
      // Every kernel present in the data, in the order BENCHMARKS.md lists
      // them (fastest-relative first), rather than a hardcoded three: the
      // generator mines all nine and the page was drawing a third of them.
      var benchScale = { log: false };
      // BENCHMARKS.md's own order (widest gap first), with startup last: it is
      // process startup rather than a workload, so it sits outside the ranking.
      var KERNEL_ORDER = ['strcat', 'hash', 'sortby', 'bigint', 'sortnums',
                          'regex', 'textsplit', 'arrayops', 'hashfill',
                          'arraypush', 'loopsum', 'rats', 'fib', 'streq',
                          'objects', 'startup'];
      var present = {};
      rel.forEach(function (r) {
        if (r.bench) Object.keys(r.bench).forEach(function (k) { present[k] = true; });
      });
      var kernels = KERNEL_ORDER.filter(function (k) { return present[k]; });
      Object.keys(present).forEach(function (k) {
        if (KERNEL_ORDER.indexOf(k) < 0) kernels.push(k);   // a kernel we have not ordered yet
      });
      function drawBench() {
        bench.textContent = '';
        kernels.forEach(drawKernel);
      }

      // The card title links to the kernel's source in the rakupp repo, so a
      // reader can see exactly what program a chart is timing. External
      // repository URLs, not site paths — no __SITE_BASE involved. The `dir`
      // argument carries its own trailing slash so that no string literal
      // here starts with one (the runtime-URL check hunts root-absolute
      // site paths, which these are not).
      var RAKUPP_TOOLS = 'https://github.com/ash/rakupp/blob/main/tools/';
      function benchTitle(card, kernel, dir) {
        var t = div('dash-bench-title', card);
        var a = document.createElement('a');
        a.href = RAKUPP_TOOLS + dir + kernel + '.raku';
        a.textContent = kernel;
        a.title = 'the ' + kernel + ' source in the rakupp repository';
        t.appendChild(a);
        if (kernel === 'hashfill') {
          t.appendChild(document.createTextNode(' '));
          var p = document.createElement('a');
          p.href = RAKUPP_TOOLS + 'bench/hashfill.pl';
          p.textContent = '· Perl twin';
          p.title = 'the line-for-line Perl 5 twin the perl series runs';
          t.appendChild(p);
        }
      }

      function drawKernel(kernel) {
        var vals = function (key) {
          return rel.map(function (r) {
            return r.bench && r.bench[kernel] && r.bench[kernel][key] != null
              ? r.bench[kernel][key] : null;
          });
        };
        var interp = vals('interp'), native = vals('native'), rakudo = vals('rakudo');
        // mutsu — the second from-scratch Raku (Rust, bytecode VM + Cranelift
        // JIT). A reference lane like Rakudo's, not one of ours, and it starts
        // at the 2026-08-31 sitting, so it is null across the whole history
        // before that: present only where the tables carry it.
        var mutsu = vals('mutsu');
        var hasMutsu = mutsu.some(function (v) { return v != null; });
        // The SAME Rakudo release compiled through RakuAST, its new frontend
        // (RAKUDO_RAKUAST=1, and the default from 2026.09 on). Not another
        // engine — the same binary in the same sitting with one environment
        // variable set, which is why it can share the Rakudo line's scale.
        // Null before the era that carries it.
        var rakuast = vals('rakuast');
        var hasRakuast = rakuast.some(function (v) { return v != null; });
        // hashfill carries one more reference: the same program in Perl 5,
        // timed as the `perl` binary. Present only where the tables carry it.
        var perl = vals('perl');
        var hasPerl = perl.some(function (v) { return v != null; });
        var all = [].concat(interp, native, rakudo,
                            hasRakuast ? rakuast : [],
                            hasMutsu ? mutsu : [], hasPerl ? perl : [])
                    .filter(function (v) { return v != null; });
        var max = Math.max.apply(null, all);
        var min = Math.min.apply(null, all.filter(function (v) { return v > 0; }));
        var card = div('dash-bench-card', bench);
        benchTitle(card, kernel, 'bench/');
        var host = div('dash-chart', card);
        var series = [
          { name: 'interpreter', cls: 's1', values: interp },
          { name: 'native --exe', cls: 's2', values: native },
          { name: 'Rakudo', cls: 'sref', dash: true, values: rakudo }
        ];
        var names = ['interpreter', 'native --exe', 'Rakudo'];
        var cols = [interp, native, rakudo];
        // Rakudo must stay at index 2 — tipRow reads cols[2] as the reference.
        var astIdx = -1;
        if (hasRakuast) {
          astIdx = series.length;
          series.push({ name: 'Rakudo (RakuAST)', cls: 'sast', dash: true, values: rakuast });
          names.push('Rakudo (RakuAST)');
          cols.push(rakuast);
        }
        if (hasMutsu) {
          series.push({ name: 'mutsu', cls: 'smutsu', dash: true, values: mutsu });
          names.push('mutsu');
          cols.push(mutsu);
        }
        if (hasPerl) {
          series.push({ name: 'perl', cls: 'sperl', dash: true, values: perl });
          names.push('perl');
          cols.push(perl);
        }
        lineChart(host, {
          labels: tagLabels,
          tickLabels: tagTicks,
          series: series,
          log: benchScale.log,
          dataMin: min,
          yMax: benchScale.log ? max : niceMax(max),
          // Sub-millisecond decades still need a digit; whole ms do not.
          yFmt: function (v) { return v < 1 ? String(v) : fmt(Math.round(v)); },
          width: 380, height: 230, maxXLabels: 4,
          tipRow: function (si, i) {
            var v = cols[si][i];
            if (v == null) return names[si] + ': —';
            var row = names[si] + ': ' + v + ' ms';
            // The ratio is the thing these charts are actually about, and on a
            // linear axis it is unreadable off the marks — so state it.
            var ref = cols[2][i];                       // Rakudo, the reference
            // The RakuAST lane is compared against the OTHER backend of that
            // same binary, and is named that way: "1.1x Rakudo" would read as a
            // rival engine rather than as the frontend swap it is. It also says
            // slower/faster in words instead of the bare ref/v the other lanes
            // carry — that quotient is a SPEED multiple, and "0.47x legacy" for
            // a lane taking twice as long reads as the opposite of the truth on
            // the one lane whose whole subject is the comparison.
            if (si === astIdx && ref) {
              row += v > ref ? ' · ' + (v / ref).toFixed(2) + '× slower than legacy'
                   : v < ref ? ' · ' + (ref / v).toFixed(2) + '× faster than legacy'
                   : ' · same as legacy';
            }
            else if (si !== 2 && ref) row += ' · ' + (ref / v).toFixed(1) + '\u00d7 Rakudo';
            if (si === 1 && cols[0][i]) row += ', ' + (cols[0][i] / v).toFixed(1) + '\u00d7 interp';
            return row;
          }
        });
      }

      scaleSwitch(bench.parentNode.insertBefore(document.createElement('div'), bench),
                  benchScale, drawBench);
      drawBench();

      // ---- the -O optimizer small multiples -----------------------------
      // Same shape, different comparison: one program compiled two ways. Only
      // the refs where the -O table was actually re-measured carry a block, so
      // this series is sparse by construction — see the section's note.
      var optHost = document.getElementById('dash-optbench');
      if (optHost) {
        var optScale = { log: false };
        var OPT_ORDER = ['sieve', 'powmod', 'intsum', 'fibcalls', 'arrayidx',
                         'nummath', 'methodcalls', 'stringbuild'];
        var optPresent = {};
        rel.forEach(function (r) {
          if (r.optbench) Object.keys(r.optbench).forEach(function (k) { optPresent[k] = true; });
        });
        var optKernels = OPT_ORDER.filter(function (k) { return optPresent[k]; });
        Object.keys(optPresent).forEach(function (k) {
          if (OPT_ORDER.indexOf(k) < 0) optKernels.push(k);
        });

        var drawOpt = function () {
          optHost.textContent = '';
          optKernels.forEach(function (kernel) {
            var vals = function (key) {
              return rel.map(function (r) {
                return r.optbench && r.optbench[kernel] && r.optbench[kernel][key] != null
                  ? r.optbench[kernel][key] : null;
              });
            };
            var exe = vals('exe'), opt = vals('opt'), rakudo = vals('rakudo');
            var all = [].concat(exe, opt, rakudo).filter(function (v) { return v != null; });
            if (!all.length) return;
            var max = Math.max.apply(null, all);
            var min = Math.min.apply(null, all.filter(function (v) { return v > 0; }));
            var card = div('dash-bench-card', optHost);
            benchTitle(card, kernel, 'optbench/');
            var host = div('dash-chart', card);
            var names = ['--exe', '--exe -O', 'Rakudo'];
            var cols = [exe, opt, rakudo];
            lineChart(host, {
              labels: tagLabels,
              tickLabels: tagTicks,
              series: [
                { name: '--exe', cls: 's2', values: exe },
                { name: '--exe -O', cls: 's1', values: opt },
                { name: 'Rakudo', cls: 'sref', dash: true, values: rakudo }
              ],
              log: optScale.log,
              dataMin: min,
              yMax: optScale.log ? max : niceMax(max),
              yFmt: function (v) { return v < 1 ? String(v) : fmt(Math.round(v)); },
              width: 380, height: 230, maxXLabels: 4,
              tipRow: function (si, i) {
                var v = cols[si][i];
                if (v == null) return names[si] + ': not measured';
                var row = names[si] + ': ' + v + ' ms';
                if (si === 1 && cols[0][i]) row += ' · ' + (cols[0][i] / v).toFixed(1) + '\u00d7 over --exe';
                if (si !== 2 && cols[2][i]) row += (si === 1 ? ', ' : ' · ') +
                  (cols[2][i] / v).toFixed(1) + '\u00d7 Rakudo';
                return row;
              }
            });
          });
        };
        scaleSwitch(optHost.parentNode.insertBefore(document.createElement('div'), optHost),
                    optScale, drawOpt);
        drawOpt();
      }
    })
    .catch(function (e) {
      document.getElementById('dash-roast').textContent = 'Could not load dashboard data (' + e + ').';
    });
})();
