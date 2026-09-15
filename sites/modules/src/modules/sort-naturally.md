---
name: Sort::Naturally
version: 0.2.3
auth: zef:thundergnat
kind: Distribution · sorting
summary: Key transforms that put `file2` before `file10` — ranking digit runs
  by length first, which puts `0100` after `999`.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:thundergnat/Sort::Naturally
source: git://github.com/thundergnat/Sort-Naturally.git
---

## What it is for

`sort` on filenames gives you `file1, file10, file2`, which is right for
strings and wrong for humans. Natural sorting reads the embedded digits as
numbers so `file2` comes first.

This distribution supplies two **key transforms** — not comparators. Each
takes one string and returns a different string, engineered so that ordinary
`cmp` on the transformed keys does the right thing.

## Sorting naturally

```raku name="basics"
use Sort::Naturally;

my @files = <file10.txt file2.txt file1.txt File3.TXT>;
say 'plain .sort : ', @files.sort.join(' ');
say 'naturally   : ', @files.sort({ .&naturally }).join(' ');
say '';
say 'two things changed: numeric order for the digits, and case folding —';
say 'plain .sort puts File3.TXT first because F is 70 and f is 102.';
say '';
my @versions = <v1.2.10 v1.2.9 v1.10.0 v1.9.0>;
say 'versions, plain : ', @versions.sort.join(' ');
say 'versions, nat   : ', @versions.sort({ .&naturally }).join(' ');
```

```output
plain .sort : File3.TXT file1.txt file10.txt file2.txt
naturally   : file1.txt file2.txt File3.TXT file10.txt

two things changed: numeric order for the digits, and case folding —
plain .sort puts File3.TXT first because F is 70 and f is 102.

versions, plain : v1.10.0 v1.2.10 v1.2.9 v1.9.0
versions, nat   : v1.2.9 v1.2.10 v1.9.0 v1.10.0
```

They are key transforms, so you use them with `.sort({ .&naturally })`, not as
a comparator. What they return is a string built for `cmp` and nothing else:

```raku name="keys"
use Sort::Naturally;

for '7', '007', 'a10' -> $s {
    say sprintf('  naturally(%-6s) = %s', $s.raku, naturally($s).raku);
}
say '';
say 'those keys contain NUL and low control characters by construction.';
say 'Never persist, log or round-trip them through anything line-based —';
say 'they are for sort and nothing else.';
```

```output
  naturally("7"   ) = "0\x[1]7\07"
  naturally("007" ) = "0\x[3]007\0007"
  naturally("a10" ) = "a0\x[2]10\0a10"

those keys contain NUL and low control characters by construction.
Never persist, log or round-trip them through anything line-based —
they are for sort and nothing else.
```

## The one thing to know

This is not numeric sorting. Digit runs are ranked by their **character
count** first, so zero-padded numbers come out in the wrong order, with no
warning.

```raku name="padding"
use Sort::Naturally;

my @nums = <007 7 08 8 0100 999>;
say 'plain .sort : ', @nums.sort.join(' ');
say 'naturally   : ', @nums.sort({ .&naturally }).join(' ');
say '';
say 'the key encodes a run as "0" ~ chr(length) ~ digits, and chr(4) is';
say 'greater than chr(3) — so a 4-character run always outranks a';
say '3-character one. 0100 is one hundred and it sorts AFTER 999.';
say '';
say 'zero-padded IDs, %03d filenames and embedded ISO dates are exactly';
say 'the data people reach for a natural sort with.';
say '';
say 'decimals are read as integers too:';
say '  ', <1.5 1.10 1.9 1.25>.sort({ .&naturally }).join(' ');
say 'and the minus sign is not part of the number:';
say '  ', <-5 -10 3 -3>.sort({ .&naturally }).join(' ');
```

```output
plain .sort : 007 7 08 8 0100 999
naturally   : 7 8 08 007 999 0100

the key encodes a run as "0" ~ chr(length) ~ digits, and chr(4) is
greater than chr(3) — so a 4-character run always outranks a
3-character one. 0100 is one hundred and it sorts AFTER 999.

zero-padded IDs, %03d filenames and embedded ISO dates are exactly
the data people reach for a natural sort with.

decimals are read as integers too:
  1.5 1.9 1.10 1.25
and the minus sign is not part of the number:
  -3 -5 -10 3
```

## The two transforms are not interchangeable

```raku name="p5"
use Sort::Naturally;

my @mixed = <ab a10 az a1 aa a9z b2 b>;
say 'plain .sort  : ', @mixed.sort.join(' ');
say 'naturally    : ', @mixed.sort({ .&naturally }).join(' ');
say 'p5naturally  : ', @mixed.sort({ .&p5naturally }).join(' ');
say '';
say 'naturally puts digits BEFORE letters; p5naturally puts them after,';
say 'because its key prefix for a non-leading run is "z{". Swapping one';
say 'for the other silently reorders your output.';
say '';
say 'both are total orders, with case as a tiebreak:';
say '  ', <b A a B aA Aa>.sort({ .&naturally }).join(' ');
```

```output
plain .sort  : a1 a10 a9z aa ab az b b2
naturally    : a1 a9z a10 aa ab az b b2
p5naturally  : aa ab az a1 a9z a10 b b2

naturally puts digits BEFORE letters; p5naturally puts them after,
because its key prefix for a non-leading run is "z{". Swapping one
for the other silently reorders your output.

both are total orders, with case as a tiebreak:
  A a Aa aA B b
```

## Where the two engines differ

Nothing in the transforms — the keys are byte-identical and so is every sort
built on them. What differs is the *baseline* you might compare against, and
that is worth knowing before you conclude the module is not doing anything.

```raku name="allomorph"
use Sort::Naturally;

my @words = <100 14th 2>;
say 'element types : ', @words.map({ .WHAT.^name }).join(', ');
say '';
say 'the numeric ones are IntStr allomorphs, and cmp between two of them';
say 'is NUMERIC while cmp between an allomorph and a Str is TEXTUAL.';
say 'That makes cmp non-transitive here:';
say '  100 cmp 14th = ', ('100' cmp '14th' given @words) // '';
for @words.combinations(2) -> ($a, $b) {
    say sprintf('  %-5s cmp %-5s = %s', $a, $b, $a cmp $b);
}
say '';
say 'a non-transitive comparator lets sort return any permutation, and the';
say 'two engines do return different ones for the same input. naturally';
say 'fixes it by making the key a plain Str, which is why its output is';
say 'identical everywhere:';
say '  ', @words.sort({ .&naturally }).join(' ');
```

```output
element types : IntStr, Str, IntStr

the numeric ones are IntStr allomorphs, and cmp between two of them
is NUMERIC while cmp between an allomorph and a Str is TEXTUAL.
That makes cmp non-transitive here:
  100 cmp 14th = Less
  100   cmp 14th  = Less
  100   cmp 2     = More
  14th  cmp 2     = Less

a non-transitive comparator lets sort return any permutation, and the
two engines do return different ones for the same input. naturally
fixes it by making the key a plain Str, which is why its output is
identical everywhere:
  2 14th 100
```

One edge, identical on both: `naturally(Any)` returns `"\0"` under Raku++ and
raises `X::Method::NotFound` under Rakudo, so an undefined element in your
list sorts first on one engine and is fatal on the other. Filter first.
