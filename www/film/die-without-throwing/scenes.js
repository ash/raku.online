// Episode 2, Die Without Throwing: the scenes. Timing is the silent timing; the
// player stretches it to fit the narration. Helpers (el, box, txt, seg, …) are
// in player/film.js. Facts: NOTES.md beside this file.

// A red token that travels: an error on its way somewhere.
function token(g, label, cls = 'chip on') {
  const t = el('g', {}, g);
  box(t, -80, -30, 160, 60, cls, 30);
  txt(t, 0, 10, label, 'mono', 28, 'middle');
  return t;
}

Film.play([
{
  title: 'Title card', dur: 8,
  cap: [[0, 'Raku++ Internals. Episode 2: Die Without Throwing.'],
        [2, 'An error has to travel from where it happens to the code that handles it. This episode is about how it travels.']],
  build(g) {
    const a = txt(g, 800, 360, 'DIE', 'disp', 230, 'middle');
    const b = txt(g, 800, 500, 'WITHOUT THROWING', 'disp t-amber', 110, 'middle');
    const c = txt(g, 800, 630, 'Raku++ Internals · Episode 2', 'body t-muted', 40, 'middle');
    const chip = token(g, 'die');
    return t => {
      op(a, 1); op(b, seg(t, .6, 1.6)); op(c, seg(t, 1.4, 2.4));
      // falls, and stops in mid-air
      const y = -60 + 240 * seg(t, 2.6, 3.6) + (t > 3.6 ? 6 * Math.sin((t - 3.6) * 3) : 0);
      mv(chip, 1250, y); op(chip, seg(t, 2.5, 2.7));
    };
  }
},
{
  title: 'Half a million deaths', dur: 12,
  cap: [[0, 'Roast’s catch.t has a loop that dies half a million times.'],
        [4.5, 'The inner CATCH matches nothing. The outer one takes the error with default.'],
        [8, 'Under Raku++ this file took 37 seconds. The Roast harness gives each file 10.']],
  build(g) {
    txt(g, 120, 190, 'S04-exception-handlers/catch.t', 'lbl', 26);
    const cb = codeBlock(g, 120, 280, [
      [['for ^500_000 {']],
      [['    CATCH { '], ['default { }', 'd'], [' }']],
      [['    { '], ['CATCH { }', 'c'], ['; die "foo" }']],
      [['}']]], 44);
    const lap = txt(g, 120, 640, '', 'mono t-muted', 34);
    // a stopwatch as a bar: 40 s of scale over 560 px
    const X = 1180, B = 780, H = 560, s = v => B - v / 40 * H;
    el('line', { x1: X - 40, y1: B, x2: X + 200, y2: B, class: 'arrow' }, g);
    const lim = el('g', {}, g);
    el('line', { x1: X - 40, y1: s(10), x2: X + 200, y2: s(10), class: 'wire', 'stroke-dasharray': '10 8' }, lim);
    txt(lim, X + 210, s(10) + 8, '10 s per file', 'body t-teal', 24);
    const bar = box(g, X, B, 120, 0, 'chip on', 6);
    const val = txt(g, X + 60, B - 20, '', 'mono t-coral', 34, 'middle');
    txt(g, X + 60, B + 40, 'catch.t', 'mono t-muted', 24, 'middle');
    return t => {
      cb.type(Math.floor(lin(t, .3, 3.3) * cb.total));
      cb.mark('c', t > 4.5); cb.mark('d', t > 6);
      lap.textContent = t < 7 ? '' : `lap ${fmt(5e5 * Math.pow(lin(t, 7, 10.5), 2))}`;
      op(lim, seg(t, 8, 8.5));
      const p = 37 * seg(t, 8.3, 11.3);
      bar.setAttribute('y', s(p)); bar.setAttribute('height', B - s(p));
      val.setAttribute('y', s(p) - 16); val.textContent = t < 8.3 ? '' : p.toFixed(1) + ' s';
    };
  }
},
{
  title: 'Four throws a lap', dur: 13,
  cap: [[0, 'Every lap raised four C++ exceptions.'],
        [2.5, 'One for the die itself.'],
        [4.5, 'Two more to get the error out of the inner block, whose CATCH matched nothing.'],
        [7.5, 'And one for default, which left its handler by throwing too.'],
        [10, 'Half a million laps: two million throws.']],
  build(g) {
    txt(g, 800, 160, '{ CATCH { }; die "foo" }', 'code', 44, 'middle');
    const items = [['throw', 'die "foo"', 2.5], ['rethrow', 'out of the handler', 4.6], ['rethrow', 'out of the block', 5.6], ['throw', 'default: BreakGivenEx', 7.5]];
    const chips = items.map(([a, b, at], i) => {
      const gg = el('g', {}, g), x = 110 + i * 350;
      box(gg, x, 330, 320, 110, 'chip on', 14);
      txt(gg, x + 160, 400, a, 'mono', 40, 'middle');
      txt(gg, x + 160, 490, b, 'body t-muted', 26, 'middle');
      return [gg, at];
    });
    const n = txt(g, 800, 720, '', 'mono t-coral', 56, 'middle');
    const l = txt(g, 800, 780, 'C++ throws', 'lbl', 28, 'middle');
    return t => {
      chips.forEach(([gg, at]) => { op(gg, seg(t, at, at + .4)); mv(gg, 0, 30 * (1 - seg(t, at, at + .4))); });
      op(n, seg(t, 10, 10.3)); op(l, seg(t, 10, 10.3));
      n.textContent = fmt(4 * 5e5 * Math.pow(lin(t, 10, 12.5), 2));
    };
  }
},
{
  title: 'Where 20 µs goes', dur: 13,
  cap: [[0, 'On macOS on Apple silicon, a C++ throw costs about 20 microseconds.'],
        [3, 'None of that is Raku. It is the unwinder, walking the stack frame by frame.'],
        [6.5, 'For each frame it scans a table of call sites, line by line. exec has 725 entries, eval has 904.'],
        [10.5, 'So the way out was to throw less.']],
  build(g) {
    const names = ['die', 'callBuiltin', 'eval', 'exec', 'execBlock', 'exec', 'execBlock'];
    const tables = { eval: 904, exec: 725 };
    const frames = names.map((n, i) => {
      const r = box(g, 120, 110 + i * 84, 440, 68, 'slot', 8);
      txt(g, 150, 154 + i * 84, n, 'mono', 28);
      return r;
    });
    txt(g, 120, 90, 'the stack, top first', 'lbl', 22);
    const dot = el('circle', { r: 14, class: 'seek' }, g);
    const panel = el('g', {}, g);
    box(panel, 760, 110, 700, 580);
    const title = txt(panel, 790, 160, '', 'mono t-amber', 30);
    const rows = [];
    for (let r = 0; r < 26; r++) rows.push(box(panel, 790, 190 + r * 18.5, 640, 12, 'bit', 2));
    const cost = txt(g, 120, 800, '≈ 20 µs per throw', 'disp t-coral', 64);
    return t => {
      op(cost, seg(t, .4, 1.2));
      const f = clamp(Math.floor((t - 3) / 1.1), 0, names.length - 1);
      op(dot, seg(t, 3, 3.3)); dot.setAttribute('cx', 590); dot.setAttribute('cy', 144 + f * 84);
      frames.forEach((r, i) => r.classList.toggle('on', t > 3 && i === f));
      const nm = names[f];
      op(panel, seg(t, 6.5, 7));
      title.textContent = tables[nm] ? `${nm}: ${tables[nm]} call-site entries` : `${nm}: its call-site table`;
      const scan = Math.floor((t * 22) % rows.length);
      rows.forEach((r, i) => r.classList.toggle('on', t > 6.5 && i <= scan));
    };
  }
},
{
  title: 'The old road', dur: 16,
  cap: [[0, 'Here is the old road.'],
        [1.5, 'die throws. The inner block catches it and runs its CATCH, which matches nothing.'],
        [5.5, 'So it rethrows from inside its own handler, and its own catch-all catches it again.'],
        [9, 'That ran LEAVE a second time, after the scope had closed. That was a bug as well.'],
        [12.5, 'Then another rethrow, and at last the outer default takes it.']],
  build(g) {
    box(g, 120, 100, 1360, 700);
    txt(g, 150, 150, 'outer block', 'body', 30); txt(g, 360, 150, 'CATCH { default { } }', 'mono t-muted', 26);
    box(g, 220, 250, 780, 460, 'bx2', 12);
    txt(g, 250, 300, 'inner block', 'body', 28); txt(g, 450, 300, 'CATCH { }', 'mono t-muted', 26);
    txt(g, 260, 470, 'die "foo"', 'code', 34);
    const cat = box(g, 560, 360, 200, 70, 'slot', 10); txt(g, 660, 405, 'CATCH', 'mono', 26, 'middle');
    const miss = txt(g, 790, 410, '✗', 'body t-coral', 54);
    const lv1 = el('g', {}, g); box(lv1, 560, 560, 200, 70, 'chip on g', 10); txt(lv1, 660, 605, 'LEAVE', 'mono', 26, 'middle');
    const lv2 = el('g', {}, g); box(lv2, 790, 560, 200, 70, 'chip on', 10); txt(lv2, 890, 605, 'LEAVE again', 'mono', 22, 'middle');
    const def = box(g, 1150, 260, 260, 90, 'slot', 10); txt(g, 1280, 315, 'default', 'mono', 28, 'middle');
    const bursts = [['throw', 330, 430, 1.5], ['rethrow', 860, 350, 6], ['rethrow', 1080, 470, 11.8], ['throw: BreakGivenEx', 1280, 400, 14.4]]
      .map(([s, x, y, at]) => [txt(g, x, y, s, 'mono t-coral', 24, 'middle'), at]);
    const tok = token(g, 'error');
    const path = [[1.5, 330, 470], [2.5, 330, 470], [3.5, 660, 395], [5.8, 660, 395], [7, 1000, 480], [11.6, 1000, 480], [13, 1280, 305]];
    return t => {
      const [x, y] = track(t, path); mv(tok, x, y); op(tok, seg(t, 1.4, 1.7));
      cat.classList.toggle('on', t > 3.5 && t < 5.8);
      op(miss, seg(t, 4.2, 4.5));
      op(lv1, seg(t, 5, 5.4)); op(lv2, seg(t, 9.2, 9.6));
      def.classList.toggle('on', t > 13);
      bursts.forEach(([e, at]) => op(e, seg(t, at, at + .3)));
    };
  }
},
{
  title: 'An error as a value', dur: 13,
  cap: [[0, 'The fix starts with a question: what if an error were just a value?'],
        [3, 'A HandedError carries the error, and the original C++ exception if there was one.'],
        [7, 'And a nested block gets a slot from its parent, called handOff, where it can leave an error instead of raising it.']],
  build(g) {
    const card = el('g', {}, g);
    box(card, 480, 110, 640, 250);
    txt(card, 510, 180, 'HandedError', 'disp', 50);
    const f1 = txt(card, 510, 250, 'err     RakuError "foo"', 'mono', 28);
    const f2 = txt(card, 510, 310, 'raised  exception_ptr, or null', 'mono t-muted', 28);
    const inner = el('g', {}, g);
    box(inner, 220, 470, 560, 150, 'bx2', 12); txt(inner, 250, 525, 'inner block', 'body', 30);
    const tray = el('g', {}, g);
    el('rect', { x: 300, y: 670, width: 400, height: 80, rx: 10, class: 'wire', 'stroke-dasharray': '10 8' }, tray);
    txt(tray, 500, 720, 'handOff', 'mono t-amber', 30, 'middle');
    const parent = el('g', {}, g);
    box(parent, 980, 470, 420, 150, 'bx2', 12); txt(parent, 1010, 525, 'outer block', 'body', 30);
    txt(parent, 1010, 580, 'lends the slot', 'lbl', 24);
    const ar = line(g, 980, 620, 720, 700, 'arrow a', 'aha');
    return t => {
      op(card, seg(t, 2.8, 3.4)); op(f1, seg(t, 3.4, 3.9)); op(f2, seg(t, 4.6, 5.1));
      op(inner, seg(t, 6.6, 7.1)); op(parent, seg(t, 7.2, 7.7)); op(ar, seg(t, 8, 8.4)); op(tray, seg(t, 8.6, 9.1));
    };
  }
},
{
  title: 'One lap, traced', dur: 17,
  cap: [[0, 'Now one lap. The inner block runs its statements through execStmtHanding.'],
        [3.5, 'A statement that is only a die call, with no user-defined die and no wrapper, gets special treatment.'],
        [7, 'dieError builds the error, and it goes into the block’s own slot. Nothing is thrown.'],
        [10, 'runBlockCatch finds no match. LEAVE runs, once.'],
        [13, 'The error moves into the handOff slot and goes back to the parent as an ordinary return value.']],
  build(g) {
    box(g, 80, 130, 640, 100, 'bx2', 10);
    txt(g, 110, 195, 'die "foo"', 'code', 42);
    txt(g, 80, 110, 'execStmtHanding looks at the statement', 'lbl', 22);
    const checks = ['only a call to die', 'no user-defined &die in scope', 'no wrapper on the built-in']
      .map((s, i) => txt(g, 100, 310 + i * 60, '✓ ' + s, 'body t-teal', 30));
    const mk = el('g', {}, g);
    box(mk, 820, 130, 300, 100, 'slot', 10); txt(mk, 970, 192, 'dieError', 'mono', 32, 'middle');
    box(g, 820, 320, 700, 260);
    txt(g, 850, 370, 'inner block', 'body', 28);
    const slot = box(g, 850, 400, 280, 110, 'slot', 10); txt(g, 990, 540, 'err', 'mono t-muted', 24, 'middle');
    const r1 = txt(g, 1170, 440, 'runBlockCatch → 2', 'mono', 28);
    const r1b = txt(g, 1170, 480, 'no match', 'body t-coral', 24);
    const r2 = txt(g, 1170, 540, 'LEAVE, once', 'mono t-teal', 28);
    const tray = el('g', {}, g);
    el('rect', { x: 850, y: 640, width: 280, height: 90, rx: 10, class: 'wire', 'stroke-dasharray': '10 8' }, tray);
    txt(tray, 990, 760, 'handOff', 'mono t-amber', 24, 'middle');
    const ret = txt(g, 1180, 820, 'returned to the parent, not thrown', 'body t-amber', 28);
    const card = el('g', {}, g);
    box(card, -115, -32, 230, 64, 'pill', 10); txt(card, 0, 9, 'HandedError', 'mono t-dark', 24, 'middle');
    const path = [[7, 970, 180], [8.5, 990, 455], [13, 990, 455], [14, 990, 685], [15, 990, 685], [16.2, 1440, 685]];
    return t => {
      checks.forEach((c, i) => op(c, seg(t, 3.8 + i * .8, 4.2 + i * .8)));
      op(mk, seg(t, 6.6, 7));
      const [x, y] = track(t, path); mv(card, x, y); op(card, seg(t, 7, 7.3));
      slot.classList.toggle('on', t > 8.5 && t < 13.5);
      op(r1, seg(t, 10, 10.4)); op(r1b, seg(t, 10.4, 10.8)); op(r2, seg(t, 11.3, 11.7));
      op(tray, seg(t, 12.6, 13)); op(ret, seg(t, 15.4, 15.9));
    };
  }
},
{
  title: 'default without a throw', dur: 12,
  cap: [[0, 'The outer block finds the error in its slot and runs its own CATCH.'],
        [3.5, 'runBlockCatch marks the current frame as the given frame, so default can finish by setting a flag.'],
        [7.5, 'That is the same trick the given statement already used.'],
        [10, 'C++ throws for this lap: zero.']],
  build(g) {
    box(g, 100, 120, 760, 520);
    txt(g, 130, 175, 'outer block', 'body', 30);
    box(g, 140, 210, 300, 100, 'slot on', 10);
    txt(g, 290, 270, 'HandedError', 'mono t-amber', 26, 'middle');
    const code = codeBlock(g, 140, 420, [[['CATCH {']], [['    '], ['default { }', 'd']], [['}']]], 34);
    box(g, 960, 120, 540, 360);
    txt(g, 990, 175, 'ExecContext', 'disp', 44);
    const f1 = txt(g, 990, 250, 'curGivenFrame = frameTop', 'mono', 28);
    const f2 = txt(g, 990, 320, 'givenCtl      = 1', 'mono', 28);
    const f3 = txt(g, 990, 400, 'whenMatched() → handler stops', 'body t-teal', 28);
    const zero = txt(g, 800, 790, 'C++ throws this lap:  0', 'disp t-amber', 72, 'middle');
    return t => {
      code.type(code.total);
      op(f1, seg(t, 3.5, 4)); f1.classList.toggle('hl', t > 3.5 && t < 6);
      code.mark('d', t > 5.5);
      op(f2, seg(t, 5.8, 6.3)); f2.classList.toggle('hl', t > 5.8);
      op(f3, seg(t, 6.8, 7.3));
      op(zero, seg(t, 10, 10.5));
    };
  }
},
{
  title: 'Who still throws', dur: 14,
  cap: [[0, 'Only a block’s own statement loop works this way.'],
        [3, 'A die inside a called routine, or inside try, still throws.'],
        [6.5, 'So does a die that is part of a bigger expression, like die if something.'],
        [9.5, 'And an error that nobody nearby handles is thrown exactly once, from the outermost block.']],
  build(g) {
    txt(g, 100, 140, 'TAKES THE SLOT', 'disp t-amber', 40);
    txt(g, 760, 140, 'STILL THROWS', 'disp t-coral', 40);
    const item = (x, y, a, b, cls) => {
      const gg = el('g', {}, g);
      box(gg, x, y - 22, 14, 14, cls, 2);
      txt(gg, x + 30, y - 6, a, 'body', 28);
      if (b) txt(gg, x + 30, y + 26, b, 'lbl', 20);
      return gg;
    };
    const L = [['die "…" as a statement of its own', 'in a block with a CATCH, or nested in one'],
               ['an error leaving a nested bare block', 'it arrives through handOff']]
      .map(([a, b], i) => item(100, 230 + i * 90, a, b, 'bit on'));
    const R = [['die inside a called routine', 'the routine body throws'], ['anything inside try { }', 'try runs a closure'],
               ['die "x" if $c,  $x // die "x"', 'die inside a bigger expression'], ['a user-defined &die, or a wrapped one', ''],
               ['fail,  .resume,  when behind a closure', '']]
      .map(([a, b], i) => item(760, 230 + i * 90, a, b, 'bul'));
    const once = txt(g, 800, 760, 'nobody nearby handles it → one throw, from the outermost block', 'body t-teal', 30, 'middle');
    return t => {
      L.forEach((e, i) => op(e, seg(t, .8 + i * .6, 1.3 + i * .6)));
      [3, 3.8, 6.5, 7.6, 8.4].forEach((at, i) => op(R[i], seg(t, at, at + .5)));
      op(once, seg(t, 9.8, 10.4));
    };
  }
},
{
  title: 'Before and after', dur: 11,
  cap: [[0, 'Same loop, same errors.'],
        [2.5, 'Before: four throws a lap.'],
        [5, 'After: a value, a slot and a flag.'],
        [7.5, 'catch.t went from 37 seconds to 0.42.']],
  build(g) {
    txt(g, 100, 200, 'BEFORE', 'disp t-coral', 44);
    txt(g, 100, 470, 'AFTER', 'disp t-amber', 44);
    const mk = (y, items, w, gap, green) => items.map((s, i) => {
      const x = 100 + i * (w + gap);
      const r = box(g, x, y, w, 70, 'chip' + (green ? ' g' : ''), 10);
      txt(g, x + w / 2, y + 44, s, 'mono', 22, 'middle');
      return r;
    });
    const B = mk(240, ['die', 'throw', 'rethrow', 'rethrow', 'BreakGivenEx'], 250, 22);
    const A = mk(510, ['die', 'HandedError', 'handOff', 'givenCtl = 1'], 320, 40, true);
    const res = txt(g, 800, 760, 'catch.t   37 s  →  0.42 s', 'mono t-amber', 56, 'middle');
    return t => {
      const bi = t > 2.5 ? Math.floor(((t - 2.5) / 3) * B.length) % B.length : -1;
      B.forEach((r, i) => r.classList.toggle('on', i === bi));
      const ai = t > 5 ? Math.floor(((t - 5) / 1) * A.length) % A.length : -1;
      A.forEach((r, i) => r.classList.toggle('on', i === ai));
      op(res, seg(t, 7.5, 8));
    };
  }
},
{
  title: 'Credits', dur: 9,
  cap: [[0, ''], [3.5, 'Coming up next: what happens when an integer gets too big for the machine.']],
  build(g) {
    const a = txt(g, 800, 330, 'DIE WITHOUT THROWING', 'disp', 130, 'middle');
    const b = txt(g, 800, 420, 'Raku++ Internals · Episode 2', 'body t-amber', 40, 'middle');
    const c = txt(g, 800, 540, 'Drawn from commit 9cc30857, src/InterpreterCore.cpp and src/InterpreterModules.cpp', 'lbl', 26, 'middle');
    const d = txt(g, 800, 660, 'Coming up: when an integer outgrows the machine', 'body', 34, 'middle');
    return t => { op(a, seg(t, 0, 1)); op(b, seg(t, .8, 1.8)); op(c, seg(t, 2, 3)); op(d, seg(t, 3.5, 4.5)); };
  }
}]);
