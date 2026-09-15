---
name: Math::SelfDescriptiveNumbers
version: 0.0.1
auth: github:holli-holzer
kind: Distribution · numbers
summary: The self-descriptive numbers of any base — from three special cases
  and a closed form, not from a search.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/github:holli-holzer/Math::SelfDescriptiveNumbers
source: https://github.com/holli-holzer/raku-Math-SelfDescriptiveNumbers.git
---

## What it is for

A self-descriptive number's *i*-th digit counts how many times the digit *i*
appears in it. In base 10 there is exactly one: `6210001000` — six zeros, two
ones, one two, one six. It is a classic puzzle, and the answers are known in
closed form for every base from seven upwards.

## Asking

```raku name="basics"
use Math::SelfDescriptiveNumbers;

for 1 .. 12 -> $b {
    my $r = self-descriptive-numbers-of($b);
    say sprintf('  base %2d : %s', $b, $r.elems ?? $r.raku !! '(none)');
}
say '';
say 'base 10 gives 6210001000, which is the published answer.';
```

```output
  base  1 : (none)
  base  2 : (none)
  base  3 : (none)
  base  4 : $("1210", "2020")
  base  5 : "21200"
  base  6 : (none)
  base  7 : "3211000"
  base  8 : "42101000"
  base  9 : "521001000"
  base 10 : "6210001000"
  base 11 : "72100001000"
  base 12 : "821000001000"

base 10 gives 6210001000, which is the published answer.
```

Each answer really is self-descriptive:

```raku name="check"
use Math::SelfDescriptiveNumbers;

sub describes(Str $s, Int $base) {
    my @d = $s.comb.map({ .parse-base($base) });
    (^$base).all.map({ @d[$_] // 0 == @d.grep($_).elems })
}
for 4, 5, 7, 10 -> $b {
    for self-descriptive-numbers-of($b).list -> $s {
        say sprintf('  base %2d  %-14s self-descriptive by definition : %s',
                    $b, $s, so describes($s, $b));
    }
}
```

```output
  base  4  1210           self-descriptive by definition : True
  base  4  2020           self-descriptive by definition : True
  base  5  21200          self-descriptive by definition : True
  base  7  3211000        self-descriptive by definition : True
  base 10  6210001000     self-descriptive by definition : True
```

## The one thing to know

The `Int` form takes a **decimal value**, so `is-self-descriptive(1210, 4)` is
`False`.

```raku name="int-vs-str"
use Math::SelfDescriptiveNumbers;

say 'the Str form compares the digit string you gave:';
say '  is-self-descriptive("1210", 4) = ', is-self-descriptive('1210', 4);
say '';
say 'the Int form calls $number.base($base) FIRST:';
say '  is-self-descriptive(1210, 4)   = ', is-self-descriptive(1210, 4);
say '  1210.base(4)                   = ', 1210.base(4);
say '';
say 'so the Int form wants the numeric VALUE:';
say '  "1210" in base 4 is ', '1210'.parse-base(4), ' in decimal';
say '  is-self-descriptive(100, 4)    = ', is-self-descriptive(100, 4);
say '';
say 'both calls are legal, neither warns, and the one that LOOKS right is';
say 'the one that returns the wrong answer. Use the Str form.';
```

```output
the Str form compares the digit string you gave:
  is-self-descriptive("1210", 4) = True

the Int form calls $number.base($base) FIRST:
  is-self-descriptive(1210, 4)   = False
  1210.base(4)                   = 102322

so the Int form wants the numeric VALUE:
  "1210" in base 4 is 100 in decimal
  is-self-descriptive(100, 4)    = True

both calls are legal, neither warns, and the one that LOOKS right is
the one that returns the wrong answer. Use the Str form.
```

## The return shape changes with the base

```raku name="shape"
use Math::SelfDescriptiveNumbers;

for 3, 4, 5, 10 -> $b {
    my $r = self-descriptive-numbers-of($b);
    say sprintf('  base %2d  type %-5s elems %d  value %s',
                $b, $r.WHAT.^name, $r.elems, $r.raku);
}
say '';
say "('21200') in Raku is a parenthesised Str, not a one-element list — so";
say 'base 4 hands you a List and every other non-empty base a bare Str.';
say 'Anything doing .[0] or .map across bases has to cope with both.';
say '';
say 'normalise it:';
sub answers(Int $b) { self-descriptive-numbers-of($b).list }
for 3, 4, 10 -> $b {
    say sprintf('  answers(%2d) = %s', $b, answers($b).raku);
}
```

```output
  base  3  type List  elems 0  value $( )
  base  4  type List  elems 2  value $("1210", "2020")
  base  5  type Str   elems 1  value "21200"
  base 10  type Str   elems 1  value "6210001000"

('21200') in Raku is a parenthesised Str, not a one-element list — so
base 4 hands you a List and every other non-empty base a bare Str.
Anything doing .[0] or .map across bases has to cope with both.

normalise it:
  answers( 3) = ()
  answers( 4) = ("1210", "2020")
  answers(10) = ("6210001000",)
```

## Where the two engines differ

Nothing. The three hard-coded cases, the closed form, both membership forms
and every shape above are identical on both engines. The one thing to plan
around is shared: bases outside 2..36 die from `.base`, not from a check of
the module's own.

```raku name="portable"
use Math::SelfDescriptiveNumbers;

for 0, -1, 37, 36 -> $b {
    my $r = try self-descriptive-numbers-of($b);
    say sprintf('  base %3d -> %s', $b,
                $! ?? 'X::OutOfRange from .base' !! ($r.elems ?? $r.raku !! '(none)'));
}
say '';
say 'note base 1 returns () happily while is-self-descriptive(10, 1) dies,';
say 'so the two halves of the API disagree about what base 1 means.';
say '';
say 'the two table subs give you everything at once:';
say '  self-descriptive-numbers().elems     = ', self-descriptive-numbers().elems;
my @dec = self-descriptive-numbers-dec();
say '  …-dec() parses them back, e.g. base 10 -> ',
    @dec.first({ .[0] == 10 })[1].list.raku;
```

```output
  base   0 -> X::OutOfRange from .base
  base  -1 -> X::OutOfRange from .base
  base  37 -> X::OutOfRange from .base
  base  36 -> "W21000000000000000000000000000001000"

note base 1 returns () happily while is-self-descriptive(10, 1) dies,
so the two halves of the API disagree about what base 1 means.

the two table subs give you everything at once:
  self-descriptive-numbers().elems     = 36
  …-dec() parses them back, e.g. base 10 -> (6210001000,)
```
