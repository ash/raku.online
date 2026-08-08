/* copy.js — a Copy button on every static code sample.
 *
 * The runnable editors get one from raku.js already; this covers the blocks
 * that are NOT editors — the shell transcripts, the module snippets, the echo
 * server the page tells you to save and run. The button is injected rather than
 * written into the markup so the pages stay readable and no sample can be
 * forgotten.
 *
 * The visual class is base.css's `.copy-btn`, the same one the spec's static
 * examples use, so there is one look for this control across the site. The
 * clipboard logic is spec.js's, and deliberately identical: navigator.clipboard
 * where it exists (https), the execCommand textarea otherwise (file:// previews,
 * and any context where a permission policy rejects the modern call). This file
 * is not loaded on spec pages, so the two handlers never see the same click.
 */
(function () {
  'use strict';

  function wrap(pre) {
    if (pre.parentElement && pre.parentElement.classList.contains('copy-wrap')) return;
    var box = document.createElement('div');
    box.className = 'copy-wrap';
    pre.parentNode.insertBefore(box, pre);
    box.appendChild(pre);
    var btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'copy-btn';
    btn.textContent = 'Copy';
    btn.setAttribute('aria-label', 'Copy this code to the clipboard');
    box.insertBefore(btn, pre);   // before the <pre>, as the spec's markup has it
  }

  // What lands on the clipboard. A transcript — one where prompts are marked up —
  // copies its COMMANDS ONLY, without the `$ `: pasting a shell session back into
  // a shell is otherwise a small act of vandalism, since the echoed output goes
  // with it. Everything else copies exactly what is on screen.
  function textOf(pre) {
    if (!pre.querySelector('.sh-p')) return pre.textContent;
    var lines = pre.textContent.split('\n'), cmds = [];
    for (var i = 0; i < lines.length; i++) {
      if (/^\$ /.test(lines[i])) cmds.push(lines[i].slice(2));
    }
    return cmds.length ? cmds.join('\n') : pre.textContent;
  }

  function flash(btn) {
    btn.classList.add('copied');
    var label = btn.textContent;
    btn.textContent = 'Copied';
    setTimeout(function () {
      btn.classList.remove('copied');
      btn.textContent = label;
    }, 1400);
  }

  document.addEventListener('click', function (e) {
    var btn = e.target.closest ? e.target.closest('.copy-wrap > .copy-btn') : null;
    if (!btn) return;
    var pre = btn.parentElement.querySelector('pre');
    if (!pre) return;
    var text = textOf(pre);

    function fallback() {
      var ta = document.createElement('textarea');
      ta.value = text;
      ta.style.position = 'fixed';
      ta.style.opacity = '0';
      document.body.appendChild(ta);
      ta.select();
      var ok = false;
      try { ok = document.execCommand('copy'); } catch (err) { ok = false; }
      document.body.removeChild(ta);
      if (ok) flash(btn);
    }

    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(function () { flash(btn); }, fallback);
    } else {
      fallback();
    }
  });

  function enhanceAll() {
    var pres = document.querySelectorAll('pre.native-code');
    for (var i = 0; i < pres.length; i++) wrap(pres[i]);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', enhanceAll);
  } else {
    enhanceAll();
  }
})();
