#!/usr/bin/env bun
// wasm-verify.cjs — the spec's third verification gate. build.raku runs this under Bun with
// the node-target build of raku.js (the same C++ the browser editors run) and a JSON list
// of the exact examples it just checked; each is run through the WASM engine and
// diffed against the declared output. Exits non-zero if any diverge, so an example
// that works in native Raku++ but not in the browser can't ship silently.
//
//   node tools/wasm-verify.cjs <rakujs-node.js> <examples.json>
//
// examples.json: [{ "p": "path:line", "s": "<source>", "e": "<expected>" }, …]
const fs = require('fs');

const modPath = process.argv[2];
const exPath = process.argv[3];
if (!modPath || !exPath) { console.error('usage: wasm-verify.cjs <module.js> <examples.json>'); process.exit(2); }

const examples = JSON.parse(fs.readFileSync(exPath, 'utf8'));

(async () => {
  let factory;
  try { factory = require(modPath); }
  catch (e) { console.error('wasm: could not load engine at ' + modPath + ' — ' + e.message); process.exit(2); }

  let buf = '';
  const mod = await factory({ print: (s) => { buf += s + '\n'; },
                              printErr: (s) => { buf += s + '\n'; } });

  let fail = 0;
  for (const ex of examples) {
    buf = '';
    let crashed = false;
    try { mod.ccall('rakupp_run', 'number', ['string'], [ex.s]); }
    catch (e) { crashed = true; }
    const got = buf.replace(/\s+$/, '');
    const want = (ex.e || '').replace(/\s+$/, '');
    if (crashed || got !== want) {
      fail++;
      console.error('  WASM MISMATCH ' + ex.p);
      console.error('    expected: ' + JSON.stringify(want));
      console.error('    raku.js:  ' + (crashed ? '<crashed — e.g. recursion cap>' : JSON.stringify(got)));
    }
  }
  console.log('verify: ' + examples.length + ' checked · ' + fail + ' raku.js (WASM) mismatch(es)');
  process.exit(fail ? 1 : 0);
})();
