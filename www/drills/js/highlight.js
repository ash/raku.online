/* highlight.js — a small, dependency-free Raku syntax highlighter.
 *
 * It is deliberately shallow: one linear scan, no parser. Good enough for the
 * short snippets a drill shows, and it never throws on input it doesn't grasp —
 * anything unrecognised is emitted as plain text.
 */
(function (global) {
  'use strict';

  const KEYWORDS = new Set([
    'my', 'our', 'has', 'state', 'let', 'temp', 'constant', 'anon',
    'sub', 'submethod', 'method', 'multi', 'proto', 'only', 'macro',
    'class', 'role', 'grammar', 'module', 'package', 'enum', 'subset', 'augment',
    'token', 'rule', 'regex',
    'if', 'elsif', 'else', 'unless', 'with', 'orwith', 'without',
    'for', 'while', 'until', 'repeat', 'loop', 'given', 'when', 'default',
    'return', 'return-rw', 'take', 'gather', 'last', 'next', 'redo', 'succeed', 'proceed',
    'use', 'need', 'require', 'import', 'unit', 'is', 'does', 'but', 'as', 'handles', 'where',
    'try', 'catch', 'throw', 'die', 'fail', 'warn', 'quietly', 'once',
    'start', 'await', 'react', 'whenever', 'supply', 'emit', 'done',
    'so', 'not', 'and', 'or', 'andthen', 'orelse', 'notandthen', 'xor',
    'BEGIN', 'CHECK', 'INIT', 'END', 'DOC',
    'ENTER', 'LEAVE', 'KEEP', 'UNDO', 'PRE', 'POST',
    'FIRST', 'NEXT', 'LAST', 'CATCH', 'CONTROL', 'CLOSE', 'QUIT', 'COMPOSE',
    'self', 'sink', 'eager', 'lazy', 'hyper', 'race', 'will', 'EVAL',
  ]);

  // Words that read as types/constants rather than plain identifiers.
  const CONSTS = new Set(['True', 'False', 'Nil', 'Inf', 'NaN', 'Any', 'Mu', 'Empty']);

  const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  const span = (cls, s) => '<span class="tk-' + cls + '">' + esc(s) + '</span>';

  // One pass, first-match-wins. Order is the whole design.
  const RX = new RegExp([
    /(?<com>#[^\n]*)/,                                        // comment
    /(?<pod>^=(?:begin|end|head\d?|item|para)[^\n]*)/,        // pod marker
    /(?<str>'(?:[^'\\\n]|\\.)*'|"(?:[^"\\\n]|\\.)*"|「[^」]*」)/,  // quoted string
    /(?<qw>«[^»\n]*»|<[A-Za-z0-9_\s\-.\/*+'"|=]*>)/,          // <word list> / %h<key>
    /(?<rx>(?:m|rx|s|tr|S|TR)?\/(?:[^\/\\\n]|\\.)*\/)/,       // regex-ish literal
    /(?<vr>[$@%&][.!^:*?=~][\w'-]+|[$@%&]\*?[A-Za-z_][\w'-]*|[$@%&]\^?[\w]|\$[\/!_0-9<]|\$\.)/, // variables
    /(?<num>\b0[xbo][0-9a-fA-F_]+\b|\b\d[\d_]*(?:\.\d[\d_]*)?(?:[eE][-+]?\d+)?\b)/,
    /(?<word>\b[A-Za-z_][\w'-]*\b)/,
    /(?<op>[^\sA-Za-z0-9_]+)/,
  ].map((r) => r.source).join('|'), 'gm');

  function highlight(src) {
    let out = '', last = 0, m;
    RX.lastIndex = 0;
    while ((m = RX.exec(src)) !== null) {
      if (m.index > last) out += esc(src.slice(last, m.index));
      const g = m.groups;
      const t = m[0];

      if (g.com || g.pod) out += span('com', t);
      else if (g.str || g.qw) out += span('str', t);
      else if (g.rx) out += span('str', t);
      else if (g.vr) out += span('var', t);
      else if (g.num) out += span('num', t);
      else if (g.word) {
        if (KEYWORDS.has(t)) out += span('key', t);
        else if (CONSTS.has(t) || /^[A-Z][A-Za-z0-9]*$/.test(t)) out += span('type', t);
        else out += esc(t);
      } else if (g.op) out += span('op', t);
      else out += esc(t);

      last = m.index + t.length;
    }
    out += esc(src.slice(last));
    return out;
  }

  /* Render a snippet. If it contains the blank marker `___`, the marker is kept
   * out of the tokeniser (it would highlight as an identifier) and each piece is
   * highlighted independently; the caller splices its own <input> into the gaps. */
  function renderCode(src) {
    return '<pre>' + highlight(src) + '</pre>';
  }

  function renderCodeWithBlanks(src, blankHtml) {
    const parts = src.split('___');
    let html = '';
    for (let i = 0; i < parts.length; i++) {
      html += highlight(parts[i]);
      if (i < parts.length - 1) html += blankHtml(i);
    }
    return '<pre>' + html + '</pre>';
  }

  global.RakuHL = { highlight, renderCode, renderCodeWithBlanks, esc };
})(window);
