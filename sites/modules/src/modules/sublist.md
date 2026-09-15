---
name: sublist
version: 1.2
auth: zef:yabobay
kind: Distribution · lists
summary: Find one list inside another — by stringifying both slices, so
  element boundaries vanish, and without exporting anything.
status: divergent
suite: no test files, so trivially green
tested: 2026-09-15
license: LGPL-3.0-only
depends: none beyond the core
raku-land: https://raku.land/zef:yabobay/sublist
source: https://gitea.com/yabobay/sublist
---

## What it is for

`index` finds a substring in a string. This distribution is the list
equivalent: at what offset does one list occur inside another, and at which
offsets does it occur more than once.

## Using it

```raku name="basics"
use sublist;

say 'index   : ', sublist::index(<a b>, <x a b>).raku;
say 'indices : ', sublist::indices(<a b>, <x a b c a b>).List.raku;
say '';
say 'not present     : ', sublist::index(<z z>, <x a b>).raku;
say 'at offset 0     : ', sublist::index(<x a>, <x a b>).raku;
say 'needle longer   : ', sublist::index(<a b c>, <a b>).raku;
say 'overlapping     : ', sublist::indices(<a a>, <a a a>).List.raku;
say '';
say 'note the qualified spelling. Both subs are `our` with NO `is export`,';
say 'so `use sublist` brings in nothing — see below.';
```

```output
index   : 1
indices : (1, 4)

not present     : Nil
at offset 0     : 0
needle longer   : Nil
overlapping     : (0, 1)

note the qualified spelling. Both subs are `our` with NO `is export`,
so `use sublist` brings in nothing — see below.
```

## The one thing to know

`use sublist;` exports nothing, so a bare `index(@needle, @hay)` silently
calls the **core** `index` and returns a plausible, wrong integer.

```raku name="shadow"
use sublist;

my @needle = 'b', 'c';
my @hay    = 'a', 'b', 'c', 'd';

say 'sublist::index(@needle, @hay) = ', sublist::index(@needle, @hay).raku,
    '   <- correct';
say 'bare index(@needle, @hay)     = ', index(@needle, @hay).raku,
    '   <- the CORE index, on the stringified lists';
say '';
say 'core index stringifies both arguments and finds "b c" at offset 0 of';
say '"a b c d"… which is a perfectly ordinary answer from this API, so';
say 'nothing downstream looks wrong.';
say '';
say 'Rakudo at least warns ("Calling .index on a Array, did you mean';
say '.first( …, :k )?"). Raku++ gives no diagnostic at all.';
say '';
say 'always write sublist::index and sublist::indices.';
```

```output
sublist::index(@needle, @hay) = 1   <- correct
bare index(@needle, @hay)     = 0   <- the CORE index, on the stringified lists

core index stringifies both arguments and finds "b c" at offset 0 of
"a b c d"… which is a perfectly ordinary answer from this API, so
nothing downstream looks wrong.

Rakudo at least warns ("Calling .index on a Array, did you mean
.first( …, :k )?"). Raku++ gives no diagnostic at all.

always write sublist::index and sublist::indices.
```

There is a second trap on top of the first: `index` at position 0 is falsy, so
`if sublist::index(@a, @b) { … }` misses a match at the start. Test with
`.defined`.

## The comparison is textual

```raku name="stringify"
use sublist;

my @needle = 'a', 'b c', 'd';
my @hay    = 'a', 'b', 'c d';

say 'needle : ', @needle.raku;
say 'hay    : ', @hay.raku;
say 'index  : ', sublist::index(@needle, @hay).raku, '   <- a false positive';
say '';
say 'element-wise, they do not match:';
say '  ', (@needle Zeq @hay[0..2]).raku;
say '';
say 'the comparison is `@a eq @b[$_ ..^ $_+@a]` — both slices are';
say 'stringified and joined with spaces, so element boundaries vanish.';
say '';
say 'the same mechanism makes it type-blind:';
say '  sublist::index((1, 2), ("0", "1", "2")) = ',
    sublist::index((1, 2), ('0', '1', '2')).raku;
say '';
say 'compare element-wise yourself if that matters:';
sub find(@needle, @hay) {
    (0 .. @hay.elems - @needle.elems).first({
        @needle eqv @hay[$_ ..^ $_ + @needle]
    })
}
say '  find(@needle, @hay) = ', find(@needle, @hay).raku;
```

```output
needle : ["a", "b c", "d"]
hay    : ["a", "b", "c d"]
index  : 0   <- a false positive

element-wise, they do not match:
  (Bool::True, Bool::False, Bool::False).Seq

the comparison is `@a eq @b[$_ ..^ $_+@a]` — both slices are
stringified and joined with spaces, so element boundaries vanish.

the same mechanism makes it type-blind:
  sublist::index((1, 2), ("0", "1", "2")) = 1

compare element-wise yourself if that matters:
  find(@needle, @hay) = Nil
```

## Where the two engines differ

A no-match `indices` returns `Nil` under Raku++ and `[]` under Rakudo, and the
container type differs (`List` vs `Array`). Both come from the module's last
line, `return @indices.list or Nil;` — dead code on Rakudo, where `return`
short-circuits, and live on Raku++, where `return EXPR or EXPR` is mis-parsed
as `return (EXPR or EXPR)`.

```raku name="portable"
use sublist;

# normalise the result and both engines agree
sub indices-of(@needle, @hay) { (sublist::indices(@needle, @hay) // ()).List }

for (<a b>, <x a b c a b>), (<z z>, <x a b>) -> (@n, @h) {
    say sprintf('  %-10s in %-16s -> %s',
                @n.raku, @h.raku, indices-of(@n, @h).raku);
}
say '';
say 'an EMPTY needle is the other divergence — do not pass one:';
say 'indexing past the end of a List bound to an @-parameter gives Any on';
say 'Raku++ and Nil on Rakudo, and the grep that follows then matches';
say 'EVERYTHING on one engine and nothing on the other. Guard against an';
say 'empty needle at the call site.';
```

```output
  ("a", "b") in ("x", "a", "b", "c", "a", "b") -> (1, 4)
  ("z", "z") in ("x", "a", "b")  -> ()

an EMPTY needle is the other divergence — do not pass one:
indexing past the end of a List bound to an @-parameter gives Any on
Raku++ and Nil on Rakudo, and the grep that follows then matches
EVERYTHING on one engine and nothing on the other. Guard against an
empty needle at the call site.
```
