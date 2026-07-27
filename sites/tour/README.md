# raku-tour — A Tour of Raku

▶ **Take the tour: [tour.raku.online](https://tour.raku.online/)**

An interactive introduction to the Raku language: 18 short lessons, each built
around live code. **Every example is an editable, runnable editor in the
browser** — powered by [Raku++](https://github.com/ash/rakupp) compiled to
WebAssembly, the same engine as the [raku.online](https://raku.online/)
playground ([source](https://github.com/ash/raku.online)). Nothing to install;
nothing leaves the visitor's machine.

Where the [Raku++ specification](https://spec.raku.online/) is the *reference*
(every feature, pinned down), the tour is the *front door*: a linear path from
`say 'Hello, World!'` to grammars and junctions, with an exercise at the end of
almost every lesson and a collapsed solution to compare against.

## Verified lessons

`build.raku --verify` runs every example (and every exercise solution) through
the real `rakupp` binary and fails the build on any output mismatch, so the tour
cannot drift from the interpreter it teaches. `--oracle=raku` additionally
cross-checks every example against Rakudo; the current lesson set passes both
gates: 69 examples, 0 mismatches.

## The toolchain is Raku++ itself

The generator is written in Raku and run by `rakupp`; the site is previewed with
`rakus`, the Raku++ static file server. Building the tour is itself an act of
dogfooding the interpreter it teaches.

```sh
rakupp build.raku                  # build src/ -> out/
rakupp build.raku --verify         # + run every example through rakupp
rakupp build.raku --verify --oracle=raku   # + cross-check against Rakudo
rakupp path/to/raku++/showcase/rakus/rakus.raku 8317 out   # preview locally
```

## Layout

```
build.raku            the static generator (run by rakupp)
.github/workflows/    build + verify + publish to GitHub Pages (tour.raku.online)
deploy.sh             the same, for a self-hosted doc root over sshfs (fallback)
src/
  site.raku           site config (title, links) — EVAL'd by the build
  theme/
    base.css          light/dark theme (shared look with spec.raku.online)
    tour.js           progress ticks, Continue button, ←/→ navigation
  lessons/
    NN-slug.md        one lesson per file, ordered by filename;
                      consecutive lessons with the same `chapter:` group together
out/                  generated static site (git-ignored)
```

## Authoring a lesson

Each lesson is a Markdown-ish file with frontmatter:

```
---
title: Variables
chapter: Basics
summary: One-line summary shown under the title.
---
```

Fenced blocks do the work:

    ```raku            an editable, runnable editor
    ```raku run        …that also auto-runs when the page loads
    ```output          expected output of the block above (checked by --verify)
    ```raku exercise   starter code for the reader — never verified
    ```solution        collapsed "Show a solution" editor (verified like any example)

Reader progress lives in `localStorage` (`raku-tour-done`): visiting a lesson
ticks it in the sidebar and the home overview, and the home page grows a
"Continue at lesson N" button. The ← and → keys walk the tour.
