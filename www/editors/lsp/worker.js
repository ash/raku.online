// worker.js — the Raku++ language server, in a Web Worker.
//
// This is `rakupp --lsp`: the same C++ server, compiled to WebAssembly with the
// rest of Raku.js. In an editor it is a separate process that reads messages
// on stdin and writes them on stdout. Here the worker is the process and
// postMessage is the pipe. The page sends a JSON-RPC body, the worker hands it
// to rakupp_lsp(), and posts back every body the server answers with, in order.
// Nothing is changed on the way.
//
// One more export rides along, outside the protocol: rakupp_highlight() colours
// the editor. The server does not offer semantic tokens yet, so that is the
// highlighter behind `rakupp --highlight`, called directly.

/* global RakuJS */
// The page passes two cache tags: v= is the engine's (shared with the
// playground and raku.js, so the 13 MB engine is fetched once), l= is ours.
const P = new URLSearchParams(self.location.search);
const V = P.get('v') ? '?v=' + P.get('v') : '';
importScripts('/rakujs.js' + V);

const post = (type, extra = {}) => self.postMessage({ type, ...extra });

let Module = null;
let reference = '';   // docs/guide/REFERENCE.md: hover and completion text for built-ins

const ready = Promise.all([
  RakuJS({
    locateFile: p => '/' + p + V,
    print: t => console.log(t),
    printErr: t => console.warn(t),
  }),
  fetch('reference.md' + (P.get('l') ? '?l=' + P.get('l') : '')).then(r => (r.ok ? r.text() : '')).catch(() => ''),
]).then(([m, ref]) => {
  Module = m;
  reference = ref;
  post('ready', { version: m.ccall('rakupp_version', 'string', [], []) });
}).catch(err => post('loaderror', { message: String(err) }));

self.onmessage = async (e) => {
  await ready;
  if (!Module) return;
  const d = e.data;
  if (d.type === 'lsp') {
    const t0 = performance.now();
    let out;
    try {
      out = Module.ccall('rakupp_lsp', 'string', ['string', 'string'], [d.body, reference]);
    } catch (err) {
      post('servererror', { message: String(err) });
      return;
    }
    const ms = performance.now() - t0;
    // The server's bodies, each as its own message, re-serialised from the
    // array it returned (the content is the server's; only the spacing is ours).
    const bodies = JSON.parse(out).map(b => JSON.stringify(b));
    post('lsp', { bodies, ms, for: d.seq });
  } else if (d.type === 'highlight') {
    const html = Module.ccall('rakupp_highlight', 'string', ['string'], [d.src]);
    post('highlight', { html, seq: d.seq });
  }
};
