// Episode 1, The Pad: the scenes. Timing is the silent timing; the player
// stretches it to fit the narration. Helpers (el, box, txt, seg, …) are in
// player/film.js.

Film.play([
{
  title: 'Title card', dur: 8,
  cap: [[0, 'Raku++ Internals. Episode 1: The Pad.'], [1.8, 'Every variable in a program has to live somewhere. This episode is about where, and how fast we can get to it.']],
  build(g) {
    const cells = [];
    for (let r = 0; r < 7; r++) for (let c = 0; c < 20; c++) cells.push(box(g, 29 + c * 78, 34 + r * 120, 60, 60, 'cell', 8));
    const a = txt(g, 800, 400, 'RAKU++', 'disp', 210, 'middle');
    const b = txt(g, 800, 478, 'I N T E R N A L S', 'body t-amber', 38, 'middle');
    const c = txt(g, 800, 610, 'Episode 1 · The Pad', 'body', 60, 'middle');
    return t => {
      cells.forEach((e, i) => op(e, .04 + .16 * Math.max(0, Math.sin(t * 1.3 + i * 1.7) * Math.sin(i * .37 + t * .6))));
      op(a, 1); op(b, seg(t, .6, 1.6)); op(c, seg(t, 1.4, 2.6));
    };
  }
},
{
  title: 'A million lookups', dur: 11,
  cap: [[0, 'A familiar shape: a variable declared in the mainline, updated from inside a loop body.'],
        [5.2, 'Each pass reads $sum and writes $sum. Both find it by its name.'],
        [8, 'A million passes means two million name lookups for $sum alone.']],
  build(g) {
    txt(g, 300, 200, 'main.raku', 'lbl', 28);
    const cb = codeBlock(g, 300, 300, [
      [['my '], ['$sum', 'a'], [' = 0;']],
      [['for 1..1_000_000 -> $i {']],
      [['    '], ['$sum', 'b'], [' = '], ['$sum', 'b'], [' + $i;']],
      [['}']]], 50);
    const w = txt(g, 480, 510, 'write', 'body t-amber', 26, 'middle');
    const r = txt(g, 690, 510, 'read', 'body t-amber', 26, 'middle');
    const cnt = txt(g, 800, 740, '', 'mono t-muted', 38, 'middle');
    return t => {
      cb.type(Math.floor(lin(t, .3, 4.3) * cb.total));
      cb.mark('b', t > 5.2);
      op(w, seg(t, 5.2, 5.8)); op(r, seg(t, 5.4, 6));
      const it = 1e6 * Math.pow(lin(t, 7, 10.3), 2);
      cnt.textContent = t < 7 ? '' : `iteration ${fmt(it)}   ·   $sum lookups ${fmt(it * 2)}`;
    };
  }
},
{
  title: 'The old road', dur: 15,
  cap: [[0, 'Before pads, every one of those lookups ended in Env::find.'],
        [1.2, 'Step one: hash the name.'],
        [2.6, 'Step two: probe the current scope’s map.'],
        [4, 'Miss. The loop body only knows $i.'],
        [5.3, 'Walk up to the parent scope, and hash again.'],
        [7.6, 'Found, one level up.'],
        [9.2, 'Per read, per level, per iteration.']],
  build(g) {
    txt(g, 80, 110, '$sum = $sum + $i', 'code', 36);
    box(g, 180, 380, 340, 180);
    txt(g, 350, 430, 'hash(name)', 'body t-muted', 28, 'middle');
    const hx = txt(g, 350, 510, '—', 'mono t-teal', 36, 'middle');
    box(g, 900, 130, 560, 230);
    txt(g, 930, 180, 'Env · mainline', 'body', 30);
    const found = el('rect', { x: 915, y: 215, width: 530, height: 46, rx: 8, class: 'hlrow' }, g);
    txt(g, 940, 248, '$sum', 'mono', 30); txt(g, 1200, 248, '820', 'mono t-muted', 30);
    txt(g, 940, 310, '&say', 'mono', 30); txt(g, 1200, 310, 'Sub', 'mono t-muted', 30);
    box(g, 900, 540, 560, 200);
    txt(g, 930, 590, 'Env · loop body', 'body', 30);
    txt(g, 940, 660, '$i', 'mono', 30); txt(g, 1200, 660, '41', 'mono t-muted', 30);
    const miss = txt(g, 1400, 672, '✗', 'body t-coral', 64, 'middle');
    line(g, 1180, 538, 1180, 368);
    txt(g, 1200, 460, 'parent', 'lbl', 26);
    const reads = txt(g, 100, 700, '', 'mono', 34);
    const hashes = txt(g, 100, 760, '', 'mono t-coral', 34);
    const pill = el('g', {}, g);
    el('rect', { x: -65, y: -28, width: 130, height: 56, rx: 28, class: 'pill' }, pill);
    txt(pill, 0, 11, '$sum', 'mono t-dark', 30, 'middle');
    const path = [[0, 140, 230], [.6, 140, 230], [1.2, 350, 330], [2.4, 350, 330], [3.6, 1330, 650], [5.2, 1330, 650], [6, 350, 330], [6.8, 350, 330], [7.8, 1380, 238]];
    return t => {
      const [x, y] = track(t, path); mv(pill, x, y);
      hx.textContent = t < 1.2 ? '—' : t < 2.2 ? hash(t) : t < 6 ? 'bucket 5' : t < 6.6 ? hash(t) : 'bucket 2';
      op(miss, seg(t, 3.8, 4.1) * (1 - seg(t, 5.2, 5.5)));
      op(found, .25 * seg(t, 7.6, 8.1));
      const n = 1e6 * Math.pow(lin(t, 9.2, 14.4), 2);
      reads.textContent = t < 9.2 ? '' : `lookups of $sum  ${fmt(n * 2)}`;
      hashes.textContent = t < 9.2 ? '' : `hash + probe     ${fmt(n * 4)}`;
    };
  }
},
{
  title: 'Perl’s trick', dur: 9,
  cap: [[0, 'Perl settled this long ago.'],
        [2, 'Each my gets an integer offset when the code is compiled.'],
        [5, 'At run time a read is PL_curpad[po]: one indexed load. No name, no hash.']],
  build(g) {
    txt(g, 800, 150, 'How Perl does it', 'body t-muted', 34, 'middle');
    const big = txt(g, 800, 280, 'PL_curpad[po]', 'code', 84, 'middle');
    const names = ['$a', '@xs', '$n', '$sum', '$i', '%h', '$ok', '$tmp'];
    const cells = names.map((n, i) => {
      const gg = el('g', {}, g), x = 350 + i * 115;
      txt(gg, x + 50, 455, String(i), 'mono t-muted', 24, 'middle');
      const r = box(gg, x, 475, 100, 100, 'slot', 10);
      txt(gg, x + 50, 535, n, 'mono', 26, 'middle');
      return { gg, r };
    });
    const px = 350 + 3 * 115 + 50;
    const po = txt(g, px, 720, 'po = 3', 'mono t-amber', 40, 'middle');
    const ar = line(g, px, 680, px, 590, 'arrow a', 'aha');
    return t => {
      op(big, seg(t, 0, .8));
      cells.forEach((c, i) => op(c.gg, seg(t, 1.8 + i * .15, 2.6 + i * .15)));
      op(po, seg(t, 4.6, 5.1)); op(ar, seg(t, 5.1, 5.5));
      cells[3].r.classList.toggle('on', t > 5.6);
    };
  }
},
{
  title: 'The layout', dur: 13,
  cap: [[0, 'Raku++ took the idea and gave it a name: the PadLayout.'],
        [2, 'At a routine’s first call, the resolver reads its body once.'],
        [3.5, 'Parameters take the first slots.'],
        [5.2, 'Then every plain my declared directly in the body.'],
        [8.4, '$x belongs to the inner block, so it stays on the map path.'],
        [10.4, 'The layout is cached per body. Two Callables sharing one body, such as .assuming wrappers, agree on every slot.']],
  build(g) {
    const cb = codeBlock(g, 90, 230, [
      [['sub total('], ['@xs', 'p'], [') {']],
      [['    my '], ['$sum', 's'], [' = 0;']],
      [['    my '], ['$n', 'n'], [' = @xs.elems;']],
      [['    for @xs -> '], ['$x', 'x'], [' { $sum += $x }']],
      [['    $sum / $n']],
      [['}']]], 34);
    const xtag = txt(g, 396, 425, 'inner block → map path', 'body t-coral', 24);
    box(g, 980, 170, 540, 430);
    txt(g, 1010, 228, 'PadLayout', 'disp', 48);
    txt(g, 1010, 268, 'names[] — one entry per slot', 'lbl', 22);
    const rows = [['0', '@xs', 'param'], ['1', '$sum', 'my'], ['2', '$n', 'my']].map((r, i) => {
      const gg = el('g', {}, g), y = 335 + i * 72;
      box(gg, 1010, y - 38, 480, 56, 'bx2', 8);
      txt(gg, 1040, y, r[0], 'mono t-amber', 28); txt(gg, 1100, y, r[1], 'mono', 28); txt(gg, 1330, y, r[2], 'lbl', 24);
      return gg;
    });
    const by = txt(g, 1010, 565, 'byName: "$sum" → 1 …', 'mono t-muted', 24);
    const key = txt(g, 1250, 670, 'cached per BODY address', 'body t-teal', 30, 'middle');
    const times = [3.5, 5.2, 6.6], keys = ['p', 's', 'n'];
    return t => {
      cb.type(Math.floor(lin(t, 0, 1.6) * cb.total));
      rows.forEach((r, i) => { const p = seg(t, times[i], times[i] + .7); op(r, p); mv(r, (1 - p) * -80, 0); cb.mark(keys[i], t > times[i]); });
      op(xtag, seg(t, 8.4, 9)); cb.mark('x', false);
      op(by, seg(t, 9.6, 10.2)); op(key, seg(t, 10.4, 11));
    };
  }
},
{
  title: 'Frames and pads', dur: 16,
  cap: [[0, 'Each call gets a frame. Every frame of this body shares the one layout.'],
        [3.2, 'The frame keeps its own pad: a vector of Values, one per slot.'],
        [5, 'A slot goes live when its declaration runs. padLive holds one bit per slot.'],
        [10, 'The pad is sized once and never grows, because lvalue() hands out pointers into it.'],
        [12.4, 'Until its bit is set, a slot answers nothing, and the lookup falls through to the map as before.']],
  build(g) {
    box(g, 650, 40, 300, 110);
    txt(g, 800, 84, 'PadLayout · total', 'body', 26, 'middle');
    txt(g, 800, 124, '@xs   $sum   $n', 'mono t-amber', 26, 'middle');
    const vals = [['(1,2,3)', '6', '3'], ['(5,5)', '10', '2'], ['()', '0', '0']];
    const lit = [[5, 6.5, 8], [5.6, 7.1, 8.6], [6.2, 7.7, 14.2]];
    const frames = [110, 600, 1090].map((x, k) => {
      const y = 330, gg = el('g', {}, g);
      const wire = el('path', { d: `M800 150 C800 240 ${x + 200} 240 ${x + 200} ${y}`, class: 'wire', pathLength: 1, 'stroke-dasharray': 1 }, g);
      box(gg, x, y, 400, 330);
      txt(gg, x + 24, y + 46, `call frame #${k + 1}`, 'body', 26);
      txt(gg, x + 24, y + 102, 'pad', 'lbl', 22);
      const cells = [0, 1, 2].map(i => {
        const r = box(gg, x + 24 + i * 122, y + 118, 110, 70, 'slot', 8);
        const s = txt(gg, x + 79 + i * 122, y + 162, '', 'mono', 22, 'middle');
        return { r, s };
      });
      txt(gg, x + 24, y + 240, 'padLive', 'lbl', 22);
      const bits = [];
      for (let j = 0; j < 14; j++) bits.push(box(gg, x + 24 + j * 22, y + 258, 16, 16, 'bit', 3));
      txt(gg, x + 336, y + 272, '… 64', 'mono t-muted', 18);
      return { gg, wire, cells, bits, k };
    });
    const lv = el('g', {}, g);
    line(lv, 311, 715, 311, 525, 'arrow a', 'aha');
    txt(lv, 311, 752, 'lvalue() → Value* into the pad', 'mono t-amber', 24, 'middle');
    const wait = txt(g, 1290, 720, 'slot 2 not live yet → map path', 'body t-coral', 24, 'middle');
    return t => {
      frames.forEach(f => {
        op(f.gg, seg(t, .6 + f.k * .8, 1.4 + f.k * .8));
        f.wire.setAttribute('stroke-dashoffset', (1 - seg(t, 2.4 + f.k * .3, 3.2 + f.k * .3)).toFixed(3));
        f.cells.forEach((c, i) => {
          const on = t > lit[f.k][i];
          c.r.classList.toggle('on', on); f.bits[i].classList.toggle('on', on);
          c.s.textContent = on ? vals[f.k][i] : '';
        });
      });
      op(lv, seg(t, 10, 10.6));
      op(wait, seg(t, 12.4, 12.9) * (1 - seg(t, 14, 14.4)));
    };
  }
},
{
  title: 'Finding the slot', dur: 15,
  cap: [[0, 'The resolver also tags each reference it can prove lands in a slot.'],
        [1.6, 'A VarExpr carries its slot number and the address of the layout that owns it.'],
        [3.8, 'At run time padPtrIn walks up from the current scope to the first frame that has a layout.'],
        [6.8, 'Same layout? Slot live? Then the answer is pad[slot].'],
        [11.4, 'Any doubt, and it takes the old map path. The nearest layout frame decides; the walk never skips past it.']],
  build(g) {
    box(g, 80, 150, 540, 250);
    txt(g, 110, 214, 'VarExpr', 'disp', 48);
    txt(g, 330, 214, '$sum', 'mono t-amber', 40);
    const f1 = txt(g, 110, 296, 'padSlot  = 1', 'mono', 28);
    const f2 = txt(g, 110, 352, 'padOwner = 0x6000…a3c0', 'mono', 28);
    const chain = [
      [60, 'Env · mainline', 'layout: mainline'],
      [320, 'Env · call frame of total', 'layout: 0x6000…a3c0'],
      [580, 'Env · block scope (for body)', 'layout: none']].map(([y, h, l]) => {
        const gg = el('g', {}, g);
        box(gg, 900, y, 560, 150);
        txt(gg, 930, y + 55, h, 'body', 28);
        txt(gg, 930, y + 110, l, 'mono t-muted', 24);
        return gg;
      });
    line(g, 1180, 578, 1180, 476); line(g, 1180, 318, 1180, 216);
    const note = txt(g, 1440, 690, 'keep walking', 'body t-muted', 22, 'end');
    const dot = el('circle', { r: 18, class: 'seek' }, g);
    const c1 = txt(g, 110, 500, 'layout == padOwner   ✓', 'mono t-teal', 30);
    const c2 = txt(g, 110, 560, 'padLive bit 1 set    ✓', 'mono t-teal', 30);
    const res = txt(g, 110, 660, '→ &pad[1]', 'mono t-amber', 48);
    const alt = txt(g, 110, 760, 'otherwise → Env::find, the map path', 'body t-coral', 30);
    return t => {
      op(f1, seg(t, 1.6, 2.2)); op(f2, seg(t, 2.4, 3));
      const [x, y] = track(t, [[4, 870, 655], [5.4, 870, 655], [6.4, 870, 395]]);
      dot.setAttribute('cx', x); dot.setAttribute('cy', y); op(dot, seg(t, 3.8, 4.2));
      op(note, seg(t, 4.5, 5) * (1 - seg(t, 6.2, 6.6)));
      op(c1, seg(t, 7, 7.5)); op(c2, seg(t, 8.2, 8.7)); op(res, seg(t, 9.4, 10) * (1 - .6 * seg(t, 11.4, 12)));
      op(alt, seg(t, 11.8, 12.4));
      op(chain[0], .35); op(chain[1], 1); op(chain[2], 1);
    };
  }
},
{
  title: 'Who stays on the map', dur: 13,
  cap: [[0, 'Not everything gets a slot.'],
        [3, 'Inner blocks keep their own maps, so every iteration’s closure still sees a fresh variable.'],
        [6.6, 'Specials, dynamics, and code that runs against someone else’s frame stay on the map path.'],
        [10.2, 'A body with more than 64 candidates gets no pad at all: the live mask is a single 64-bit word.']],
  build(g) {
    txt(g, 100, 140, 'GETS A SLOT', 'disp t-amber', 40);
    txt(g, 740, 140, 'STAYS ON THE MAP PATH', 'disp t-coral', 40);
    const item = (x, y, a, b, cls) => {
      const gg = el('g', {}, g);
      box(gg, x, y - 22, 14, 14, cls, 2);
      txt(gg, x + 30, y - 6, a, 'body', 28);
      if (b) txt(gg, x + 30, y + 26, b, 'lbl', 20);
      return gg;
    };
    const L = [['Parameters', 'slots 0 … k-1'], ['Top-level my in a routine body', 'the owner’s direct statements'], ['Top-level my in the mainline', 'the main program is an owner too']]
      .map(([a, b], i) => item(100, 230 + i * 90, a, b, 'bit on'));
    const R = [['my inside an inner block', 'each iteration’s closure needs a fresh variable'], ['$_', 'the topic'], ['Twigils: $!x  $*x  $?x', ''], ['&-sigil names', ''],
      ['our · state · is dynamic', ''], ['EVAL, module mainlines, REPL lines', 'they run against frames owned by someone else'], ['More than 64 candidates', 'no layout for that owner']]
      .map(([a, b], i) => item(740, 230 + i * 86, a, b, 'bul'));
    return t => {
      L.forEach((e, i) => op(e, seg(t, .8 + i * .5, 1.3 + i * .5)));
      const at = [3, 6.6, 7, 7.4, 7.8, 8.2, 10.2];
      R.forEach((e, i) => op(e, seg(t, at[i], at[i] + .5)));
    };
  }
},
{
  title: 'Before and after', dur: 11,
  cap: [[0, 'Same loop, same $sum.'],
        [2.4, 'Before: a hash and a map probe for every level of the walk.'],
        [5.6, 'After: one compare, one bit test, one indexed load.']],
  build(g) {
    txt(g, 100, 220, 'BEFORE', 'disp t-coral', 44);
    txt(g, 100, 520, 'AFTER', 'disp t-amber', 44);
    const mk = (y, items, w, gap, green) => items.map((s, i) => {
      const x = 100 + i * (w + gap);
      const r = box(g, x, y, w, 70, 'chip' + (green ? ' g' : ''), 10);
      txt(g, x + w / 2, y + 44, s, 'mono', 21, 'middle');
      return r;
    });
    const B = mk(270, ['$sum', 'hash', 'probe body', 'miss', 'parent', 'hash', 'probe main', 'found'], 160, 18);
    const A = mk(570, ['$sum', 'layout == owner', 'bit 1 live', 'pad[1]'], 300, 40, true);
    return t => {
      const bi = t > 2.4 ? Math.floor(((t - 2.4) / 3.2) * B.length) % B.length : -1;
      B.forEach((r, i) => r.classList.toggle('on', i === bi));
      const ai = t > 5.6 ? Math.floor(((t - 5.6) / .9) * A.length) % A.length : -1;
      A.forEach((r, i) => r.classList.toggle('on', i === ai));
    };
  }
},
{
  title: 'Credits', dur: 9,
  cap: [[0, ''], [3.5, 'Coming up next: how die reaches CATCH without a C++ throw.']],
  build(g) {
    const a = txt(g, 800, 330, 'THE PAD', 'disp', 170, 'middle');
    const b = txt(g, 800, 420, 'Raku++ Internals · Episode 1', 'body t-amber', 40, 'middle');
    const c = txt(g, 800, 540, 'Drawn from docs/dev/plans/PADS-PLAN.md and src/Interpreter.h', 'lbl', 28, 'middle');
    const d = txt(g, 800, 660, 'Coming up: how die reaches CATCH without a C++ throw', 'body', 34, 'middle');
    return t => { op(a, seg(t, 0, 1)); op(b, seg(t, .8, 1.8)); op(c, seg(t, 2, 3)); op(d, seg(t, 3.5, 4.5)); };
  }
}]);
