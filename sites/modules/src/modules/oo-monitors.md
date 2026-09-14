---
name: OO::Monitors
version: 1.1.7
auth: zef:raku-community-modules
kind: Distribution · concurrency
summary: A `monitor` declarator — a class whose every method call takes the
  object's own lock on the way in, so one thread at a time is inside it and
  the methods carry no locking code of their own.
status: full
suite: 5 files, green
tested: 2026-09-15
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

## A monitor is a class that serialises itself

```raku name="declare"
use OO::Monitors;

monitor Counter {
    has $!n = 0;
    method inc { $!n++ }
    method n   { $!n }
}

my $counter = Counter.new;
await do for ^4 { start { $counter.inc for ^1000 } }
say $counter.n;
say Counter.^name, ' ', $counter ~~ Counter;
```

```output
4000
Counter True
```

Four threads, a thousand increments each, and the answer is four thousand
every time — the increment is read-modify-write, and without the lock the
threads lose updates and the total lands somewhere in the high three
thousands. Nothing in the class body says so: the only difference from
`class` is the keyword.

Everything else a class can do, a monitor can — attributes, `BUILD`,
inheritance, roles, `.new` with named arguments — and a method calling
another method on the same object is fine, because the lock is re-entrant:

```raku name="reentrant"
use OO::Monitors;

monitor Ledger {
    has %!balance;
    method deposit(Str $who, Int $amount) { %!balance{$who} += $amount; self }
    method transfer(Str $from, Str $to, Int $amount) {
        self.deposit($from, -$amount);     # a method, from inside a method
        self.deposit($to, $amount);
    }
    method balance(Str $who) { %!balance{$who} // 0 }
    method snapshot { %!balance.clone }
}

my $ledger = Ledger.new;
$ledger.deposit('ada', 100).deposit('grace', 10);
$ledger.transfer('ada', 'grace', 40);
say $ledger.balance('ada'), ' ', $ledger.balance('grace');
say $ledger.snapshot.sort.map({ .key ~ '=' ~ .value }).join(' ');
```

```output
60 50
ada=60 grace=50
```

`transfer` holds the lock across both deposits, so no other thread sees the
money after it has left one account and before it has reached the other —
which is the property a lock per *method* would not give you.

## The one thing to know

The lock protects the **call**, not the data. A method that returns one of
the object's own containers hands the caller a reference, and every write
through that reference happens with no lock held:

```raku name="escapes"
use OO::Monitors;

monitor Registry {
    has %!items;
    method add(Str $k, $v) { %!items{$k} = $v; self }
    method items { %!items }         # hands the container out
    method copy  { %!items.clone }   # hands a snapshot out
    method count { %!items.elems }
}

my $r = Registry.new;
$r.add('a', 1);
$r.items<b> = 2;                      # written from outside, unlocked
say $r.count;
my %snapshot = $r.copy;
%snapshot<c> = 3;                     # written into the copy
say $r.count;
```

```output
2
2
```

The first write lands *inside* the monitor without ever taking its lock;
the second cannot, because `copy` handed out a clone. So return copies of
anything mutable, or return the answer rather than the structure — the
declarator cannot help you here, since by the time the caller writes, the
method that leaked the container has already returned and released the
lock.

Two smaller consequences of wrapping every method. Reads are serialised
too, so a monitor whose accessors are called in a hot loop is a bottleneck
where a `Lock` taken only on writes would not be; and a call on the *type
object*, `.new` above all, is delegated without locking, which is correct
and worth knowing if you were counting on construction to be serialised.

Until Raku++ 3.28 this page carried a red badge: the engine built the class
without consulting the declarator's metaclass, so the lock attribute was
never added and no method was ever wrapped — a monitor had the syntax and
none of the exclusion, and the counter above landed near 3,970. The engine
now runs those hooks, the distribution's own suite is green, and every
example on this page is checked under both engines like the rest.
