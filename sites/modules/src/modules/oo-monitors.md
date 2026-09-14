---
name: OO::Monitors
version: 1.1.7
auth: zef:raku-community-modules
kind: Distribution · concurrency
summary: A `monitor` declarator — a class whose every method call takes the
  object's own lock on the way in, so one thread at a time is inside it and
  the methods carry no locking code of their own.
status: divergent
suite: 5 files, basic.rakutest fails under Raku++
tested: 2026-09-14
license: Artistic-2.0
raku-land: https://raku.land/zef:raku-community-modules/OO::Monitors
source: https://github.com/raku-community-modules/OO-Monitors
---

## What it is for

An object that several threads share needs its state changed by one of them
at a time, and the usual way to arrange that is a `Lock` attribute and a
`$!lock.protect: { … }` around the body of every method — which is
repetitive, easy to forget on the one method added later, and the reason
Hoare's *monitor* exists as a concept: a class where the protection is a
property of the type rather than of each method.

This distribution adds that concept as a declarator. `monitor Foo { … }` is
`class Foo { … }` with a different metaclass, which gives every instance a
hidden `Lock` and wraps each method so the lock is held for the call. The
lock is re-entrant, so a method that calls another method of the same object
does not deadlock on itself. Thirteen distributions build on it, including
`Terminal::ANSI`'s stateful terminal object.

## A monitor is a class

```raku name="declare"
use OO::Monitors;

monitor Ledger {
    has %!balance;
    method deposit(Str $who, Int $amount) { %!balance{$who} += $amount; self }
    method balance(Str $who)             { %!balance{$who} // 0 }
    method total                         { %!balance.values.sum }
}

my $ledger = Ledger.new;
$ledger.deposit('ada', 40).deposit('ada', 2).deposit('grace', 10);
say $ledger.balance('ada'), ' ', $ledger.balance('grace'), ' ', $ledger.total;
say Ledger.^name, ' ', $ledger ~~ Ledger;
```

```output
42 10 52
Ledger True
```

Everything a class can do, a monitor can: attributes, `BUILD`, inheritance,
roles, `.new` with named arguments. The difference only shows when two
threads arrive at once, and that is the case the distribution's own test
exercises — four threads, a thousand increments each, one counter:

```raku fragment
monitor Counter {
    has $!n = 0;
    method inc { $!n++ }
    method n   { $!n }
}

my $counter = Counter.new;
await do for ^4 { start { $counter.inc for ^1000 } }
say $counter.n;    # Rakudo: 4000, every run
```

## The one thing to know

Under Raku++ 3.28 that program prints something like 3,970 — a different
number each run, and never 4,000. The `monitor` keyword is accepted and the
type it makes reports the right metaclass, but the engine builds the class
through its own machinery and never consults that metaclass's `new_type` and
`add_method` hooks, which are where the lock attribute is added and each
method is wrapped; nor does it run the `BUILDALL` the metaclass wraps to
create the lock. So the wrap never happens, and the monitor is a plain class
whose increments race like anyone else's.

The distribution's own `basic.rakutest` measures exactly this and fails, so
`rakupp install OO::Monitors` refuses unless you pass `--no-test`. If you do,
know what you are installing: on Raku++ today a monitor gives you the syntax
and none of the exclusion. Where the exclusion is the point, keep a `Lock`
attribute and `protect` the bodies yourself until the engine catches up; the
gap is filed and this page will change when it closes.
