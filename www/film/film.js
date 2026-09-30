// film.js — the Raku++ Internals film player.
//
// An episode page loads this file, sets window.FILM_VO (the narration: one
// audio track per style, with an [offset, duration] pair per spoken caption),
// then loads its own scenes.js, which calls Film.play(scenes).
//
// A scene is { title, dur, cap: [[t, text], ...], build(g) }: build draws into
// the SVG group g and returns update(t), called every frame with the scene's
// own clock t (seconds, 0..dur). Captions are timed on that clock. The player
// stretches each caption's stretch of time to fit its spoken line, so scenes
// are written against their silent timing and never know about the voice.

// ---- drawing helpers, shared by every episode's scenes ----------------------

const NS = 'http://www.w3.org/2000/svg';
function el(tag, a = {}, p, s) { const e = document.createElementNS(NS, tag); for (const k in a) e.setAttribute(k, a[k]); if (s != null) e.textContent = s; if (p) p.appendChild(e); return e; }
const clamp = (x, a = 0, b = 1) => Math.min(b, Math.max(a, x));
const ease = x => x < .5 ? 2 * x * x : 1 - Math.pow(-2 * x + 2, 2) / 2;
const seg = (t, a, b) => ease(clamp((t - a) / (b - a)));
const lin = (t, a, b) => clamp((t - a) / (b - a));
const op = (e, v) => e.setAttribute('opacity', clamp(v).toFixed(3));
const mv = (e, x, y) => e.setAttribute('transform', `translate(${x.toFixed(1)},${y.toFixed(1)})`);
const box = (p, x, y, w, h, cls = 'bx', r = 14) => el('rect', { x, y, width: w, height: h, rx: r, class: cls }, p);
const txt = (p, x, y, s, cls, size, anchor = 'start') => el('text', { x, y, class: cls, 'font-size': size, 'text-anchor': anchor }, p, s);
const line = (p, x1, y1, x2, y2, cls = 'arrow', m = 'ah') => el('line', { x1, y1, x2, y2, class: cls, 'marker-end': `url(#${m})` }, p);
const fmt = n => Math.floor(n).toLocaleString('en-US');
function track(t, k) {
  if (t <= k[0][0]) return [k[0][1], k[0][2]];
  for (let i = 1; i < k.length; i++) if (t <= k[i][0]) {
    const a = k[i - 1], b = k[i], u = ease((t - a[0]) / (b[0] - a[0]));
    return [a[1] + (b[1] - a[1]) * u, a[2] + (b[2] - a[2]) * u];
  }
  const z = k[k.length - 1]; return [z[1], z[2]];
}
// A typed code block: lines are arrays of [text, key?, cls?] segments.
function codeBlock(g, x, y, lines, fs = 34, lh = 1.5) {
  const segs = []; let total = 0;
  lines.forEach((ln, i) => {
    const t = el('text', { x, y: y + i * fs * lh, class: 'code', 'font-size': fs }, g);
    ln.forEach(([s, k, c]) => { const ts = el('tspan', c ? { class: c } : {}, t); segs.push({ ts, s, start: total, k }); total += s.length; });
    total += 1;
  });
  return {
    total,
    type(n) { segs.forEach(o => { o.ts.textContent = o.s.slice(0, Math.max(0, n - o.start)); }); },
    mark(k, on) { segs.forEach(o => { if (o.k === k) o.ts.classList.toggle('hl', on); }); }
  };
}
function hash(t) { const n = Math.floor(t * 18) * 2654435761 >>> 0; return '0x' + n.toString(16).padStart(8, '0'); }


// ---- the player -------------------------------------------------------------

const Film = { play };

