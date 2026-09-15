---
name: ASCII::To::Uni
version: 0.1.1
auth: zef:raku-community-modules
kind: Distribution · source tools
summary: A source-rewriting filter that replaces about forty-five ASCII
  spellings with the Unicode characters Raku also accepts.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/ASCII::To::Uni
source: https://github.com/raku-community-modules/ASCII-To-Uni.git
---

## What it is for

Raku accepts `(elem)` and `∈`, `(|)` and `∪`, `...` and `…`, for the same
operators. The ASCII spellings are what you can type without a compose key;
the Unicode ones are what the code reads best as.

This distribution converts the first into the second, either in a string or in
a file on disk.

## Converting a string

```raku name="convert"
use ASCII::To::Uni;

my Str $src = 'my @a = 1,2,3; say @a (|) @b; say $x (elem) %h; my $s = set();';
my $returned = convert-string($src);

say 'the return value : ', $returned.raku;
say 'the variable     : ', $src;
say '';
my Str $two = 'if $a (<=) $b and $c (>=) $d { say "..." }';
convert-string($two);
say $two;
```

```output
the return value : Any
the variable     : my @a = 1,2,3; say @a ∪ @b; say $x ∈ %h; my $s = ∅;

if $a ⊆ $b and $c ⊇ $d { say "…" }
```

`convert-string` reads like a pure function and is not: it returns `Any` and
**mutates its argument**, which must therefore be a writable container.
`convert-string('a literal')` dies.

## Your own table

```raku name="table"
use ASCII::To::Uni;

my Str $t = 'alpha beta gamma';
convert-string($t, table => { 'alpha' => 'A', 'beta' => 'B' });
say $t;
```

```output
A B gamma
```

`:table` replaces the built-in one entirely rather than adding to it.

## The one thing to know

The table converts ` + ` to `⁺` — a superscript plus, which is not a Raku
operator — so running it over ordinary arithmetic produces source that no
longer compiles.

```raku name="plus-trap"
use ASCII::To::Uni;
use MONKEY-SEE-NO-EVAL;

my Str $prog = 'my $e = 40; my $n = $e + 2; $n';
say 'before : ', $prog;
say '  evaluates to : ', EVAL $prog;
say '';
convert-string($prog);
say 'after  : ', $prog;
my $r = try EVAL $prog;
say '  evaluates    : ', $! ?? 'no — it is a parse error now' !! 'yes';
```

```output
before : my $e = 40; my $n = $e + 2; $n
  evaluates to : 42

after  : my $e = 40; my $n = $e⁺2; $n
  evaluates    : no — it is a parse error now
```

This is not an exotic corner. `+` is the most common infix in the language,
and the module's advertised job is rewriting your source files in place.

Two related hazards in the same table. ` e `, ` o `, ` pi ` and ` tau ` are all
rewritten, so a **variable named `e` or `o`** is silently replaced with
Euler's number or the composition operator. And the substitution is a plain
substring pass with no lexing, so string literals and comments are rewritten
too.

## Where the two engines differ

On whether the output is reproducible at all.

The table is walked with `%table.keys`, and every negated set operator
contains its positive form as a substring — so whichever key comes first wins.
Raku++ iterates hashes in insertion order, so it is stable, and stably wrong:
`!(elem)` always becomes `!∈` rather than `∉`. Rakudo randomises hash order
per process, so **the same input file yields a different output on every
run** — eighteen distinct results in twenty runs of one six-operator string.

So on one engine the conversion is deterministic and incorrect, and on the
other it is non-deterministic. Neither is a basis for a source-rewriting tool
you run over a repository.

One more thing to know before running `convert-file`: a bare call writes a
**new file next to the original** with `.uni` inserted before the extension,
prints two lines to stdout, and leaves the original alone — while `:rewrite`
overwrites in place. And a filename with no dot in it produces the path
`uni./abs/path/to/name`, which then fails to open.
