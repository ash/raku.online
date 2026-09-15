---
name: Calculator
version: 0.0.1
auth: github:manwar
kind: Distribution · arithmetic
summary: A two-number arithmetic object — construct it with an x and a y, then
  ask for their sum, difference, product or quotient.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/github:manwar/Calculator
source: git://github.com/manwar/p6-Calculator.git
---

## What it is for

This is a first distribution — the kind written to learn the packaging, the
test harness and the metadata rather than to solve a problem. It holds two
numbers and offers the four arithmetic operations on them.

It is in the handbook because it is short enough to read in full and because
its constructor makes a decision worth understanding before you copy the
pattern.

## Using it

```raku name="calculator"
use Calculator;

my $c = Calculator.new(x => 10, y => 3);
say 'x = ', $c.x, '   y = ', $c.y;
say '';
say 'add       -> ', $c.add;
say 'substract -> ', $c.substract;
say 'multiply  -> ', $c.multiply;
say 'divide    -> ', $c.divide, '   (a ', $c.divide.^name, ', exactly ',
    $c.divide.nude.join('/'), ')';
```

```output
x = 10   y = 3

add       -> 13
substract -> 7
multiply  -> 30
divide    -> 3.333333   (a Rat, exactly 10/3)
```

`divide` returns an exact `Rat`, which is the right answer and not what most
calculators give you.

Note the spelling: the method is **`substract`**, without the first `t`.
`.subtract` is a method-not-found on both engines.

## Named arguments only

```raku name="named"
use Calculator;

my $r = try Calculator.new(10, 3);
say 'positional arguments : ', $! ?? 'refused' !! 'accepted';
say 'named arguments      : ', Calculator.new(x => 10, y => 3).add;
say '';
my $n = try Calculator.new(x => 10);
say 'a missing y          : ', $! ?? 'refused' !! 'accepted';
```

```output
positional arguments : refused
named arguments      : 13

a missing y          : refused
```

Both attributes are `is required`, so the constructor tells you what is
missing.

## The one thing to know

The constructor, not the methods, decides what arithmetic you are allowed to
do: it demands `x > y > 0`.

```raku name="constraint-trap"
use Calculator;

sub attempt($label, &c) {
    my $r = try c();
    say sprintf('%-22s %s', $label, $! ?? 'refused' !! 'ok -> ' ~ $r);
}

attempt 'new(x=>10, y=>3).add',  { Calculator.new(x => 10, y => 3).add };
attempt 'new(x=>3,  y=>10).add', { Calculator.new(x => 3,  y => 10).add };
attempt 'new(x=>5,  y=>5).add',  { Calculator.new(x => 5,  y => 5).add };
attempt 'new(x=>5,  y=>0).add',  { Calculator.new(x => 5,  y => 0).add };
attempt 'new(x=>5,  y=>-2).add', { Calculator.new(x => 5,  y => -2).add };
```

```output
new(x=>10, y=>3).add   ok -> 13
new(x=>3,  y=>10).add  refused
new(x=>5,  y=>5).add   refused
new(x=>5,  y=>0).add   refused
new(x=>5,  y=>-2).add  refused
```

This is a `Calculator` that cannot compute `3 + 10`, cannot compute `5 − 5`,
and cannot touch zero or any negative number. The refusal happens at `new`,
before you have named an operation — so a program that only ever wanted
`multiply` still dies because its operands are in the wrong order, with a
message about a relation that has nothing to do with multiplication.

Roughly the only genuine two-number sum this class can express is one where
the first number is strictly the larger and both are positive.

## Where the two engines differ

On whether the declared attribute **type** is enforced at all.

`has Int $.x is required where * > 0` carries both a type and a constraint.
Rakudo applies both, so `Calculator.new(x => 2.5, y => 1)` and
`Calculator.new(x => '7', y => '3')` are refused. Raku++ applies only the
`where`, so the same two calls build an object and `.add` returns `3.5` and
`10` respectively.

Code that passes a `Rat` or a numeric string therefore works on one engine and
is refused on the other — and the one that accepts it is the one giving you an
`Int`-declared attribute holding a `Str`.

The `git://` source URL in the metadata uses a protocol GitHub stopped
serving.