function play(scenes) {
  const VO = window.FILM_VO;
  const LEAD = .25, TAIL = .5;
  const RATES = [.75, 1, 1.25, 1.5];
  const store = {
    get(k) { try { return localStorage.getItem('film-' + k); } catch (e) { return null; } },
    set(k, v) { try { localStorage.setItem('film-' + k, v); } catch (e) {} }
  };

  // The timeline: one segment per caption. A segment keeps its scripted length
  // or stretches to fit its spoken line; the animation plays at normal speed,
  // holds, and replays the segment's last moments before the next caption.
  let segs = [], total = 0, sceneStart = [];
  let style = VO.styles.find(s => s.id === store.get('style')) || VO.styles[0];
  let rate = Number(store.get('rate')) || 1;
  if (!RATES.includes(rate)) rate = 1;
  function buildTimeline(st) {
    segs = []; total = 0; sceneStart = []; let clipNo = 0;
    scenes.forEach((s, si) => {
      sceneStart.push(total);
      s.cap.forEach((c, k) => {
        const end = k + 1 < s.cap.length ? s.cap[k + 1][0] : s.dur, o = end - c[0];
        const text = c[1] && st.subs ? st.subs[clipNo] : c[1];
        const clip = c[1] ? st.clips[clipNo++] : null;
        const n = clip ? Math.max(o, LEAD + clip[1] + TAIL) : o;
        segs.push({ si, c: c[0], o, n, start: total, text, clip });
        total += n;
      });
    });
    if (clipNo !== st.clips.length)
      console.error(`film: the scenes have ${clipNo} spoken captions, the ${st.id} narration has ${st.clips.length} lines`);
  }
  function warp(g, u) {
    const d = g.n - g.o, h = Math.min(.6, g.o), p = g.o - h;
    return g.c + (u < p ? u : u < p + d ? p : u - d);
  }

  const $ = id => document.getElementById(id);
  const stage = $('stage'), capEl = $('cap'), prog = $('prog'), fill = $('fill'), clock = $('clock');
  const playBtn = $('play'), bigPlay = $('bigplay'), voBtn = $('vo');
  const audio = new Audio(); audio.preload = 'auto';
  const mmss = s => `${Math.floor(s / 60)}:${String(Math.floor(s % 60)).padStart(2, '0')}`;

  const chapBtns = scenes.map((s, i) => {
    const li = document.createElement('li'), b = document.createElement('button');
    b.type = 'button'; b.innerHTML = '<span></span><b></b>'; b.querySelector('b').textContent = s.title;
    b.addEventListener('click', () => { seek(sceneStart[i] + .001); setPlaying(true); });
    li.appendChild(b); $('chap').appendChild(li); return b;
  });
  function useStyle() {
    audio.pause(); audio.src = style.src;
    buildTimeline(style);
    capKey = -1;
    $('stylenote').textContent = style.note;
    document.querySelectorAll('#styles button').forEach(b => b.setAttribute('aria-pressed', b.dataset.id === style.id));
    prog.setAttribute('aria-valuemax', Math.round(total));
    prog.querySelectorAll('.tick').forEach(d => d.remove());
    sceneStart.slice(1).forEach(s => { const d = document.createElement('div'); d.className = 'tick'; d.style.left = (s / total * 100) + '%'; prog.appendChild(d); });
    chapBtns.forEach((b, i) => { b.querySelector('span').textContent = mmss(sceneStart[i]); });
  }
  function pills(id, items, label, isOn, pick) {
    const bar = $(id);
    if (items.length < 2) { bar.parentElement.hidden = true; return; }
    items.forEach(it => {
      const b = document.createElement('button');
      b.type = 'button'; b.dataset.id = String(it.id ?? it); b.textContent = label(it);
      b.setAttribute('aria-pressed', isOn(it));
      b.addEventListener('click', () => {
        pick(it);
        bar.querySelectorAll('button').forEach(x => x.setAttribute('aria-pressed', x === b));
      });
      bar.appendChild(b);
    });
  }
  pills('styles', VO.styles, s => s.label, s => s === style, s => {
    // stay on the same caption, at the same fraction of it
    const gi = segAt(T), f = (T - segs[gi].start) / segs[gi].n;
    style = s; store.set('style', s.id); useStyle();
    seek(segs[gi].start + f * segs[gi].n);
  });
  pills('speeds', RATES, r => r + '×', r => r === rate, r => {
    rate = r; store.set('rate', r); audio.playbackRate = r;
  });
  $('credit').textContent = VO.credit;

  let T = 0, playing = false, started = false, voOn = true, cur = -1, upd = null, last = null, capKey = -1;
  function segAt(t) { let i = 0; while (i + 1 < segs.length && segs[i + 1].start <= t) i++; return i; }
  function sceneAt(t) { let i = 0; while (i + 1 < sceneStart.length && sceneStart[i + 1] <= t) i++; return i; }
  // The voice is stopped by its own position, not by the film's clock: audio
  // starts a little late (a seek, then play()), and a line whose clip ends on
  // its last syllable would otherwise lose it. Each line is left to finish; the
  // TAIL after it in the timeline absorbs the lag. Only a new line, a seek, or
  // a pause moves the audio.
  let voClip = null, resync = false;
  function syncAudio(g, u) {
    if (!playing || !voOn) { if (!audio.paused) audio.pause(); voClip = null; return; }
    if (voClip && !audio.paused && audio.currentTime >= voClip[0] + voClip[1] + .08) { audio.pause(); voClip = null; }
    if (!g.clip || u < LEAD || u >= LEAD + g.clip[1]) return;
    if (audio.playbackRate !== rate) audio.playbackRate = rate;
    const want = g.clip[0] + (u - LEAD);
    // A voice slightly behind the picture is left alone (that is start-up lag,
    // and correcting it would cut a word); one that is ahead, or far behind
    // because a seek did not take, is moved.
    const off = audio.currentTime - want;
    if (voClip !== g.clip || resync || audio.paused || off > .3 * rate || off < -1 * rate) {
      voClip = g.clip; resync = false;
      audio.currentTime = want;
      if (audio.paused) audio.play().catch(() => {});
    }
  }
  function render() {
    const gi = segAt(T), g = segs[gi], u = T - g.start, i = g.si, s = scenes[i], lt = warp(g, u);
    if (i !== cur) { stage.replaceChildren(); cur = i; upd = s.build(stage); chapBtns.forEach((b, j) => b.setAttribute('aria-current', j === i ? 'true' : 'false')); }
    upd(lt);
    op(stage, i === 0 ? 1 - seg(lt, s.dur - .5, s.dur) : Math.min(seg(lt, 0, .5), i === scenes.length - 1 ? 1 : 1 - seg(lt, s.dur - .5, s.dur)));
    if (gi !== capKey) { capKey = gi; capEl.textContent = g.text; }
    capEl.style.opacity = g.text ? seg(u, 0, .35) : 0;
    syncAudio(g, u);
    fill.style.width = (T / total * 100) + '%';
    prog.setAttribute('aria-valuenow', Math.floor(T));
    clock.textContent = `${mmss(T)} / ${mmss(total)}`;
  }
  function setPlaying(p) {
    if (p && T >= total - .01) T = 0;
    playing = p; started = started || p; bigPlay.hidden = started;
    playBtn.textContent = playing ? 'Pause' : 'Play';
    render();
  }
  function seek(t) { T = clamp(t, 0, total - .001); resync = true; if (!audio.paused) audio.pause(); render(); }
  function tick(now) {
    if (last != null && playing) {
      T += Math.min(.1, (now - last) / 1000) * rate;
      if (T >= total) { T = total - .001; playing = false; playBtn.textContent = 'Replay'; }
    }
    last = now; render(); requestAnimationFrame(tick);
  }
  playBtn.addEventListener('click', () => setPlaying(!playing));
  bigPlay.addEventListener('click', e => { e.stopPropagation(); setPlaying(true); });
  $('screen').addEventListener('click', () => setPlaying(!playing));
  voBtn.addEventListener('click', () => { voOn = !voOn; voBtn.textContent = voOn ? 'Narration on' : 'Narration off'; voBtn.setAttribute('aria-pressed', voOn); render(); });
  $('prev').addEventListener('click', () => { const i = sceneAt(T); seek(T - sceneStart[i] > 1.5 ? sceneStart[i] : sceneStart[Math.max(0, i - 1)]); });
  $('next').addEventListener('click', () => { const i = sceneAt(T); if (i + 1 < sceneStart.length) seek(sceneStart[i + 1]); });
  prog.addEventListener('click', e => { const r = prog.getBoundingClientRect(); seek((e.clientX - r.left) / r.width * total); });
  document.addEventListener('keydown', e => {
    if (e.target.closest && e.target.closest('input, textarea, select, [contenteditable]')) return;
    if (e.target.closest && e.target.closest('button') && e.key === ' ') return;
    if (e.key === ' ') { e.preventDefault(); setPlaying(!playing); }
    else if (e.key === 'ArrowRight') $('next').click();
    else if (e.key === 'ArrowLeft') $('prev').click();
  });
  useStyle();
  // Film.at(scene, fraction[, play]): go to one moment, paused unless play.
  // Film.audio: the voice.
  // Both are for checking frames and sync by hand.
  Film.audio = audio;
  Film.at = (i, f, go) => { setPlaying(false); seek(sceneStart[i] + f * ((sceneStart[i + 1] ?? total) - sceneStart[i])); if (go) setPlaying(true); };
  render(); requestAnimationFrame(tick);
}
