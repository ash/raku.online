---
name: Math::BijectiveBase
version: 0.0.1
auth: zef:slavenskoj
kind: Distribution · numbers
summary: Bijective positional numerals — the system spreadsheet columns use,
  where there is no zero digit — with five alphabets, one of them radix 35.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:slavenskoj/Math::BijectiveBase
source: https://github.com/slavenskoj/raku-Math-BijectiveBase
---

## What it is for

Spreadsheet columns go `A, B, … Z, AA, AB`. That is not base 26 — there is no
zero digit, and every position runs 1..k. It is *bijective* base 26, and the
same idea gives you short identifiers with no leading-zero ambiguity.

## Converting

```raku name="basics"
use Math::BijectiveBase;

say 'spreadsheet columns:';
for 1, 26, 27, 52, 702, 703, 16384 -> $n {
    say sprintf('  %6d -> %s', $n, to-bijective26($n));
}
say '';
say '16384 is the last column of an Excel worksheet, and XFD is the';
say 'published answer.';
say '';
say 'round trip over 1..2000 : ',
    so (1..2000).all.map({ from-bijective26(to-bijective26($_)) == $_ });
say '';
say 'and the generic pair takes any alphabet you like:';
say '  to-bijectivebase(5, <a b>)   = ', to-bijectivebase(5, <a b>);
say '  to-bijectivebase(3, ["z"])   = ', to-bijectivebase(3, ['z']);
say '  big integers work            : ', to-bijective26(10**20);
```

```output
spreadsheet columns:
       1 -> A
      26 -> Z
      27 -> AA
      52 -> AZ
     702 -> ZZ
     703 -> AAA
   16384 -> XFD

16384 is the last column of an Excel worksheet, and XFD is the
published answer.

round trip over 1..2000 : True

and the generic pair takes any alphabet you like:
  to-bijectivebase(5, <a b>)   = ba
  to-bijectivebase(3, ["z"])   = zzz
  big integers work            : ANGWJIRSMASUFQV
```

## The one thing to know

`to-bijective36` is bijective base **35**, and has no `0`.

```raku name="base36"
use Math::BijectiveBase;

say 'the 36 alphabet is  flat("1".."9", "A".."Z")  — nine digits plus';
say 'twenty-six letters is THIRTY-FIVE symbols, and "0" is not one:';
say '';
for 9, 10, 35, 36, 37 -> $n {
    say sprintf('  %3d -> %s', $n, to-bijective36($n));
}
say '';
say 'the first n whose output is two characters is 36, so the radix is 35.';
say '';
say 'the pair round-trips perfectly with itself, so nothing ever';
say 'complains — but a string produced by to-bijective36 is not base-36';
say 'anything, and real base-36 text containing 0 is rejected:';
my $r = try from-bijective36('10');
say '  from-bijective36("10") -> ', $! ?? 'refused' !! $r;
say '';
say 'round trip 1..500 : ',
    so (1..500).all.map({ from-bijective36(to-bijective36($_)) == $_ });
```

```output
the 36 alphabet is  flat("1".."9", "A".."Z")  — nine digits plus
twenty-six letters is THIRTY-FIVE symbols, and "0" is not one:

    9 -> 9
   10 -> A
   35 -> Z
   36 -> 11
   37 -> 12

the first n whose output is two characters is 36, so the radix is 35.

the pair round-trips perfectly with itself, so nothing ever
complains — but a string produced by to-bijective36 is not base-36
anything, and real base-36 text containing 0 is rejected:
  from-bijective36("10") -> refused

round trip 1..500 : True
```

## Two more alphabet surprises

```raku name="alphabets"
use Math::BijectiveBase;

say 'base 62 is A..Z, a..z, 0..9 — NOT the usual base62 order:';
for 1, 27, 53, 62, 63 -> $n {
    say sprintf('  %3d -> %s', $n, to-bijective62($n));
}
say '';
say 'and a non-distinct alphabet silently breaks the round trip, because';
say 'the decoder resolves a symbol to its LAST index:';
say '  to-bijectivebase(5, <a b a>)              = ', to-bijectivebase(5, <a b a>);
say '  from-bijectivebase(that, <a b a>)         = ',
    from-bijectivebase(to-bijectivebase(5, <a b a>), <a b a>);
say '  from-bijectivebase("a", <a b a>)          = ',
    from-bijectivebase('a', <a b a>);
say '';
say 'decode also has a value encode cannot produce:';
say '  from-bijective26("") = ', from-bijective26('');
my $z = try to-bijective26(0);
say '  to-bijective26(0)    = ', $! ?? 'refused (where * > 0)' !! $z;
```

```output
base 62 is A..Z, a..z, 0..9 — NOT the usual base62 order:
    1 -> A
   27 -> a
   53 -> 0
   62 -> 9
   63 -> AA

and a non-distinct alphabet silently breaks the round trip, because
the decoder resolves a symbol to its LAST index:
  to-bijectivebase(5, <a b a>)              = ab
  from-bijectivebase(that, <a b a>)         = 11
  from-bijectivebase("a", <a b a>)          = 3

decode also has a value encode cannot produce:
  from-bijective26("") = 0
  to-bijective26(0)    = refused (where * > 0)
```

## Where the two engines differ

Nothing behavioural. Only the constraint-failure message: Raku++ stops at
`Constraint type check failed in binding to parameter '$n'` where Rakudo
appends `; expected anonymous constraint to be met but got Int (0)`. Catch the
exception; do not match the text.

```raku name="portable"
use Math::BijectiveBase;

# a spreadsheet-column helper that is total over the values it accepts
sub column(Int $n) {
    die "column numbers start at 1, got $n" unless $n > 0;
    to-bijective26($n)
}
for 1, 27, 703, 0 -> $n {
    my $c = try column($n);
    say sprintf('  column(%4d) -> %s', $n, $! ?? $!.message !! $c);
}
say '';
say 'the five alphabets are reachable as `our` arrays if you need to';
say 'inspect one: Math::BijectiveBase::@base26-alphabet and friends.';
say 'their declared sizes are 26, 35, 52, 62 and 10.';
```

```output
  column(   1) -> A
  column(  27) -> AA
  column( 703) -> AAA
  column(   0) -> column numbers start at 1, got 0

the five alphabets are reachable as `our` arrays if you need to
inspect one: Math::BijectiveBase::@base26-alphabet and friends.
their declared sizes are 26, 35, 52, 62 and 10.
```
