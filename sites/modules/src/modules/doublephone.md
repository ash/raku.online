---
name: Doublephone
version: 0.1.3
auth: zef:jonathanstowe
kind: Distribution · text comparison
summary: Double Metaphone over a bundled C implementation — one call turns a
  word into two four-letter phonetic keys.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none at runtime
raku-land: https://raku.land/zef:jonathanstowe/Doublephone
source: git://github.com/jonathanstowe/Doublephone.git
---

## What it is for

Soundex was designed for English surnames in 1918 and shows it. Double
Metaphone is the modern replacement: it handles Germanic, Slavic, Romance and
Chinese name patterns, and it returns **two** keys per word — a primary and an
alternative — because a name like `Schmidt` has more than one plausible
pronunciation depending on where the bearer's family came from.

Two names match if any of their keys match.

## Coding a name

```raku name="phone"
use Doublephone;

for <Smith Smyth Schmidt Wright Rait Knight Nite
     Jackson Jaxon Gonzalez Gonsalez Pfeiffer Xavier Czerny> -> $w {
    my ($p, $s) = double-metaphone($w);
    say sprintf('%-10s primary=%-6s secondary=%-6s same=%s', $w, $p, $s, $p eq $s);
}
```

```output
Smith      primary=SM0    secondary=XMT    same=False
Smyth      primary=SM0    secondary=XMT    same=False
Schmidt    primary=XMT    secondary=SMT    same=False
Wright     primary=RT     secondary=RT     same=True
Rait       primary=RT     secondary=RT     same=True
Knight     primary=NT     secondary=NT     same=True
Nite       primary=NT     secondary=NT     same=True
Jackson    primary=JKSN   secondary=AKSN   same=False
Jaxon      primary=JKSN   secondary=AKSN   same=False
Gonzalez   primary=KNSL   secondary=KNSL   same=True
Gonsalez   primary=KNSL   secondary=KNSL   same=True
Pfeiffer   primary=PFFR   secondary=PFFR   same=True
Xavier     primary=SF     secondary=SFR    same=False
Czerny     primary=SRN    secondary=XRN    same=False
```

`Smith` and `Smyth` share both keys. `Jackson` and `Jaxon` share both.
`Gonzalez` and `Gonsalez` agree. And `Schmidt` gets `XMT` primary with `SMT`
alternative, which is exactly the two-pronunciation case the algorithm exists
for — `Smith`'s alternative is `XMT` too, so the two names match on the
crossed pair.

## Matching

```raku name="match"
use Doublephone;

sub sounds-alike($a, $b) {
    my @a = double-metaphone($a);
    my @b = double-metaphone($b);
    so @a.grep(*.chars) (&) @b.grep(*.chars);
}

for <Smith Schmidt>, <Wright Rait>, <Knight Nite>,
    <Smith Jones>, <Thompson Tomson> -> ($a, $b) {
    say sprintf('%-10s %-10s -> %s', $a, $b, sounds-alike($a, $b) ?? 'match' !! 'no');
}
```

```output
Smith      Schmidt    -> match
Wright     Rait       -> match
Knight     Nite       -> match
Smith      Jones      -> no
Thompson   Tomson     -> no
```

`Thompson` and `Tomson` do **not** match, which is the algorithm working
correctly: the `p` is audible.

## What the input can be

```raku name="input"
use Doublephone;

sub show($label, $in) {
    my ($p, $s) = double-metaphone($in);
    say sprintf('%-22s -> (%s, %s)', $label, $p.raku, $s.raku);
}

show 'empty string',    '';
show 'digits only',     '12345';
show 'lowercase',       'smith';
show 'mixed case',      'SmItH';
show 'hyphenated',      'Smith-Jones';
show 'leading spaces',  '  Smith';
show 'accented',        "Ren\c[LATIN SMALL LETTER E WITH ACUTE]e";
show 'Cyrillic',        "\c[CYRILLIC CAPITAL LETTER I]\c[CYRILLIC SMALL LETTER VE]";
```

```output
empty string           -> ("", "")
digits only            -> ("", "")
lowercase              -> ("SM0", "XMT")
mixed case             -> ("SM0", "XMT")
hyphenated             -> ("SM0J", "XMTJ")
leading spaces         -> ("SM0", "SMT")
accented               -> ("RN", "RN")
Cyrillic               -> ("", "")
```

Case is folded. Non-Latin input yields two empty strings rather than an error,
which is worth guarding: an empty key matches every other empty key, so a
corpus with mixed scripts will bucket all of its non-Latin names together.

Note the leading-whitespace row: `'Smith'` and `'  Smith'` give **different**
secondary keys. Trim before calling.

## The one thing to know

An undefined `Str` segfaults the process, and `try` cannot save you.

The signature is `Str $str`, which accepts a type object; the C function then
dereferences a null pointer. Exit status 139 is SIGSEGV — not an exception,
not a backtrace, just a program that is gone.

The realistic path to it is ordinary: a database column that is NULL, a regex
capture that did not match, a hash key that was absent. Guard with `// ''` or
declare `Str:D` at your own call site.

## Where the two engines differ

Nowhere, including the segfault — Raku++ and Rakudo both die the same way on
an undefined argument, and every key in this page is byte-identical on the
two.

One difference in noise rather than behaviour: on a cold precompilation cache
Rakudo prints a deprecation report at exit about `Distribution::Resource.Str`,
and it does not reappear once the unit is precompiled. Raku++ never prints it.

The thing to size before you rely on the keys: **every code is capped at four
characters**, so `Constantinople`, `Constantine`, `Constant` and `Konstanz` all
collide on `KNST`. That is fine for a phonetic bucket and wrong if you treat
the key as an identifier.
