---
name: Physics::Error
version: 0.1.9
auth: zef:librasteve
kind: Distribution · science
summary: The measurement uncertainty attached to a physical quantity — the
  plus-or-minus — converting between absolute, relative and percentage forms.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: FatRatStr
raku-land: https://raku.land/zef:librasteve/Physics::Error
source: git://github.com/librasteve/raku-Physics-Error.git
---

## What it is for

A measured quantity is not a number, it is a number and an uncertainty:
9.81 ± 0.05 m/s². The uncertainty can be stated three ways — absolute,
relative, or as a percentage — and converting between them needs the measured
value, which the error itself does not carry.

This distribution is the class that holds the uncertainty and does those
conversions. It is a support class for a measurement library rather than a
standalone one.

## Holding an uncertainty

```raku name="error"
use Physics::Error;

my $abs = Error.new(:error(0.05));
$abs.bind-mea-value(9.81);

say 'an absolute 0.05 on a measured 9.81:';
say '  .absolute : ', $abs.absolute;
say '  .relative : ', $abs.relative.round(0.000001);
say '  .percent  : ', $abs.percent;
say '  .Str      : ', $abs.Str;
say '';
my $pct = Error.new(:error('2%'), :value(200));
$pct.bind-mea-value(200);
say "the same error stated as '2%' of 200:";
say '  .absolute : ', $pct.absolute;
say '  .relative : ', $pct.relative;
say '  .percent  : ', $pct.percent;
```

```output
an absolute 0.05 on a measured 9.81:
  .absolute : 0.05
  .relative : 0.005097
  .percent  : 0.5%
  .Str      : 0.05

the same error stated as '2%' of 200:
  .absolute : 4
  .relative : 0.02
  .percent  : 2%
```

Note the class is called **`Error`**, not `Physics::Error` — the unit exports
that name.

`bind-mea-value` is how the measured value reaches the object, and it is
required before `.relative` or `.percent` mean anything.

## Combining

```raku name="combine"
use Physics::Error;

my $a = Error.new(:error(3)); $a.bind-mea-value(100);
my $b = Error.new(:error(4)); $b.bind-mea-value(100);

say 'a = 3, b = 4, both on a measured 100';
say '  a.add-abs(b) returns : ', $a.add-abs($b), '   (a Real, not an Error)';
say '  a.absolute is now    : ', $a.absolute, '   — add-abs MUTATED a';
say '';
my $c = Error.new(:error(3)); $c.bind-mea-value(100);
say '  c.add-rel(b) returns : ', $c.add-rel($b);
say '  c.absolute is still  : ', $c.absolute, '   — add-rel did not';
```

```output
a = 3, b = 4, both on a measured 100
  a.add-abs(b) returns : 7   (a Real, not an Error)
  a.absolute is now    : 7   — add-abs MUTATED a

  c.add-rel(b) returns : 0.07
  c.absolute is still  : 3   — add-rel did not
```

Three things fall out. The two combining methods are **asymmetric**: one
mutates the invocant and one does not. Neither returns an `Error`. And errors
combine **linearly** — 3 + 4 = 7 — rather than in quadrature, which is what a
physicist would expect for independent uncertainties.

`.absolute` is also `is rw`, so an `Error` is a mutable value passed by
reference.

## Bad input

```raku name="input"
use Physics::Error;

for 'Error.new()',                 { Error.new() },
    'Error.new(:value(10))',       { Error.new(:value(10)) },
    'Error.new(:error(Nil))',      { Error.new(:error(Nil)) },
    'Error.new(:error("bananas"))',{ Error.new(:error('bananas')) },
    'Error.new(:error(-3))',       { Error.new(:error(-3)) } -> $label, &c {
    my $e = c();
    say sprintf('%-30s -> %s', $label,
        $e.defined ?? 'an Error with absolute=' ~ $e.absolute !! 'Nil');
}
```

```output
Error.new()                    -> Nil
Error.new(:value(10))          -> Nil
Error.new(:error(Nil))         -> Nil
Error.new(:error("bananas"))   -> Nil
Error.new(:error(-3))          -> an Error with absolute=3
```

`Error.new` returns **`Nil`** — not an `Error`, not a `Failure` — whenever
`:error` is missing, undefined or unparseable. `Error.new(:error('bananas'))`
is accepted in silence. And a negative error silently loses its sign.

A caller doing `my $e = Error.new(:error($user-input));` and proceeding will
fail at the first method call with a type-object error, far from the cause.

## The one thing to know

The percent output mode cannot be switched on.

`.Str` consults a module-level `$default`, and the file declares
`our $default = 'absolute'` in its mainline. But the file has **no `unit
module` declarator** — it is a bare `use`, two `our` variables and `class Error
is export`. So `$default` never lands in the `Physics::Error::` namespace, and
assigning to `$Physics::Error::default` autovivifies a fresh, unrelated
package variable without complaint.

The `'percent'` branch of `.Str`, and the `$round-per` rounding knob beside
it, are dead from outside the module. Call `.percent` explicitly.

## Where the two engines differ

On the path where you forgot `bind-mea-value`, and it is a silent wrong answer
against a stop.

`.relative` with nothing bound divides by an uninitialised value. Rakudo
reports `Use of uninitialized value of type Real in numeric context` and
halts. Raku++ returns **`Inf`**, then `.percent` returns `"Inf%"`, and the
program carries on for two more calls before dying somewhere else entirely.

Bind the measured value immediately after constructing, every time.
