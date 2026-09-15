---
name: String::Utils
version: 0.0.40
auth: zef:lizmat
kind: Distribution · text
summary: About forty small string routines that the core does not have —
  substring-before and -after, accent stripping, n-grams, abbreviations,
  whitespace introspection — each one a sub rather than a method.
status: full
suite: 3 files, green
tested: 2026-09-16
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/String::Utils
source: https://github.com/lizmat/String-Utils.git
---

## What it is for

Every one of these is a line or three of Raku you have written before. The value
is not that they are hard; it is that they are *named*, so a program says
`before($path, '/')` instead of `$path.substr(0, $path.index('/'))` and stops
being wrong when the separator is absent.

The distribution exports about forty of them. This page covers the families
rather than the list.

## Cutting a string at a marker

```raku name="strutils"
use String::Utils;

my $path = 'lib/String/Utils.rakumod';
say 'before   : ', before($path, '/').raku;
say 'after    : ', after($path, '/').raku;
say 'between  : ', between($path, 'lib/', '.rakumod').raku;
say '';
say 'stem           : ', stem('archive.tar.gz').raku;
say 'stem, 1 part   : ', stem('archive.tar.gz', 1).raku;
say 'shorten        : ', shorten('a rather long sentence', 10).raku;
say 'nomark         : ', nomark('çédille naïve').raku;
say 'is-sha1        : ', is-sha1('0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33');
say '';
say 'ngram("raku", 2) : ', ngram('raku', 2).join(' ');
say 'word-at          : ', word-at('the quick brown', 4).raku;
say 'abbrev("length") : ', abbrev('length').sort(*.key).map({ .key }).join(' ');
```

```output
before   : "lib"
after    : "String/Utils.rakumod"
between  : "String/Utils"

stem           : "archive"
stem, 1 part   : "archive.tar"
shorten        : "a ra…tence"
nomark         : "cedille naive"
is-sha1        : False

ngram("raku", 2) : ra ak ku
word-at          : (4, 5, 1)
abbrev("length") : l le len leng lengt length
```

`before`, `after` and `between` return `Nil` when the marker is not there,
which is the behaviour that makes them worth using: the `.substr`/`.index`
version returns nonsense or throws, and the difference only shows up on the
input you did not test.

`stem` strips extensions and takes a count — one call for `archive` and one for
`archive.tar`, which is the distinction `.extension` cannot make. `shorten`
elides in the **middle** with `…`, keeping both ends, because the ends are
where the information is in a path or an identifier.

`nomark` strips diacritics without a normalisation table lookup on your side,
which is what you want before a case-insensitive compare or a slug.

## Sequences and prefixes

`ngram` slices a string into overlapping runs — the input to a similarity
measure or a cheap index. `word-at` answers where the word under a character
offset starts and how long it is, which is the primitive an editor needs and
nothing in core provides.

`abbrev` returns every unambiguous prefix of a word, as a **Hash** mapping
prefix to full word. The hash is the reason the example sorts before printing:
the return value has no order, so a program that joins it directly prints
something different on every run, and on two engines at once.

## Where the two engines differ

Nowhere. Every routine above produced identical output on Raku++ and Rakudo,
and all three test files pass on both.

The one thing to watch is the `abbrev` ordering above, and it is not an engine
difference — it is a `Hash` being asked to behave like a list. Sort it, or index
it, but do not iterate it and expect a sequence. That is also the reason this
page's example is stable under the site's two-runs-per-engine check, and an
earlier draft of it was not.
