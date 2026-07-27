# raku-spec — the Raku++ specification sites

Two sites, one repository, one deploy. Both are served from
**[spec.raku.online](https://spec.raku.online/)** (GitHub Pages, custom domain),
and in both every example runs live in your browser via the same WebAssembly
build of [Raku++](https://github.com/ash/rakupp) that powers the
[raku.online](https://raku.online/) playground.

| Site | URL | What it is |
|---|---|---|
| **Spec** | `/` | The readable feature guide — one page per feature, prose plus runnable examples. 129 pages. |
| **Rules** | `/rules/` | The exhaustive reference: every operator filed by precedence level, and every type with its hierarchy, signatures and return types. 536 pages. |

Where [Roast](https://github.com/Raku/roast) is a conformance *test suite* and
[docs.raku.org](https://docs.raku.org/) documents the *library*, these sites pin
down last-mile behaviour: what a construct does, what it returns, and where this
implementation and Rakudo part company.

## The toolchain is Raku++ itself

Every generator here is written in Raku and run by `rakupp`; the sites are
previewed with `rakus`, the Raku++ static file server. Building the spec is
itself an act of dogfooding the interpreter it documents.

---

## Where the facts come from

Nothing on either site is retyped from somewhere else. Three sources, each
answering a different question — and one source deliberately *not* used.

**The official documentation** (a local `Raku/doc` checkout) is the authority on
what the language contains.

* `doc/Language/operators.rakudoc` carries the precedence ladder as a table — 26
  levels, tightest to loosest, each with its associativity — *and* is organised
  by that ladder: every operator is documented under a `=head1 <Level>
  precedence` section. So an operator's precedence comes from the document's own
  structure rather than from anyone's inference.
* `doc/Type/*.rakudoc` gives each type its `=TITLE`/`=SUBTITLE`, its declaration
  line (`class Int is Cool does Real { }` — the hierarchy), and for every routine
  a `=head2` heading, an indented block of signatures including `-->` return
  types, and a prose statement of what it does.
* Both carry examples annotated with the output they are *expected* to produce:
  `say 1 + 1; # OUTPUT: «2␤»`.

**Raku++ itself**, probed. Each construct is fed to the interpreter in a minimal
use and classified by whether it *parses*. A type error still proves the spelling
is known; only a parse error does not. That is what the "Raku++ parses this" chip
and the `gap` badge mean — measured, never asserted.

**Rakudo**, as an oracle. Not read — *run*. Every example is executed by it, and
its answer is treated as what the language actually does.

### What is not read: Rakudo's grammar

An earlier version of `tools/inventory.raku` parsed
`rakudo/src/Perl6/Grammar.nqp`. It was seductive — the grammar has exact
precedence letters (`y=` … `b=`) and internal flags (`iffy`, `thunky`, `fiddly`)
that no documentation mentions, and it declares constructs the docs never
describe.

That is precisely the problem. Those are facts about one implementation's
parser, not about Raku, and publishing them would quietly turn this into a
description of Rakudo's internals — a wrong path to be led down while believing
you are documenting a language.

The cost is visible and accepted: the operator inventory went from 292
constructs to 181 when the grammar was dropped. The remaining 181 are the ones
the language documents.

---

## Verification

A rule ships only when its declared output is what **both** engines produce.

```sh
rakupp rules.raku --verify                  # every example on rakupp
rakupp rules.raku --verify --oracle=raku    # …and on Rakudo, which must agree
```

`build.raku` adds a third gate — running every example through the node-target
build of `raku.js` under Bun — so a browser-only divergence also fails the build.
`./verify.sh` runs all of them and aborts on any drift.

Where the two engines genuinely differ, the page says so in a static block
showing both, rather than claiming either is the language.

---

## The generated artefacts

Run in this order; each writes a committed data file under `src/data/`, so a
site build needs neither a Rakudo checkout nor the doc sources.

| Tool | Reads | Writes | Purpose |
|---|---|---|---|
| `tools/inventory.raku` | doc `operators.rakudoc`, rakupp probe | `inventory.raku` | every documented operator, its precedence level, whether Raku++ parses it |
| `tools/matrix.raku` | inventory, both engines | `matrix.raku` | the behaviour matrix — each operator against a battery of operand types |
| `tools/divergences.raku` | matrix | `DIVERGENCES.md` | operator disagreements, grouped by root cause |
| `tools/typedoc.raku` | doc `Type/*.rakudoc`, `type-graph.txt` | `typedoc.raku` | 355 types, 2009 routines, their signatures and examples |
| `tools/typerun.raku` | typedoc, both engines | `typerun.raku` | every documented example, run three ways |
| `tools/conformance.raku` | typerun | `CONFORMANCE.md` | the Raku++ work list |
| `tools/snapshot.raku` | typerun, matrix, inventory | `history.jsonl` | appends one record per run, so the trend survives regeneration |

```sh
rakupp tools/inventory.raku --doc=/path/to/doc --rakupp=/path/to/rakupp
rakupp tools/matrix.raku    --rakupp=/path/to/rakupp --oracle=raku
rakupp tools/typedoc.raku   --doc=/path/to/doc
rakupp tools/typerun.raku   --rakupp=/path/to/rakupp --oracle=raku
rakupp tools/snapshot.raku  --rakupp=/path/to/rakupp --oracle=raku
```

Note that the run is not perfectly deterministic: two consecutive runs over
identical data have differed by roughly 1-2% of examples, because some
documentation examples print members of unordered collections or report timings.
A movement of a handful of examples between snapshots is noise; only tens of
examples are signal.

Run `snapshot.raku` last, after any regeneration. It appends one self-contained
JSON object to `src/data/history.jsonl` — aggregate verdict counts, matrix
totals, operator counts, both engine versions, and per-type counts — and never
rewrites an earlier line. `/rules/divergences/` draws a static chart from it;
the file is plain JSON Lines, so an interactive timeline can read it directly
later without the data having to be reconstructed.

`typerun` executes arbitrary documentation examples, so it runs them in a
sandbox directory — some of them write files — under a fork-and-alarm guard,
because a few block on input.

### The three-way comparison, and why it matters

Each documentation example carries the output the docs *assert*. Running it
gives two more answers, and the information is in how the three relate:

| Verdict | Meaning |
|---|---|
| `ok` | documentation, Rakudo and Raku++ all agree |
| `rakupp-differs` | doc and Rakudo agree — **Raku++ is wrong** |
| `doc-drift` | both engines agree — **the documentation is stale** |
| `rakudo-differs` | doc and Raku++ agree, Rakudo does not — usually a stale doc that **Raku++ was implemented from**, inheriting its error |
| `all-differ` | three answers; needs a human |
| `not-runnable` | neither engine runs it standalone |

The last two classes are why this is not a two-way comparison — and
`rakudo-differs` is the one where **no source can be trusted by default**. It can
mean a stale doc that Raku++ was implemented from, or a Rakudo bug the
documentation predates, and the two look identical from the outside.

The `asinh` case shows why that matters. The documentation and Raku++ both give
`1.asinh` as `0.881373587019543`; Rakudo gives `0.8813735870195429`. Working it
out: asinh(1) is ln(1+√2) = 0.88137358701954302523…, whose correctly-rounded
double has `0.881373587019543` as its shortest round-tripping representation. So
**Raku++ is right and Rakudo is one ulp low** — resolving this by "follow Rakudo"
would have made Raku++ less accurate.

Such cases are therefore examined one at a time and the finding recorded in
`src/rules/adjudications.raku`, keyed by type and the example's first line. The
site prints the ruling and its reasoning on the example itself; anything not yet
examined is shown as such rather than silently resolved.

### The trajectory so far

The comparison exists to be acted on, so the interesting figure is how `ok`
moves. Both columns are the same corpus measured by the same tools; the current
numbers are always in [CONFORMANCE.md](CONFORMANCE.md).

| Verdict | 2026-07-25 (first run) | 2026-07-26 (Raku++ v1.2.0) |
|---|---:|---:|
| `ok` — all three agree | 596 | **835** |
| `rakupp-differs` — Raku++ is wrong | 471 | **237** |
| `all-differ` — needs a human | 176 | 164 |
| `doc-drift` — the docs are stale | 104 | 112 |
| `not-runnable` | 88 | 88 |
| `rakudo-differs` — Rakudo is the odd one out | 16 | 15 |

Two cautions when reading a delta. `rakupp-differs` is not a clean progress
metric on its own: fixing Raku++ reshuffles rows between `all-differ`,
`doc-drift` and `rakupp-differs` as the three answers realign — track `ok`. And
the count carries a few points of run-to-run jitter, because Rakudo randomises
hash iteration order per process, so every example whose output gists a Hash or
a QuantHash flips between `ok` and `rakudo-differs` between runs. A move of ±5
with a flat Roast gate is noise.

---

## Layout

```
build.raku            the Spec generator            -> out/
rules.raku            the Rules generator           -> out/rules/
verify.sh             build both + all three checks (pre-push gate)
tools/                the extractors above
src/
  site.raku           Spec config
  theme/              base.css, rules.css, spec.js, rules.js, search.js
  pages/<cat>/*.md    Spec pages
  rules/
    site.raku         Rules config: topics, and the precedence ladder
    adjudications.raku  hand-written rulings on disagreements
    pages/<topic>/*.md  hand-written rule pages
  data/*.raku         generated, committed — the site build reads only these
out/                  generated site (git-ignored)
```

## Authoring

### A Spec page

```
---
title: Integer literals
status: full            # full | partial | divergent | ni
order: 10
summary: One-line teaser shown in nav cards and the page header.
---
```

### A Rules page

Naming the construct pulls in its precedence, associativity and section
automatically — an author never restates a machine fact.

```
---
title: Concatenation
sym: "~"
cat: infix
status: written
summary: One line shown in the nav and under the title.
---
```

Then `## Rules`, `## Traps` and `## Errors`; each `###` inside them becomes a
numbered, anchored, citable rule — `R1`, `T2`, `E1`.

Any construct with no hand-written page still gets one, pre-filled with what was
extracted and badged **Skeleton**, and `/rules/coverage/` counts written against
total — so a missing rule is visible rather than absent.

### Fences

` ```raku ` is a runnable editor; follow it with ` ```output ` to declare the
expected output, which `--verify` then enforces. Options: `run` (auto-run),
`stdin="…"`, `rows="8"`. Also `syntax` and `text` for static blocks, and `bad`
for code that is meant to fail — shown, never run, never verified.

## Build & preview

```sh
rakupp build.raku                  # the Spec  -> out/
rakupp rules.raku                  # the Rules -> out/rules/
rakupp path/to/rakus.raku 8080 out # preview at http://127.0.0.1:8080/
```

## Publishing

`spec.raku.online` is **GitHub Pages** with a custom domain. Push to `main` and
`.github/workflows/pages.yml` rebuilds: it installs the latest released `rakupp`,
runs `build.raku --clean`, then `rules.raku`. The Rules step is
`continue-on-error`, so a released interpreter that cannot build the generator
degrades to the Spec alone rather than staling the whole site.

There is no other deploy path. An earlier `deploy.sh` mirrored `out/` to a server
doc root over sshfs; that tree serves nothing and the script is gone.

**The workflow does not verify anything** — it only builds. So verification is a
local pre-push gate:

```sh
./verify.sh          # build both sites, run all three checks, publish nothing
```

It reads `RAKUPP`, `ORACLE` and `WASM` from a git-ignored `.verify.env` (or the
older `.deploy.env`) and fails on any example drift. Run it before pushing.

The engine is **not** copied here — pages load `https://raku.online/raku.js`,
reusing the interpreter and cache of the
[raku.online](https://github.com/ash/raku.online) playground.
