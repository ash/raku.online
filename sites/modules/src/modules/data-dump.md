---
name: Data::Dump
version: 0.0.18
auth: zef:tony-o
kind: Distribution · debugging
summary: One sub, Dump, that renders any structure — nested data, objects,
  attributes and all — as indented, optionally colored text a human can
  actually read.
status: full
license: Artistic-2.0
suite: 9 files, green
tested: 2026-08-28
raku-land: https://raku.land/zef:tony-o/Data::Dump
source: https://github.com/tony-o/perl6-data-dump
---

## What it is for

`say` gives you a gist, `.raku` gives you something round-trippable, and
neither is what you want at 2 a.m. with a nested structure that is not
the shape you thought it was. `Dump` is the third answer: everything laid
out vertically, one element per line, indentation carrying the nesting,
each value labelled with its type:

```raku name="dump-a-structure"
use Data::Dump;

class Server { has $.host; has $.port; has @.tags }
my $s = Server.new(:host<db1>, :port(5432), :tags<primary ssd>);
say Dump($s, :!color, :skip-methods);
say Dump([1, 'two', 3.5], :!color);
```

```output
Server :: (
  $!host => "db1".Str,
  $!port => 5432.Int,
  @!tags => [
    "primary".Str,
    "ssd".Str,
  ],

)
[
  1.Int,
  "two".Str,
  3.5.Rat,
]
```

Objects come apart into their attributes — real sigils, declaration
order — and every leaf carries its type as a postfix, so `"5432"` and
`5432` can never masquerade as each other in a dump. That type labelling
is the feature you will miss in a plain `say`.

## The adverbs that matter

Two of the adverbs above are close to mandatory knowledge. `:!color`
turns off the ANSI colors that `Dump` emits whenever `Terminal::ANSIColor`
is installed — with it, dumps are painted for terminals and wrong for log
files; the examples here disable it so the page shows bytes you can
compare. `:skip-methods` keeps `Dump` from listing every method of the
object's classes alongside the data — without it, a dump of one
three-attribute object runs to dozens of lines of method signatures,
which is occasionally what you want and usually is not.

The rest: `:indent(4)` widens the steps, `:max-recursion(50)` is the
guard that keeps a self-referencing structure from dumping forever
(`Dump` cuts off and says so rather than hanging), and `:gist` swaps the
attribute view for each object's own `.gist`, for classes that already
know how to present themselves.

One honest caution that belongs to hashes rather than to this module: a
multi-key `Hash` dumps its pairs in hash order, which Raku does not
promise between runs. Comparing dumps of hashes across runs — or between
engines — is a coin flip by design; dump arrays and objects when the
output has to be stable, as the examples on this page do.

## Where the two engines differ

Nothing on this page. Attribute discovery through the metaobject
protocol, the sigil rendering, the type postfixes and the recursion
handling answer identically under Raku++ and Rakudo — `Dump` leans hard
on introspection (`.^attributes`, `.^methods`, `.^mro`), so this page is
quietly a MOP conformance statement too.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install Data::Dump`; it depends on nothing —
   `Terminal::ANSIColor` is picked up *optionally* at run time, via
   `try require`, when it happens to be installed.
3. **Test** — the distribution's own suite: 9 files, green.
4. **Run** — every example on this page, twice under each engine, as the
   site is built.

That optional-dependency trick — `(try require ::('Terminal::ANSIColor'))`
falling back to a no-op colorizer — is worth stealing for your own
modules, and its working here means dynamic `require` of a
maybe-installed module behaves on both engines. Fourteen distributions
depend on this one; an earlier engine campaign ("Six general faults
behind Data::Dump") got its suite from red to 9/9 green, so this page is
the receipt.
