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
  index.html          the playground page (editor, output pane, share/open UI)
  worker.js           runs the WASM interpreter off the main thread
  raku.js             drop-in widget for embedding editors on other pages
  embed-demo.html     live guide + examples for raku.js
  embed-builder.html  paste code → copy a ready embed snippet (live preview)
  rakujs.js           Emscripten-generated loader        (built artifact)
  rakujs.wasm         the Raku++ interpreter, ~4.6 MB    (built artifact)
  examples.js         the example dropdown data          (built artifact)
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

A collapsible **Stdin** strip under the editor feeds the program's standard
input (`get`, `lines`, `prompt`, `$*IN` — EOF after the last line, fresh per
run). Non-empty input travels with share links as `&stdin=<data>`, encoded the
same way as `#code=`.

Example:

```
https://raku.online/?gh=ash/rakupp/main/examples/anagrams.raku&run=1
```

## Embedding on other pages (`raku.js`)

`www/raku.js` turns the playground into a widget any site can drop in. One
script tag, then any element with `data-raku` becomes a runnable editor:

```html
<script src="https://raku.online/raku.js"></script>

<!-- shows the code, and makes it runnable -->
<pre data-raku>say "Hello from an embedded editor!";</pre>

<!-- an empty editor to type into -->
<div data-raku data-rows="6"></div>
```

Per-element attributes: `data-run` (run once on load), `data-stdin="…"` (preset
standard input and reveal the input box), `data-rows="N"` (initial height),
`data-theme="light|dark"` (force a theme; default follows the OS).

Script-tag options: `data-theme="…"` (page-wide theme default), `data-selector`
(what to enhance, default `[data-raku]`), and `data-auto` — with it, ordinary
highlighter code blocks (`<pre><code class="language-raku">`, what markdown /
Prism / highlight.js emit) become runnable with no `data-raku`, so authors add
the script once and change nothing else:

```html
<script src="https://raku.online/raku.js" data-auto></script>
```

`data-auto` matches `language-raku` on the `<code>` (highlighters) **or** a
bare `raku`/`language-raku` class on the `<pre>` itself.

Attach programmatically with `RakuEmbed.enhance(el, opts)` / `RakuEmbed.enhanceAll()`.

**No hand-written HTML?** The **[embed builder](https://raku.online/embed-builder.html)**
(`www/embed-builder.html`) lets you paste code, tick options, and copy a
ready snippet with a live preview.

### WordPress block editor

Gutenberg rejects a bare boolean attribute, so `<pre data-raku>` in a Custom
HTML block fails validation — write `data-raku=""` (explicit empty value) and
it passes. Better, skip Custom HTML entirely:

1. Load `raku.js` **with `data-auto`** once (theme/footer, gated by category —
   see the WordPress note below).
2. Use the normal **Code block**, and in its **Advanced → Additional CSS
   class(es)** field add `raku`.

That Code block becomes a runnable editor — native editor UI, only the blocks
you tag, no plugin, no Custom HTML.

Design points that make it embed-safe:

- **Each editor is in its own Shadow DOM** — the host page's CSS can't reach in
  and the widget's styles can't leak out, so it looks identical on any site.
- **All blocks on a page share one Web Worker / one WASM instance** (built from
  a Blob so it works cross-origin), so ten code blocks still download the
  interpreter once. Programs run one at a time.
- The **input box appears only when the code reads stdin** (`get`/`lines`/
  `prompt`/`$*IN`); the **output box appears on the first run**.

The **🔗 Share** popover in the full playground generates a ready-to-paste
snippet for the current program. A live guide lives at
[`/embed-demo.html`](www/embed-demo.html).

**WordPress note:** post content often strips `<script>`, so add the one script
line to the theme/footer (or via a plugin) and use `<pre data-raku>` blocks in
posts — those are plain content and survive sanitizing.

**Server requirement — CORS.** Cross-origin embeds fetch the engine from
raku.online, so the static assets must send `Access-Control-Allow-Origin`.
Add to the nginx server block:

```nginx
location ~* \.(wasm|js)$ {
    add_header Access-Control-Allow-Origin *;
}
```

Without it, embeds on other domains fail to load the WASM (same-origin pages,
i.e. raku.online itself, are unaffected).

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
