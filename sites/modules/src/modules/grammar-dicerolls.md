---
name: Grammar::DiceRolls
version: 0.3.1
auth: none stated
kind: Distribution · grammars
summary: A grammar for tabletop dice notation — 3d6, 2d6+1d4-1 — with two
  action classes, one returning a total and one every individual die.
status: full
suite: 3 files, green
tested: 2026-09-15
license: AGPL-3.0-or-later
depends: none beyond the core
raku-land: https://raku.land/?/Grammar::DiceRolls
source: https://home.tyil.nl/git/raku/Grammar::DiceRolls/
---

## What it is for

`3d6+2` is a compact, universally understood way to say "roll three six-sided
dice and add two". Any program that touches tabletop rules — a character
generator, a combat simulator, a chat bot — needs to read that notation and
act on it.

This distribution splits the job the way Raku wants it split: a grammar that
recognises the notation, and two separate action classes that decide what to
do with a successful parse.

## Parsing the notation

```raku name="parse"
use Grammar::DiceRolls;

my $m = Grammar::DiceRolls.parse('3d6+2d4-1');
say 'parsed  : ', ?$m;
say 'dice    : ', $m<dice>.map({ "{$_<count>}d{$_<sides>}" }).join(' ');
say 'bonus   : ', $m<bonus>.map({ $_<value>.Str }).join(' ');
say '';
for '1d6', '1d6+2', '1d6-2', '2d6+1d4', '1d6+2-3', 'd6', '0d6', '1d0', '1 d 6', '' -> $s {
    say sprintf('parse %-10s -> %s', "'$s'", Grammar::DiceRolls.parse($s) ?? 'ok' !! 'no match');
}
```

```output
parsed  : True
dice    : 3d6 2d4
bonus   : -1

parse '1d6'      -> ok
parse '1d6+2'    -> ok
parse '1d6-2'    -> ok
parse '2d6+1d4'  -> ok
parse '1d6+2-3'  -> ok
parse 'd6'       -> no match
parse '0d6'      -> ok
parse '1d0'      -> ok
parse '1 d 6'    -> no match
parse ''         -> no match
```

The count is mandatory — `d6` alone does not parse — and whitespace anywhere
inside the expression is rejected. `0d6` and `1d0` both parse, which is worth
knowing before you trust the result.

## Rolling

Dice are random, so what an example can assert is the shape and the bounds:

```raku name="roll"
use Grammar::DiceRolls;
use Grammar::DiceRolls::CountActions;
use Grammar::DiceRolls::ListActions;

my @totals = (^200).map({
    Grammar::DiceRolls.parse('3d6+2', actions => Grammar::DiceRolls::CountActions.new).made
});
say 'CountActions gives an Int  : ', ?all(@totals.map(* ~~ Int));
say '3d6+2 is always in 5..20   : ', ?all(@totals.map({ 5 <= $_ <= 20 }));
say 'and the range is exercised : ', @totals.min == 5 || @totals.unique.elems > 8;
say '';
my @lists = (^200).map({
    Grammar::DiceRolls.parse('3d6+2', actions => Grammar::DiceRolls::ListActions.new).made.List
});
say 'ListActions gives 4 values : ', ?all(@lists.map(*.elems == 4));
say 'first three are each 1..6  : ', ?all(@lists.map({ ?all(.[^3].map({ 1 <= $_ <= 6 })) }));
say 'the last is the bonus, 2   : ', ?all(@lists.map(*.[3] == 2));
```

```output
CountActions gives an Int  : True
3d6+2 is always in 5..20   : True
and the range is exercised : True

ListActions gives 4 values : True
first three are each 1..6  : True
the last is the bonus, 2   : True
```

`CountActions` gives you the sum. `ListActions` gives you every die result in
order, followed by the bonuses — which is what you want when the table expects
you to show your work.

## Limits

```raku name="limits"
use Grammar::DiceRolls;
use Grammar::DiceRolls::ListActions;
use X::Grammar::DiceRolls::TooManyDice;
use X::Grammar::DiceRolls::TooManySides;

sub roll($expr, *%limits) {
    my $a = Grammar::DiceRolls::ListActions.new(|%limits);
    my $r = try Grammar::DiceRolls.parse($expr, actions => $a);
    $! ?? "{$!.^name.subst('X::Grammar::DiceRolls::', '')} count={$!.count}"
       !! "ok, {$r.made.elems} results"
}

say '2d6  with limit-dice 2   : ', roll('2d6',   :limit-dice(2));
say '3d6  with limit-dice 2   : ', roll('3d6',   :limit-dice(2));
say '1d20 with limit-sides 6  : ', roll('1d20',  :limit-sides(6));
say '2d6+1 with limit-dice 2  : ', roll('2d6+1', :limit-dice(2));
```

```output
2d6  with limit-dice 2   : ok, 2 results
3d6  with limit-dice 2   : TooManyDice count=3
1d20 with limit-sides 6  : TooManySides count=20
2d6+1 with limit-dice 2  : TooManyDice count=3
```

That last line is the first surprise: a **bonus counts as a die** against
`limit-dice`, because `bonus` increments the counter before checking it. So
`2d6+1` with a limit of two dice is refused even though only two dice are
rolled.

The two exception classes carry only a `.count` and no message, and they mean
different things by it — `TooManySides` reports the offending number of sides,
not a die count.

## The one thing to know

A `ListActions` object is single-use. Its die counter only ever accumulates,
so the limit applies to the **lifetime of the object**, not to the expression
being parsed.

```raku name="reuse-trap"
use Grammar::DiceRolls;
use Grammar::DiceRolls::ListActions;

my $actions = Grammar::DiceRolls::ListActions.new(limit-dice => 3);

for 1, 2 -> $n {
    my $r = try Grammar::DiceRolls.parse('2d6', actions => $actions);
    say "parse $n of the identical '2d6' : ",
        $! ?? "threw, count={$!.count}" !! "ok, {$r.made.elems} results";
}
say '';
say 'a fresh object each time works:';
for 1, 2 -> $n {
    my $r = try Grammar::DiceRolls.parse('2d6',
        actions => Grammar::DiceRolls::ListActions.new(limit-dice => 3));
    say "  parse $n : ", $! ?? 'threw' !! "ok, {$r.made.elems} results";
}
```

```output
parse 1 of the identical '2d6' : ok, 2 results
parse 2 of the identical '2d6' : threw, count=4

a fresh object each time works:
  parse 1 : ok, 2 results
  parse 2 : ok, 2 results
```

The natural pattern — build the actions object once, roll many times — fails
after the first few rolls, and the exception blames the expression rather than
the reuse. Construct a fresh `ListActions` for every parse.

## Where the two engines differ

Nowhere. Every spike in this page, including the limit behaviour and the
counter that does not reset, produced identical verdicts on Raku++ and Rakudo.

The values themselves are genuinely random and are not reproducible across
engines even with a fixed seed, because both action classes call `.pick` on a
`Range`. Do not expect the same numbers from the two engines.

Two degenerate cases to guard against, since neither is rejected: `0d6` yields
an empty list, and `1d0` yields `(Nil,)` from picking on an empty range —
which, fed to `CountActions`, puts a `Nil` into a `.sum`.
