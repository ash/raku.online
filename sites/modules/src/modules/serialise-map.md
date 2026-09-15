---
name: Serialise::Map
version: 0.1.1
auth: none stated
kind: Distribution · serialisation
summary: An interface-only role declaring that a class can hand out a Map of
  its state and rebuild itself from one.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/?/Serialise::Map
source: git://github.com/samgwise/p6-mappable.git
---

## What it is for

A serialisation layer that knows how to write a `Map` should not also have to
know about your classes, and your classes should not have to know about the
format. The usual way to bridge that is an interface: a class promises two
methods, and anything holding an object of that kind can call them.

This distribution is that promise, and nothing else. There is no
implementation — composing the role obliges you to write both methods.

## Composing it

```raku name="compose"
use Serialise::Map;

class Point does Serialise::Map {
    has $.x;
    has $.y;
    method to-map(--> Map) { Map.new(( x => $!x, y => $!y )) }
    method from-map(Map $map) { self.new(|$map) }
}

my $p = Point.new(:x(3), :y(4));
my $m = $p.to-map;

say 'to-map returns a : ', $m.^name;
say '  contents       : ', $m.sort(*.key).map({ "{.key}={.value}" }).join(' ');
say '';
my $q = $p.from-map($m);
say 'round trip : x=', $q.x, ' y=', $q.y;
say 'same class : ', $q.^name eq $p.^name;
say '';
say 'the object does the role : ', $p ~~ Serialise::Map;
say 'the role requires        : ', Serialise::Map.^methods.map(*.name).sort.join(' ');
```

```output
to-map returns a : Map
  contents       : x=3 y=4

round trip : x=3 y=4
same class : True

the object does the role : True
the role requires        : from-map to-map
```

That is the whole distribution: a type you can test against and two required
methods.

## What the role buys you

```raku name="buys"
use Serialise::Map;

class Point does Serialise::Map {
    has $.x; has $.y;
    method to-map(--> Map) { Map.new(( x => $!x, y => $!y )) }
    method from-map(Map $map) { self.new(|$map) }
}

class Plain { has $.z }

sub save($thing) {
    $thing ~~ Serialise::Map
        ?? 'saved: ' ~ $thing.to-map.sort(*.key).map({ "{.key}={.value}" }).join(' ')
        !! 'cannot serialise a ' ~ $thing.^name
}

say save(Point.new(:x(1), :y(2)));
say save(Plain.new(:z(9)));
```

```output
saved: x=1 y=2
cannot serialise a Plain
```

One type check tells a storage layer whether it can proceed. That is the
value, and it is real — it is just small.

## The one thing to know

`from-map` is declared as an **instance** method, so the deserialiser is
shaped like something you can only call on an object you already have.

```raku name="instance-trap"
use Serialise::Map;

class Point does Serialise::Map {
    has $.x; has $.y;
    method to-map(--> Map) { Map.new(( x => $!x, y => $!y )) }
    method from-map(Map $map) { self.new(|$map) }
}

my $m = Point.new(:x(1), :y(2)).to-map;

say 'on an instance    : ', Point.new(:x(0), :y(0)).from-map($m).x;
say 'on the type object: ', Point.from-map($m).x;
say '';
say 'the second works only because THIS body happens to be self.new(|$map).';
say 'a body that assigns to attributes would compose just as legally';
say 'and could not be called on the type object at all.';
```

```output
on an instance    : 1
on the type object: 1

the second works only because THIS body happens to be self.new(|$map).
a body that assigns to attributes would compose just as legally
and could not be called on the type object at all.
```

The role imposes no `:U` invocant and no return type on `from-map`, so nothing
in the contract guarantees it works as a constructor. A consumer who writes
`method from-map(Map $m) { $!x = $m<x>; self }` satisfies the role and breaks
every caller that treated it as one.

Nothing enforces the round trip either — the role does not constrain what
`from-map` returns.

If you are defining the interface for your own codebase, add `:U` to the
invocant and `--> ::?CLASS` to the return.

## Where the two engines differ

Only on which missing method they name first. A class that composes the role
and implements neither is refused by both engines, with Rakudo naming
`to-map` at compile time and Raku++ naming `from-map` from a runtime-style
frame.

Both refuse it, which is the behaviour that matters. It does mean the error
text cannot be asserted in a test.

The distribution declares no `auth` and no `api`.
