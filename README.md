# raku.online

The site behind [raku.online](https://raku.online/) — a Raku playground that
runs entirely in the browser. The interpreter is
[Raku++](https://github.com/ash/rakupp) (a Raku implementation in C++)
compiled to WebAssembly as
[Raku.js](https://github.com/ash/rakupp/blob/main/rakujs/README.md).
No code is sent to a server: programs execute in a Web Worker on the
visitor's machine, and the site itself is five static files.

## Layout

```
www/
  index.html    the playground page (editor, output pane, share/open UI)
  worker.js     runs the WASM interpreter off the main thread
  rakujs.js     Emscripten-generated loader        (built artifact)
  rakujs.wasm   the Raku++ interpreter, ~4.4 MB    (built artifact)
  examples.js   the example dropdown data          (built artifact)
```

The three built artifacts are committed so the repo is deployable as-is.
They are produced by `rakujs/build.sh` in the
[rakupp](https://github.com/ash/rakupp) repo, which is also the upstream of
`index.html`/`worker.js` (`rakujs/playground/`); this repo carries the
raku.online-specific branding (title, footer).

## Shareable links

The playground opens pre-filled from URL parameters — nothing is stored
server-side:

| URL form | Where the code lives |
|---|---|
| `#code=<data>` | in the URL itself (deflate-compressed, base64url) |
| `?gist=<id>[&file=<name>]` | a GitHub gist, fetched client-side |
| `?gh=<owner>/<repo>/<branch>/<path>` | a file in a GitHub repo (raw) |
| `?url=<encoded-url>` | any https URL whose host allows CORS fetches |

Append `&run=1` to run the code on load. The **🔗 Share** button builds the
`#code=` form and copies it; the **📂 Open…** button accepts a pasted GitHub /
gist / raw URL and rewrites the address bar to the matching persistent link.

Example:

```
https://raku.online/?gh=ash/rakupp/main/examples/anagrams.raku&run=1
```

## Deploy

The site is plain static files behind nginx. `deploy.sh` copies `www/` to the
server mount (sshfs) and removes the `._*` AppleDouble files macOS `cp`
leaves behind:

```sh
./deploy.sh                 # default: /Users/ash/sshfs/raku.online/raku.online/www
./deploy.sh /path/to/www    # or an explicit destination
```

nginx needs `application/wasm wasm;` in its `mime.types` (added there on the
server) so the browser can use streaming WASM compilation.

## Updating the interpreter

Build fresh artifacts in rakupp (`rakujs/build.sh`), copy
`rakujs.{js,wasm}` + `examples.js` into `www/`, commit, deploy.
