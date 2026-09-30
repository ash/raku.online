// Episode 3, The Carry: the scenes. Timing is the silent timing; the player
// stretches it to fit the narration. Helpers (el, box, txt, seg, …) are in
// player/film.js. Facts: NOTES.md beside this file.

// A small "malloc" stamp that pops onto a heap block.
function stamp(g, x, y) {
  const s = el('g', {}, g);
  box(s, x, y, 110, 40, 'chip on', 20);
  txt(s, x + 55, y + 28, 'malloc', 'mono', 20, 'middle');
  return s;
}
// A row of limb cells; returns the cell groups, each with .r (rect) and .s (text).
function limbs(g, x, y, n, w = 200, h = 80) {
  return Array.from({ length: n }, (_, i) => {
    const gg = el('g', {}, g);
    const r = box(gg, x + i * (w + 16), y, w, h, 'slot', 8);
    const s = txt(gg, x + i * (w + 16) + w / 2, y + h / 2 + 11, '', 'mono', 30, 'middle');
    txt(gg, x + i * (w + 16) + w / 2, y - 14, String(i), 'mono t-muted', 20, 'middle');
    return { gg, r, s };
  });
}

Film.play([
{
  title: 'Title card', dur: 8,
  cap: [[0, 'Raku++ Internals. Episode 3: The Carry.'],
        [2, 'In Raku an Int never overflows. This episode is about what that asks of the interpreter, and how it got cheaper.']],
  build(g) {
    const a = txt(g, 800, 390, 'THE CARRY', 'disp', 210, 'middle');
    const c = txt(g, 800, 510, 'Raku++ Internals · Episode 3', 'body t-muted', 40, 'middle');
    const n = txt(g, 800, 680, '', 'mono t-amber', 52, 'middle');
    return t => {
      op(a, 1); op(c, seg(t, .8, 1.8));
      const d = '9223372036854775807';
      n.textContent = d.slice(0, Math.floor(lin(t, 2.4, 5) * d.length));
    };
  }
},
{
  title: 'The machine word', dur: 12,
  cap: [[0, 'A small Int lives right inside the Value, in one 64-bit machine word.'],
        [4, 'Adding two of them is one CPU instruction, plus a check for overflow.'],
        [8, 'No overflow, no allocation. That is the common case.']],
  build(g) {
    box(g, 120, 160, 620, 300);
    txt(g, 150, 220, 'Value', 'disp', 48);
    box(g, 150, 260, 180, 60, 'slot on', 8); txt(g, 240, 300, 'VT::Int', 'mono t-amber', 26, 'middle');
    box(g, 150, 350, 560, 80, 'slot', 8);
    txt(g, 170, 402, 'i', 'mono t-muted', 26);
    const iv = txt(g, 690, 402, '41', 'mono', 34, 'end');
    const gate = el('g', {}, g);
    box(gate, 900, 230, 300, 120, 'bx2', 12);
    txt(gate, 1050, 305, 'add_ovf', 'mono', 34, 'middle');
    const lamp = el('circle', { cx: 1270, cy: 290, r: 26, class: 'seek' }, gate);
    const ok = txt(gate, 1310, 300, 'no overflow', 'body t-teal', 28);
    const code = txt(g, 900, 180, '$x + 1', 'code', 40);
    const result = txt(g, 1050, 470, '→ 42, in the same word', 'mono t-amber', 30, 'middle');
    const cost = txt(g, 800, 700, 'no allocation', 'disp t-teal', 72, 'middle');
    return t => {
      op(gate, seg(t, 3.8, 4.4)); op(code, seg(t, 3.6, 4.2));
      op(lamp, seg(t, 5.5, 5.8)); op(ok, seg(t, 5.8, 6.2));
      op(result, seg(t, 6.6, 7.1)); iv.textContent = t > 7 ? '42' : '41';
      op(cost, seg(t, 8.2, 8.8));
    };
  }
},
{
  title: 'The cliff', dur: 12,
  cap: [[0, 'Now add one to the biggest word.'],
        [2.5, 'The overflow check trips, and the fast path gives up.'],
        [5.5, 'The general path works it out in 128-bit arithmetic, or as a BigInt.'],
        [9, 'The answer is still just an Int. The type never changes, only where the number lives.']],
  build(g) {
    const code = codeBlock(g, 120, 170, [[['my $n = 2**63 - 1;']], [['say $n + 1;']], [['say ($n + 1).WHAT;']]], 40);
    const gate = el('g', {}, g);
    box(gate, 900, 110, 300, 120, 'bx2', 12);
    txt(gate, 1050, 185, 'add_ovf', 'mono', 34, 'middle');
    const lamp = el('circle', { cx: 1270, cy: 170, r: 26, class: 'bul' }, gate);
    const bad = txt(gate, 1310, 180, 'overflow', 'body t-coral', 28);
    const ar = line(g, 1050, 232, 1050, 380, 'arrow a', 'aha');
    const gen = el('g', {}, g);
    box(gen, 830, 390, 440, 110, 'slot on', 12);
    txt(gen, 1050, 460, 'applyArithGeneral', 'mono t-amber', 32, 'middle');
    const how = txt(g, 1050, 560, '128-bit, or a BigInt', 'body t-muted', 28, 'middle');
    const out = el('g', {}, g);
    txt(out, 120, 520, '9223372036854775808', 'mono t-amber', 44);
    txt(out, 120, 590, '(Int)', 'mono t-amber', 44);
    const note = txt(g, 800, 780, 'same type, a different home', 'disp', 64, 'middle');
    return t => {
      code.type(Math.floor(lin(t, 0, 1.8) * code.total));
      op(gate, seg(t, 1.8, 2.3)); op(lamp, seg(t, 2.8, 3.1)); op(bad, seg(t, 3.1, 3.5));
      op(ar, seg(t, 4, 4.5)); op(gen, seg(t, 4.6, 5.1)); op(how, seg(t, 5.8, 6.3));
      op(out, seg(t, 7.2, 7.8)); op(note, seg(t, 9.2, 9.8));
    };
  }
},
{
  title: 'What a limb is', dur: 13,
  cap: [[0, 'A BigInt is a sign and a list of limbs.'],
        [3, 'A limb here is nine decimal digits in a 32-bit number. The base is one billion.'],
        [7, 'The lowest limb comes first. Two to the 63rd takes three limbs.'],
        [10.5, 'A result that fits in 64 bits never stays a BigInt: it moves back into the word.']],
  build(g) {
    const d = '9223372036854775808';
    // the digits, then cut into nine-digit pieces from the right
    const parts = ['9', '223372036', '854775808'];
    const digits = txt(g, 800, 200, '', 'mono', 60, 'middle');
    const cut = parts.map((p, i) => txt(g, 470 + i * 330, 330, p, 'mono t-amber', 44, 'middle'));
    txt(g, 120, 470, 'sign', 'lbl', 24);
    box(g, 120, 490, 120, 80, 'slot on', 8); txt(g, 180, 542, '+', 'mono t-amber', 40, 'middle');
    txt(g, 330, 470, 'mag: limbs, base 10⁹, lowest first', 'lbl', 24);
    const L = limbs(g, 330, 520, 3, 260, 80);
    const vals = ['854775808', '223372036', '9'];
    const back = txt(g, 800, 780, 'fits in 64 bits?  → back into the word', 'body t-teal', 36, 'middle');
    return t => {
      digits.textContent = d.slice(0, Math.floor(lin(t, 0, 2) * d.length));
      cut.forEach((c, i) => op(c, seg(t, 3.4 + i * .5, 3.8 + i * .5)));
      L.forEach((c, i) => {
        const on = t > 7.2 + i * .6;
        op(c.gg, seg(t, 6.8, 7.2)); c.s.textContent = on ? vals[i] : ''; c.r.classList.toggle('on', on);
      });
      op(back, seg(t, 10.7, 11.2));
    };
  }
},
{
  title: 'Where a BigInt lives', dur: 14,
  cap: [[0, 'A BigInt does not fit in the Value, so it hangs off the Value’s cold block.'],
        [4, 'The BigInt itself is a shared object on the heap.'],
        [7, 'And its limbs lived in a std::vector, which is another heap block.'],
        [10.5, 'Even a number one limb long paid for that block.']],
  build(g) {
    const chain = [['Value', 'VT::Int'], ['cold block', 'ValueExt · big'], ['BigInt', 'sign · mag'], ['std::vector', 'ptr · size · cap'], ['limbs', '3 of them, 12 bytes']];
    const at = [.2, .8, 4, 7, 7.8];
    const G = chain.map(([a, b], i) => {
      const gg = el('g', {}, g), x = 90 + i * 300;
      box(gg, x, 330, 260, 150, i === 4 ? 'slot on' : 'bx', 12);
      txt(gg, x + 20, 385, a, 'body', 30);
      txt(gg, x + 20, 440, b, 'mono t-muted', 20);
      if (i) line(gg, x - 36, 405, x - 4, 405);
      return gg;
    });
    const S = [stamp(g, 390, 270), stamp(g, 690, 270), stamp(g, 1290, 270)];
    const sAt = [1.5, 4.5, 8.3];
    const one = txt(g, 800, 700, 'one limb, and still a heap block for it', 'body t-coral', 34, 'middle');
    return t => {
      G.forEach((e, i) => op(e, seg(t, at[i], at[i] + .5)));
      S.forEach((e, i) => { op(e, seg(t, sAt[i], sAt[i] + .2)); mv(e, 0, -20 * (1 - seg(t, sAt[i], sAt[i] + .3))); });
      op(one, seg(t, 10.8, 11.3));
    };
  }
},
{
  title: 'The Rat problem', dur: 13,
  cap: [[0, 'Every decimal literal in Raku is a Rat, and a Rat is two BigInts.'],
        [3.5, 'So 0.01 times 7 made two vectors, each holding a single limb.'],
        [7.5, 'In the rats benchmark kernel that came to ten allocations every time round the loop.']],
  build(g) {
    txt(g, 120, 170, '0.01 * 7', 'code', 56);
    const eq = txt(g, 470, 170, '= 0.07 = 7/100', 'mono t-muted', 44);
    const parts = [['numerator', '7'], ['denominator', '100']].map(([a, v], i) => {
      const gg = el('g', {}, g), y = 260 + i * 200;
      box(gg, 120, y, 380, 150);
      txt(gg, 150, y + 55, a, 'body', 30); txt(gg, 150, y + 110, 'BigInt', 'mono t-muted', 24);
      line(gg, 510, y + 75, 600, y + 75);
      box(gg, 610, y + 35, 260, 80, 'slot on', 8); txt(gg, 740, y + 87, v, 'mono t-amber', 32, 'middle');
      txt(gg, 890, y + 87, 'one limb, one vector', 'lbl', 22);
      return gg;
    });
    const S = [stamp(g, 700, 240), stamp(g, 700, 440)];
    const n = txt(g, 800, 780, '', 'disp t-coral', 72, 'middle');
    return t => {
      op(eq, seg(t, 1, 1.5));
      parts.forEach((p, i) => op(p, seg(t, 3.6 + i * .8, 4.1 + i * .8)));
      S.forEach((s, i) => op(s, seg(t, 5 + i * .6, 5.2 + i * .6)));
      n.textContent = t > 7.6 ? '10 allocations per iteration' : '';
      op(n, seg(t, 7.6, 8.1));
    };
  }
},
{
  title: 'LimbVec', dur: 14,
  cap: [[0, 'The fix is a vector with room for four limbs inside it: LimbVec.'],
        [3.5, 'It is 24 bytes, the same as the std::vector it replaced.'],
        [7, 'Sixteen of those bytes hold four limbs. The rest is the count and the capacity.'],
        [10.5, 'Four limbs are 36 digits, so a number under 10 to the 36th keeps its limbs inside.']],
  build(g) {
    const W = 36; // px per byte
    const row = (y, label, fields, hot) => {
      const gg = el('g', {}, g);
      txt(gg, 120, y - 16, label, 'body', 30);
      let x = 120;
      fields.forEach(([name, bytes]) => {
        box(gg, x, y, bytes * W - 6, 90, hot && name.startsWith('limb') ? 'slot on' : 'bx2', 8);
        txt(gg, x + (bytes * W - 6) / 2, y + 55, name, 'mono', 22, 'middle');
        x += bytes * W;
      });
      txt(gg, x + 20, y + 55, '24 bytes', 'lbl', 24);
      return gg;
    };
    const vec = row(230, 'std::vector<uint32_t>', [['pointer', 8], ['size', 8], ['capacity', 8]]);
    const lv = row(480, 'LimbVec', [['limb 0', 4], ['limb 1', 4], ['limb 2', 4], ['limb 3', 4], ['n_', 4], ['cap_', 4]], true);
    const brace = txt(g, 120 + 8 * W, 640, 'union: four inline limbs, or a heap pointer', 'lbl', 24, 'middle');
    const big = txt(g, 800, 790, 'under 10³⁶: no allocation for the limbs', 'disp t-amber', 60, 'middle');
    return t => {
      op(vec, seg(t, 3.4, 3.9)); op(lv, seg(t, .6, 1.2));
      op(brace, seg(t, 7.3, 7.8)); op(big, seg(t, 10.8, 11.4));
    };
  }
},
{
  title: 'The spill', dur: 13,
  cap: [[0, 'Past four limbs, the vector spills.'],
        [2.5, 'The capacity doubles to eight, and the limbs are copied to the heap.'],
        [6, 'Whether the limbs are inside or on the heap is read from the capacity alone.'],
        [9.5, 'And once a vector has spilled, it stays on the heap, even if the number shrinks.']],
  build(g) {
    txt(g, 120, 130, '[*] 1..40', 'code', 44);
    txt(g, 470, 130, '48 digits, six limbs', 'lbl', 28);
    const inl = limbs(g, 120, 230, 4, 170, 70);
    const cap = txt(g, 900, 275, '', 'mono', 32);
    const ptr = el('g', {}, g);
    box(ptr, 120, 230, 4 * 186 - 16, 70, 'bx2', 8);
    txt(ptr, 120 + (4 * 186 - 16) / 2, 276, 'heap_  →', 'mono t-teal', 28, 'middle');
    const heap = limbs(g, 120, 470, 8, 150, 70);
    const hl = txt(g, 120, 600, 'on the heap: capacity 8, six used', 'lbl', 24);
    const S = stamp(g, 1340, 400);
    const rule = txt(g, 800, 720, 'cap_ > 4  ⇒  on the heap', 'mono t-amber', 44, 'middle');
    const stay = txt(g, 800, 800, 'no shrinking back', 'body t-muted', 32, 'middle');
    return t => {
      const k = Math.floor(lin(t, .3, 2.2) * 5);
      inl.forEach((c, i) => { c.r.classList.toggle('on', i < k); c.s.textContent = i < k ? '·' : ''; });
      const spilled = t > 3;
      op(ptr, seg(t, 3, 3.4));
      cap.textContent = spilled ? 'cap_ = 8' : 'cap_ = 4';
      heap.forEach((c, i) => { op(c.gg, seg(t, 3.3, 3.7)); const on = spilled && i < Math.min(6, Math.floor(lin(t, 3.5, 5) * 7)); c.r.classList.toggle('on', on); c.s.textContent = on ? '·' : ''; });
      op(hl, seg(t, 4.8, 5.2)); op(S, seg(t, 3.2, 3.4));
      op(rule, seg(t, 6.3, 6.8)); op(stay, seg(t, 9.8, 10.3));
    };
  }
},
{
  title: 'Who is left out', dur: 13,
  cap: [[0, 'Some things stay as they were.'],
        [2.5, 'A native int never becomes a BigInt. It wraps at 64 bits, the same as in Rakudo.'],
        [6.5, 'Numbers of 10 to the 36th and above still put their limbs on the heap.'],
        [9.5, 'And every Rat still has its cold block and two shared pointers. That part is still to do.']],
  build(g) {
    const cards = [
      ['my int $w', 'wraps at 64 bits', 'my int $w = 2**63 - 1; $w++;  # -9223372036854775808'],
      ['10³⁶ and up', 'limbs on the heap', 'five limbs or more spill, as before'],
      ['every Rat', 'cold block + two shared_ptr', 'still left, per INTERP-SPEED-PLAN']];
    const at = [2.5, 6.5, 9.5];
    const G = cards.map(([a, b, c], i) => {
      const gg = el('g', {}, g), y = 150 + i * 220;
      box(gg, 120, y, 1360, 180);
      txt(gg, 160, y + 70, a, 'disp t-amber', 48);
      txt(gg, 560, y + 70, b, 'body', 34);
      txt(gg, 160, y + 135, c, 'mono t-muted', 24);
      return gg;
    });
    return t => { G.forEach((e, i) => op(e, seg(t, at[i], at[i] + .5))); };
  }
},
{
  title: 'Before and after', dur: 12,
  cap: [[0, 'Same loop, same numbers.'],
        [2.5, 'Allocations per iteration of the rats kernel: from ten to six.'],
        [6, 'The rats and bigint benchmarks ran about seven percent faster.'],
        [9, 'And the answers did not change: a differential run of three thousand rounds matched the previous build and Rakudo.']],
  build(g) {
    txt(g, 120, 170, 'allocations per iteration, rats kernel', 'lbl', 28);
    const dots = (y, n, cls) => Array.from({ length: n }, (_, i) => el('circle', { cx: 150 + i * 70, cy: y, r: 24, class: cls }, g));
    txt(g, 900, 272, 'before: 10', 'mono t-coral', 34);
    txt(g, 900, 392, 'after: 6', 'mono t-amber', 34);
    const B = dots(260, 10, 'bul'), A = dots(380, 6, 'bit on');
    const bars = [['tools/bench/rats.raku', 7.4], ['tools/bench/bigint.raku', 7.2]].map(([n, p], i) => {
      const gg = el('g', {}, g), y = 520 + i * 100;
      txt(gg, 120, y + 40, n, 'mono', 26);
      const r = box(gg, 560, y, 0, 60, 'slot on', 6);
      const v = txt(gg, 580, y + 42, '−' + p + '%', 'mono t-amber', 30);
      return { gg, r, v, p };
    });
    const same = txt(g, 800, 810, '3,000 rounds, 1–200 digits: identical output', 'body t-teal', 32, 'middle');
    return t => {
      B.forEach((c, i) => op(c, seg(t, 2.5 + i * .1, 2.7 + i * .1)));
      A.forEach((c, i) => op(c, seg(t, 3.8 + i * .1, 4 + i * .1)));
      bars.forEach(b => {
        op(b.gg, seg(t, 6, 6.4)); const w = b.p * 60 * seg(t, 6.2, 7.2);
        b.r.setAttribute('width', w); b.v.setAttribute('x', 580 + w);
      });
      op(same, seg(t, 9.2, 9.7));
    };
  }
},
{
  title: 'Credits', dur: 9,
  cap: [[0, ''], [3.5, 'Coming up next: a block of code that can stop halfway, and wait.']],
  build(g) {
    const a = txt(g, 800, 330, 'THE CARRY', 'disp', 170, 'middle');
    const b = txt(g, 800, 420, 'Raku++ Internals · Episode 3', 'body t-amber', 40, 'middle');
    const c = txt(g, 800, 540, 'Drawn from commit b81c74fd, src/BigInt.h, src/Value.h and src/IntOps.h', 'lbl', 26, 'middle');
    const d = txt(g, 800, 660, 'Coming up: take, and wait', 'body', 34, 'middle');
    return t => { op(a, seg(t, 0, 1)); op(b, seg(t, .8, 1.8)); op(c, seg(t, 2, 3)); op(d, seg(t, 3.5, 4.5)); };
  }
}]);
