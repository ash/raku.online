// Episode 4, Take, and Wait: the scenes. Timing is the silent timing; the
// player stretches it to fit the narration. Helpers (el, box, txt, seg, …) are
// in player/film.js. Facts: NOTES.md beside this file.

// A vertical stack of frames; returns the frame rects, top first.
function stack(g, x, y, names, w = 360, cls = 'bx2') {
  return names.map((n, i) => {
    const r = box(g, x, y + i * 70, w, 58, cls, 8);
    txt(g, x + 20, y + i * 70 + 38, n, 'mono', 24);
    return r;
  });
}

Film.play([
{
  title: 'Title card', dur: 8,
  cap: [[0, 'Raku++ Internals. Episode 4: Take, and Wait.'],
        [2, 'This episode is about a block of code that can stop in the middle, and carry on later from the same place.']],
  build(g) {
    const a = txt(g, 800, 330, 'TAKE,', 'disp', 200, 'middle');
    const b = txt(g, 800, 520, 'AND WAIT', 'disp t-amber', 150, 'middle');
    const c = txt(g, 800, 640, 'Raku++ Internals · Episode 4', 'body t-muted', 40, 'middle');
    const dots = [0, 1, 2].map(i => el('circle', { cx: 1180 + i * 40, cy: 505, r: 10, class: 'seek' }, g));
    return t => {
      op(a, 1); op(b, seg(t, .6, 1.6)); op(c, seg(t, 1.4, 2.4));
      dots.forEach((d, i) => op(d, t > 2.5 ? .25 + .75 * Math.max(0, Math.sin(t * 3 - i * .8)) : 0));
    };
  }
},
{
  title: 'Taking turns', dur: 13,
  cap: [[0, 'Here is an endless gather: count up forever, and take each number.'],
        [4, 'The loop reads three and stops.'],
        [6.5, 'Look at the output. The producer and the consumer take turns: made one, got one, made two, got two.']],
  build(g) {
    const cb = codeBlock(g, 100, 200, [
      [['my \\nums = '], ['gather', 'g'], [' for 1..* {']],
      [['    say "  made $_";']],
      [['    '], ['take', 't'], [' $_;']],
      [['}']],
      [['for nums { say "got $_"; last if $_ == 3 }']]], 34);
    box(g, 1050, 150, 450, 560, 'bx', 12);
    txt(g, 1080, 200, 'output', 'lbl', 24);
    const out = ['  made 1', 'got 1', '  made 2', 'got 2', '  made 3', 'got 3']
      .map((s, i) => txt(g, 1090, 270 + i * 70, s, 'mono ' + (i % 2 ? 't-amber' : 't-teal'), 32));
    return t => {
      cb.type(Math.floor(lin(t, 0, 3.6) * cb.total));
      cb.mark('g', t > 1 && t < 4); cb.mark('t', t > 7);
      out.forEach((o, i) => op(o, seg(t, 6.6 + i * .9, 6.9 + i * .9)));
    };
  }
},
{
  title: 'The old road: a probe', dur: 13,
  cap: [[0, 'Raku++ used to run the block as soon as the gather was evaluated.'],
        [3.5, 'Up to 64 takes, or 20 milliseconds, whichever came first.'],
        [7.5, 'A block that finished inside that probe was simply eager, side effects and all.']],
  build(g) {
    txt(g, 120, 170, 'gather { … }', 'code', 44);
    const run = txt(g, 560, 170, '→ runs now', 'body t-coral', 36);
    const cells = [];
    for (let i = 0; i < 64; i++) cells.push(box(g, 120 + (i % 16) * 70, 260 + Math.floor(i / 16) * 70, 56, 56, 'bit', 6));
    txt(g, 120, 580, 'takes', 'lbl', 24);
    const n = txt(g, 230, 580, '', 'mono t-amber', 30);
    box(g, 1300, 260, 60, 266, 'bx2', 8);
    const fill = box(g, 1300, 526, 60, 0, 'slot on', 8);
    txt(g, 1330, 580, '20 ms', 'mono t-muted', 26, 'middle');
    const stop = txt(g, 800, 760, 'finished inside?  then eager, side effects already done', 'body t-coral', 34, 'middle');
    return t => {
      op(run, seg(t, .8, 1.3));
      const k = Math.floor(64 * lin(t, 3.5, 6.5));
      cells.forEach((c, i) => c.classList.toggle('on', i < k));
      n.textContent = t > 3.5 ? String(k) : '';
      const h = 266 * lin(t, 3.5, 6.5); fill.setAttribute('y', 526 - h); fill.setAttribute('height', h);
      op(stop, seg(t, 7.8, 8.3));
    };
  }
},
{
  title: 'Start again, bigger', dur: 14,
  cap: [[0, 'Need more elements? There was no way to resume.'],
        [3, 'So the block ran again from the top, with a bigger cap: 64, then 128, then 256.'],
        [7, 'A snapshot put back the variables it had changed, before each rerun.'],
        [10.5, 'Recursive gathers nested 100 deep took over a minute.']],
  build(g) {
    const caps = [64, 128, 256];
    const runs = caps.map((c, i) => {
      const gg = el('g', {}, g), y = 170 + i * 130;
      txt(gg, 120, y + 45, 'run ' + (i + 1), 'body', 30);
      const r = box(gg, 300, y, 0, 64, i ? 'chip on' : 'slot on', 8);
      txt(gg, 300, y + 100, 'from the top, cap ' + c, 'lbl', 22);
      return { gg, r, c, at: 3 + i * 1.3 };
    });
    const snap = el('g', {}, g);
    box(snap, 1140, 180, 360, 200, 'bx', 12);
    txt(snap, 1170, 235, 'snapshot', 'disp', 42);
    txt(snap, 1170, 290, 'variables the', 'lbl', 24);
    txt(snap, 1170, 325, 'block wrote', 'lbl', 24);
    const deep = txt(g, 800, 760, 'nested 100 deep:  over 60 s', 'disp t-coral', 64, 'middle');
    return t => {
      runs.forEach(u => { op(u.gg, seg(t, u.at, u.at + .3)); u.r.setAttribute('width', 3 * u.c * seg(t, u.at, u.at + 1)); });
      op(snap, seg(t, 7, 7.5));
      op(deep, seg(t, 10.7, 11.2));
    };
  }
},
{
  title: 'A stack of its own', dur: 14,
  cap: [[0, 'The fix gives the block a stack of its own.'],
        [3, '256 megabytes are reserved, but the kernel only commits pages as they are touched.'],
        [7.5, 'A guard region at the bottom catches an overflow.'],
        [10.5, 'Finished stacks go back to a pool, up to 16 per thread.']],
  build(g) {
    txt(g, 120, 130, 'the consumer’s stack', 'lbl', 24);
    stack(g, 120, 150, ['main', 'for nums', 'gatherPull', 'resume']);
    const co = el('g', {}, g);
    txt(co, 700, 130, 'the block’s own stack', 'lbl', 24);
    box(co, 700, 150, 360, 600, 'bx', 10);
    const pages = [];
    for (let i = 0; i < 12; i++) pages.push(box(co, 716, 166 + i * 44, 328, 36, 'bit', 4));
    const guard = box(co, 700, 700, 360, 50, 'chip on', 6);
    txt(co, 1080, 185, '256 MiB reserved', 'mono t-muted', 24);
    txt(co, 1080, 230, 'MAP_NORESERVE', 'mono t-muted', 22);
    const gl = txt(co, 1080, 735, '64 KiB guard', 'mono t-coral', 24);
    const pool = el('g', {}, g);
    txt(pool, 1300, 460, 'pool', 'lbl', 24);
    for (let i = 0; i < 16; i++) box(pool, 1300 + (i % 4) * 44, 480 + Math.floor(i / 4) * 64, 34, 54, 'bit on', 4);
    txt(pool, 1300, 770, 'up to 16 per thread', 'lbl', 22);
    return t => {
      op(co, seg(t, .5, 1));
      const k = Math.floor(4 * lin(t, 3.5, 6));
      pages.forEach((p, i) => p.classList.toggle('on', i < k));
      op(guard, t > 7.5 ? 1 : .35); op(gl, seg(t, 7.5, 8));
      op(pool, seg(t, 10.6, 11.1));
    };
  }
},
{
  title: 'The switch', dur: 13,
  cap: [[0, 'Switching between the two stacks takes a few lines of assembly.'],
        [3, 'Save the registers a function must preserve, switch the stack pointer, and restore the other side’s.'],
        [7.5, 'No ucontext, and no threads. A resume and a yield take about 42 nanoseconds together.'],
        [10.5, 'ucontext was ruled out: macOS deprecates it, and it makes a system call on every switch.']],
  build(g) {
    txt(g, 120, 150, 'rakupp_coro_switch, arm64', 'mono t-muted', 28);
    const regs = ['x19', 'x20', 'x21', 'x22', 'x23', 'x24', 'x25', 'x26', 'x27', 'x28', 'x29', 'x30', 'd8', 'd9', 'd10', 'd11', 'd12', 'd13', 'd14', 'd15'];
    const R = regs.map((r, i) => {
      const gg = el('g', {}, g);
      box(gg, 0, 0, 100, 50, 'slot', 6); txt(gg, 50, 34, r, 'mono', 22, 'middle');
      return { gg, x0: 120 + (i % 10) * 110, y0: 190 + Math.floor(i / 10) * 64, x1: 900 + (i % 5) * 110, y1: 200 + Math.floor(i / 5) * 64 };
    });
    const frame = el('g', {}, g);
    el('rect', { x: 880, y: 180, width: 570, height: 280, rx: 10, class: 'wire', 'stroke-dasharray': '10 8' }, frame);
    txt(frame, 900, 500, 'a 160-byte frame on the stack being left', 'lbl', 22);
    const sp = el('g', {}, g);
    txt(sp, 120, 440, 'sp', 'mono t-amber', 40);
    const spA = txt(sp, 200, 440, '→ consumer’s stack', 'mono', 30);
    const n = txt(g, 800, 680, '≈ 42 ns  resume + yield', 'disp t-amber', 64, 'middle');
    const no = txt(g, 800, 780, 'no ucontext · no threads', 'body t-muted', 34, 'middle');
    return t => {
      const p = seg(t, 3.5, 5.5);
      R.forEach(r => mv(r.gg, r.x0 + (r.x1 - r.x0) * p, r.y0 + (r.y1 - r.y0) * p));
      op(frame, seg(t, 3.2, 3.6));
      op(sp, seg(t, 5.5, 5.8)); spA.textContent = t > 6.3 ? '→ the block’s stack' : '→ consumer’s stack';
      op(n, seg(t, 7.8, 8.3)); op(no, seg(t, 8.4, 8.9));
    };
  }
},
{
  title: 'Pull and take', dur: 16,
  cap: [[0, 'Now one element. The for loop asks the Seq for one more.'],
        [3.5, 'gatherPull records how many are wanted and resumes the block.'],
        [7, 'The block runs until take has filled what was asked for, then yields right there, in the middle of its loop.'],
        [11, 'The next pull resumes exactly where it stopped.']],
  build(g) {
    txt(g, 120, 120, 'consumer', 'disp t-teal', 40);
    const C = ['for nums', 'materializeLazy  pullHint = 1', 'gatherPull  want = 1', 'co.resume()']
      .map((s, i) => { const gg = el('g', {}, g); box(gg, 120, 160 + i * 110, 560, 80, 'bx2', 8); txt(gg, 145, 210 + i * 110, s, 'mono', 26); return gg; });
    txt(g, 900, 120, 'the block', 'disp t-amber', 40);
    const B = ['say "  made $_"', 'take $_  → buf', 'buf.size() ≥ want', 'co.yield()']
      .map((s, i) => { const gg = el('g', {}, g); box(gg, 900, 160 + i * 110, 560, 80, 'bx2', 8); txt(gg, 925, 210 + i * 110, s, 'mono', 26); return gg; });
    const hop = line(g, 690, 530, 890, 200, 'arrow a', 'aha');
    const back = line(g, 890, 530, 690, 200, 'arrow', 'ah');
    const resume = txt(g, 800, 720, 'next pull: resume at the take, not from the top', 'body t-teal', 32, 'middle');
    const ptr = el('circle', { r: 14, class: 'seek' }, g);
    return t => {
      C.forEach((c, i) => op(c, seg(t, .5 + i * .8, .9 + i * .8)));
      op(hop, seg(t, 5.5, 5.9));
      B.forEach((b, i) => op(b, seg(t, 6.2 + i * .9, 6.6 + i * .9)));
      op(back, seg(t, 10, 10.4));
      const [x, y] = t < 6.2 ? [100, 200 + Math.min(3, Math.floor((t - .5) / .8)) * 110] : [880, 200 + Math.min(3, Math.floor((t - 6.2) / .9)) * 110];
      ptr.setAttribute('cx', x); ptr.setAttribute('cy', y); op(ptr, seg(t, .5, .8) * (1 - seg(t, 10.2, 10.5)));
      op(resume, seg(t, 11.2, 11.7));
    };
  }
},
{
  title: 'What travels with a switch', dur: 13,
  cap: [[0, 'The interpreter keeps its running state per thread, so every switch swaps it.'],
        [3.5, 'Field by field: swapping the whole structure at once cost 40 percent of a loop over a gather.'],
        [7.5, 'Dynamic variables resolve through whoever is pulling, as they do in Rakudo.']],
  build(g) {
    box(g, 120, 140, 560, 420);
    txt(g, 150, 200, 'ExecContext', 'disp', 44);
    txt(g, 150, 240, '1,472 bytes on Apple arm64', 'lbl', 22);
    const F = [];
    for (let i = 0; i < 12; i++) F.push(box(g, 150 + (i % 4) * 128, 280 + Math.floor(i / 4) * 80, 112, 60, 'slot', 6));
    const whole = txt(g, 400, 640, 'std::swap of the whole thing: −40%', 'body t-coral', 28, 'middle');
    const dyn = el('g', {}, g);
    txt(dyn, 900, 180, 'dynamic chain, while the block runs', 'lbl', 24);
    [['the block’s frames', 'slot on'], ['the consumer’s frames', 'bx2'], ['the consumer’s callers', 'bx2']]
      .forEach(([s, c], i) => { box(dyn, 900, 210 + i * 100, 560, 80, c, 8); txt(dyn, 930, 260 + i * 100, s, 'body', 28); });
    txt(dyn, 900, 560, '$*X looks up through whoever pulls', 'mono t-teal', 26);
    return t => {
      const k = Math.floor(12 * lin(t, .8, 3.2));
      F.forEach((f, i) => f.classList.toggle('on', i < k));
      op(whole, seg(t, 4.5, 5));
      op(dyn, seg(t, 7.6, 8.1));
    };
  }
},
{
  title: 'Letting go', dur: 13,
  cap: [[0, 'And if nobody pulls again?'],
        [2, 'When the Seq is dropped, the suspended block goes to a graveyard.'],
        [5.5, 'The next gather on that thread wakes it once, only to throw StopGatherEx, so its frames unwind cleanly.'],
        [9.5, 'Its LEAVE phasers stay silent, as in Rakudo, and the stack goes back to the pool.']],
  build(g) {
    const blk = el('g', {}, g);
    box(blk, 0, 0, 340, 120, 'slot on', 10);
    txt(blk, 170, 52, 'suspended', 'body t-amber', 28, 'middle');
    txt(blk, 170, 92, 'at take', 'mono t-muted', 24, 'middle');
    box(g, 900, 180, 420, 240, 'bx', 12);
    txt(g, 930, 230, 'graveyard', 'disp', 40);
    txt(g, 930, 270, 'per thread', 'lbl', 22);
    const wake = txt(g, 120, 560, 'next gather:  resume with cancel', 'mono t-teal', 30);
    const thr = txt(g, 120, 620, 'take throws StopGatherEx → frames unwind', 'mono t-coral', 30);
    const quiet = txt(g, 120, 680, 'LEAVE phasers: silent', 'mono t-muted', 30);
    const pool = txt(g, 120, 740, 'stack → pool', 'mono t-amber', 30);
    return t => {
      const [x, y] = track(t, [[0, 200, 250], [2.2, 200, 250], [3.6, 940, 290], [6, 940, 290], [8.5, 940, 520]]);
      mv(blk, x, y); op(blk, 1 - seg(t, 8.2, 8.8));
      op(wake, seg(t, 5.8, 6.3)); op(thr, seg(t, 7, 7.5));
      op(quiet, seg(t, 9.6, 10.1)); op(pool, seg(t, 10.6, 11.1));
    };
  }
},
{
  title: 'Read once', dur: 12,
  cap: [[0, 'One more change: a Seq can now be read only once.'],
        [3, 'The first for marks it consumed. A second one throws X::Seq::Consumed.'],
        [7, 'Uses that only look, like elems or indexing, mark it cached instead, and never complain.']],
  build(g) {
    const cb = codeBlock(g, 120, 200, [
      [['for nums { … }']],
      [['try { .say for nums; CATCH { default { say .^name } } }']]], 32);
    const badge = el('g', {}, g);
    box(badge, 1080, 140, 380, 110, 'bx', 12);
    txt(badge, 1110, 180, 'SeqToken', 'lbl', 24);
    const st = txt(badge, 1110, 228, 'Unread', 'mono t-teal', 36);
    const err = txt(g, 120, 400, 'X::Seq::Consumed', 'mono t-coral', 44);
    const look = el('g', {}, g);
    txt(look, 120, 560, '.elems   .Bool   .Str   $s[0]', 'mono', 32);
    txt(look, 120, 620, '→ Cached: never an error', 'body t-amber', 30);
    return t => {
      cb.type(Math.floor(lin(t, .2, 2.4) * cb.total));
      st.textContent = t < 3.2 ? 'Unread' : t < 7.2 ? 'Consumed' : 'Consumed';
      st.setAttribute('class', t < 3.2 ? 'mono t-teal' : 'mono t-coral');
      op(err, seg(t, 5, 5.4)); op(look, seg(t, 7.2, 7.7));
    };
  }
},
{
  title: 'Where it runs', dur: 12,
  cap: [[0, 'The switch needs its own few lines for each kind of processor. Raku++ has them for 64-bit ARM and x86, and uses Fibers on Windows.'],
        [4.5, 'Raku.js, running as WebAssembly, still uses the old probe.'],
        [7.5, 'And a gather that has started producing can only be read on the thread that started it.']],
  build(g) {
    const rows = [['arm64 · x86-64', 'coroutines, by the assembly switch', 'bit on'], ['Windows', 'coroutines, by Fibers', 'bit on'], ['WebAssembly (Raku.js)', 'the probe, as before', 'bul'], ['a started gather', 'read on its own thread', 'slot on']];
    const G = rows.map(([a, b, c], i) => {
      const gg = el('g', {}, g), y = 170 + i * 170;
      box(gg, 120, y - 30, 22, 22, c, 4);
      txt(gg, 170, y - 8, a, 'body', 38);
      txt(gg, 170, y + 44, b, 'mono t-muted', 28);
      return gg;
    });
    const at = [0, 1, 4.5, 7.5];
    return t => G.forEach((e, i) => op(e, seg(t, at[i] + .2, at[i] + .7)));
  }
},
{
  title: 'Before and after', dur: 13,
  cap: [[0, 'Big gathers got 1.7 to 2.7 times faster.'],
        [4.5, 'Nested recursive gathers, 100 deep, went from over a minute to 20 milliseconds.'],
        [8.5, 'Tiny gathers pay for starting a coroutine: 60,000 of them went from 100 to 120 milliseconds.']],
  build(g) {
    const S = 1.6; // px per ms
    const rows = [['list-assign 300k takes', 230, 84], ['for over 300k takes', 350, 200], ['.map over a gather', 310, 180], ['endless gather → array', 355, 194]];
    const R = rows.map(([n, a, b], i) => {
      const y = 140 + i * 110;
      txt(g, 120, y + 30, n, 'body', 26);
      const ra = box(g, 520, y, 0, 30, 'chip on', 4), rb = box(g, 520, y + 36, 0, 30, 'slot on', 4);
      const ta = txt(g, 530, y + 24, a + ' ms', 'mono t-muted', 20), tb = txt(g, 530, y + 60, b + ' ms', 'mono t-amber', 20);
      return { ra, rb, ta, tb, a, b };
    });
    const deep = txt(g, 120, 640, 'nested 100 deep:   > 60 s  →  0.02 s', 'mono t-amber', 36);
    const tiny = txt(g, 120, 720, '60,000 two-take gathers:   100 ms  →  120 ms', 'mono t-coral', 32);
    txt(g, 1240, 110, 'before', 'mono t-coral', 22); txt(g, 1340, 110, 'after', 'mono t-amber', 22);
    return t => {
      const p = seg(t, .3, 2.3);
      R.forEach(r => {
        r.ra.setAttribute('width', r.a * S * p); r.rb.setAttribute('width', r.b * S * p);
        r.ta.setAttribute('x', 530 + r.a * S * p); r.tb.setAttribute('x', 530 + r.b * S * p);
      });
      op(deep, seg(t, 4.7, 5.2)); op(tiny, seg(t, 8.7, 9.2));
    };
  }
},
{
  title: 'Credits', dur: 9,
  cap: [[0, ''], [3.5, 'That is the end of this episode. Thanks for watching.']],
  build(g) {
    const a = txt(g, 800, 330, 'TAKE, AND WAIT', 'disp', 150, 'middle');
    const b = txt(g, 800, 420, 'Raku++ Internals · Episode 4', 'body t-amber', 40, 'middle');
    const c = txt(g, 800, 540, 'Drawn from commit 0d048722, docs/dev/plans/ROAST-TRACKS-PLAN.md, src/Coro.cpp and src/InterpreterOperators.cpp', 'lbl', 24, 'middle');
    return t => { op(a, seg(t, 0, 1)); op(b, seg(t, .8, 1.8)); op(c, seg(t, 2, 3)); };
  }
}]);
