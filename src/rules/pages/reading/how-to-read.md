---
title: How to read these rules
slug: how-to-read
section: overview
order: 10
status: written
summary: What a rule is, where each one comes from, and what the badges on a page mean.
---

This site tries to answer a narrower question than a tutorial and a wider one than a
reference card: **given this construct, exactly what happens?** Not the common case —
all of it, including the parts that only bite you once.

## Rules

### A rule is a numbered, citable claim about behaviour

Every `R`-numbered heading is one claim, and it is anchored. `R2` on this page is
`how-to-read.R2`, and its link is stable, so a rule can be cited from a bug report, a
commit message, or another page.

Rules are stated in the order you meet them: what the construct does, then what it
does in the cases you did not think about.

### Every rule that can carry an example carries a runnable one

The editors below are live. Edit the code, press Run, and the same WebAssembly build
of Raku++ that powers [raku.online](https://raku.online/) executes it in your browser.

```raku
say 6 + 3;
say "6" + "3";
```
```output
9
9
```

### Declared output is verified at build time, twice

The `Output` panel under an example is not typed by hand and hoped for. The generator
runs every example through the real `rakupp` binary and fails the build if the output
differs. With `--oracle=raku` it also runs the example through **Rakudo** and fails if
the declared output is not what Rakudo produces.

That gives the two properties this site needs: an example cannot drift from the
interpreter, and it cannot quietly document a bug as if it were the language.

### Where a rule comes from

Three sources, each answering a different question.

| Source | Answers |
|---|---|
| The official documentation | What constructs exist, and where each sits in the precedence ladder |
| Both engines, actually run | What each one really does with the same expression |
| The Raku++ sources | Why the implementation behaves as it does, and where its edges are |

Nothing is copied from any of them. The documentation says what to test; running
the engines says what happens; the implementation says what is worth warning about.

Rakudo's *grammar* is deliberately not read. It carries precedence letters and
internal flags no documentation mentions, and declares constructs the docs never
describe — but those are facts about one implementation's parser rather than about
Raku, and documenting them here would quietly turn this site into a description of
Rakudo's internals.

## Traps

### A trap is behaviour that is correct and still surprising

`T`-numbered items are not bugs. They are places where a reasonable expectation is
wrong — usually precedence, context, or a container doing something to a value on the
way past.

```raku
say "-" x 3 + 2;
```
```output
-----
```

`x` binds tighter than `+`? No — the other way round. `+` sits at the *additive*
level and `x` at *replication*, which is one step looser, so this is
`"-" x (3 + 2)`. The precedence chip at the top of every operator page carries the
level and its position on the ladder, precisely so this is checkable rather than
memorable.

## Badges

### Status says how finished a page is

| Badge | Meaning |
|---|---|
| **Written** | Rules written and verified. |
| **Partial** | Some rules written; the construct has more behaviour than is documented. |
| **Skeleton** | Only machine-extracted facts so far — precedence, associativity, and what is known about Raku++ support. No rules yet. |
| **Gap** | Raku++ does not parse this spelling at all. The page records that, rather than pretending. |

Skeleton pages exist on purpose. The menu is built from every construct the official
documentation describes, so a construct nobody has written up yet still gets a page
and still shows up in the count on the [coverage page](/rules/coverage/). A missing
rule is visible; it cannot hide behind a table of contents that simply omits it.

### The fact panel is machine-generated

The chips under the title — category, precedence level and ladder position,
associativity, and what is known about Raku++ support — are extracted, not typed.
The level names are the documentation's own, and the position (`8/28`) counts
from the tightest. Two operators bind equally exactly when they share a level.

The support chip is graded by how strong the evidence actually is, because
"it parses" and "it works" are very different claims:

| Chip | What was established |
|---|---|
| **runs this — matches Rakudo on all N** | Executed with N different operand types; every result matched Rakudo. |
| **runs this — X of N results differ** | It executed, but some results disagree with Rakudo. The table further down shows which. |
| **parses this — execution unchecked** | A minimal use got past the parser. That is *all* it means: nothing here says the construct executes, let alone correctly. |
| **does not parse this** | A minimal use is a parse error. |

The third case is the one to read carefully. A construct can parse and still fail
at run time, or run and return the wrong type — so treat "parses" as the absence
of evidence rather than as evidence of health.

## Traps for the reader

### This documents one implementation, deliberately

Where Raku++ and Rakudo agree, a rule is a statement about Raku. Where they differ,
the page says so explicitly and shows both. It never silently documents Raku++'s
answer as the language's answer — that is what the oracle check is for.
