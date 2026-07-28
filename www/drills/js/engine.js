/* engine.js — a thin front end for the Raku++ / Raku.js WebAssembly interpreter.
 *
 * engine/worker.js is Andrew Shitov's own worker from the rakupp playground, used
 * verbatim: post {type:'run', src, stdin} and it answers with 'ready', 'start',
 * 'out', 'done', 'runerror' or 'loaderror'. All this file adds is a promise-shaped
 * API, a run queue (rakupp_run is synchronous, so one program at a time) and a
 * watchdog that kills a runaway worker and boots a fresh one.
 */
(function (global) {
  'use strict';

  const DEFAULT_TIMEOUT = 10000;

  let worker = null;
  let status = 'loading';   // loading | ready | busy | error
  let version = '';
  let errorMsg = '';
  let current = null;       // the in-flight run
  const queue = [];
  const watchers = new Set();

  function setStatus(s) { status = s; watchers.forEach((f) => f(status, version, errorMsg)); }

  function boot() {
    try {
      worker = new Worker('engine/worker.js');
    } catch (e) {
      errorMsg = String(e);
      setStatus('error');
      return;
    }
    worker.onerror = (e) => {
      // Most often: the page was opened as file://, where workers are blocked.
      errorMsg = e.message || 'worker failed to start';
      if (location.protocol === 'file:') {
        errorMsg = 'Raku.js needs to be served over http:// — run ./serve.sh and open localhost.';
      }
      setStatus('error');
      finish({ ok: false, error: errorMsg, out: [] });
    };
    worker.onmessage = (e) => {
      const d = e.data;
      switch (d.type) {
        case 'ready':
          version = d.version || '';
          // The site bar names the engine too, and the drills load their own
          // rather than raku.js, so publish the same signal raku.js does.
          if (version) {
            const v = String(version).match(/\d+\.\d+\.\d+/);
            window.__RAKUPP_VERSION = v ? v[0] : String(version);
            try {
              window.dispatchEvent(new CustomEvent('rakupp:ready',
                { detail: { version: window.__RAKUPP_VERSION } }));
            } catch (e) { /* the global is still set */ }
          }
          setStatus(current ? 'busy' : 'ready');
          break;
        case 'loaderror':
          errorMsg = d.message || 'engine failed to load';
          setStatus('error');
          finish({ ok: false, error: errorMsg, out: [] });
          break;
        case 'start':
          break;
        case 'out':
          if (current) {
            current.out.push(d);
            if (current.onOut) current.onOut(d.text, d.cls);
          }
          break;
        case 'done':
          finish({ ok: true, rc: d.rc, ms: d.ms, out: current ? current.out : [] });
          break;
        case 'runerror':
          finish({
            ok: false,
            error: d.deep ? 'deep recursion — the program was stopped' : d.message,
            out: current ? current.out : [],
          });
          break;
      }
    };
  }

  function finish(result) {
    if (!current) return;
    const c = current;
    current = null;
    clearTimeout(c.timer);
    if (status !== 'error') setStatus('ready');
    c.resolve(Object.assign({ text: textOf(result.out) }, result));
    pump();
  }

  function textOf(out) { return (out || []).map((o) => o.text).join(''); }

  function pump() {
    if (current || !queue.length || !worker) return;
    current = queue.shift();
    setStatus('busy');
    current.timer = setTimeout(() => {
      // Synchronous interpreter: the only way out of an endless loop is a kill.
      worker.terminate();
      worker = null;
      const c = current;
      current = null;
      boot();
      c.resolve({ ok: false, error: 'timed out after ' + (c.timeoutMs / 1000) + 's', out: c.out, text: textOf(c.out) });
      pump();
    }, current.timeoutMs);
    worker.postMessage({ type: 'run', src: current.src, stdin: current.stdin });
  }

  const Engine = {
    init() { if (!worker) boot(); return Engine; },

    get status() { return status; },
    get version() { return version; },
    get error() { return errorMsg; },
    get ready() { return status === 'ready' || status === 'busy'; },

    onStatus(fn) { watchers.add(fn); fn(status, version, errorMsg); return () => watchers.delete(fn); },

    /* Run a program. Always resolves — never rejects — with
     * { ok, text, out, rc, ms, error }. */
    run(src, opts) {
      opts = opts || {};
      if (status === 'error') {
        return Promise.resolve({ ok: false, error: errorMsg, out: [], text: '' });
      }
      if (!worker) boot();
      return new Promise((resolve) => {
        queue.push({
          src,
          stdin: opts.stdin || '',
          onOut: opts.onOut,
          timeoutMs: opts.timeoutMs || DEFAULT_TIMEOUT,
          out: [],
          resolve,
        });
        pump();
      });
    },

    /* Kill whatever is running and start a clean instance. */
    cancel() {
      if (!current) return;
      const c = current;
      clearTimeout(c.timer);
      current = null;
      if (worker) worker.terminate();
      worker = null;
      boot();
      c.resolve({ ok: false, error: 'stopped', out: c.out, text: textOf(c.out) });
      pump();
    },
  };

  global.Engine = Engine;
})(window);
