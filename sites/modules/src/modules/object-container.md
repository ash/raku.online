---
name: Object::Container
version: 0.0.2
auth: cpan:MOZNION
kind: Distribution · dependency injection
summary: A name-to-object registry with lazy initialisers — and a lock that
  stays locked if an initialiser throws.
status: divergent
suite: 4 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/cpan:MOZNION/Object::Container
source: git://github.com/moznion/p6-Object-Container.git
---

## What it is for

A service locator: register a database handle, a cache client and a logger
under names, ask for them by name later, and let the expensive ones be built
on first use rather than at startup.

## Registering and fetching

```raku name="basics"
use Object::Container;

class Widget { has $.id }

my $c = Object::Container.new;
$c.register('w', Widget.new(id => 7));
say 'get("w")      : ', $c.get('w').raku;
say 'get(missing)  : ', $c.get('nope').raku;
say 'remove("w")   : ', $c.remove('w');
say 'remove again  : ', $c.remove('w');
say 'get after rm  : ', $c.get('w').raku;
say '';
my $built = 0;
$c.register('lazy', sub { $built++; Widget.new(id => 99) });
say 'built before get : ', $built;
say 'first get        : ', $c.get('lazy').raku, '  built=', $built;
say 'second get       : ', $c.get('lazy').raku, '  built=', $built;
say 'same object      : ', $c.get('lazy') === $c.get('lazy');
$c.clear;
say 'after clear      : ', $c.get('lazy').raku;
```

```output
get("w")      : Widget.new(id => 7)
get(missing)  : Nil
remove("w")   : True
remove again  : False
get after rm  : Nil

built before get : 0
first get        : Widget.new(id => 99)  built=1
second get       : Widget.new(id => 99)  built=1
same object      : True
after clear      : Nil
```

## Class methods are a different container

```raku name="singleton"
use Object::Container;

class Widget { has $.id }

Object::Container.register('shared', Widget.new(id => 1));
say 'class method sees "shared"   : ', Object::Container.get('shared').raku;
say '';
my $inst = Object::Container.new;
say 'a fresh instance sees it     : ', $inst.get('shared').raku;
$inst.register('mine', Widget.new(id => 2));
say 'class method sees "mine"     : ', Object::Container.get('mine').raku;
say '';
say 'called as class methods the whole thing collapses to one';
say 'process-wide singleton; instances are separate. Mixing the two';
say 'styles silently loses registrations — pick one.';
```

```output
class method sees "shared"   : Widget.new(id => 1)

a fresh instance sees it     : Nil
class method sees "mine"     : Nil

called as class methods the whole thing collapses to one
process-wide singleton; instances are separate. Mixing the two
styles silently loses registrations — pick one.
```

## You can never store a Callable

```raku name="callable"
use Object::Container;

my $c = Object::Container.new;
my &handler = sub { 'I AM THE VALUE' };
$c.register('cb', &handler);
say 'get("cb")       : ', $c.get('cb').raku;
say '  is it Code ?  : ', ($c.get('cb') ~~ Code);
say '';
say 'the Callable:D candidate is NARROWER than Any:D, so register always';
say 'takes the lazy branch and get hands you the RETURN VALUE. A registry';
say 'of handlers or factories is impossible without wrapping each one:';
class Holder { has &.fn }
$c.register('wrapped', Holder.new(fn => &handler));
say '  wrapped       : ', $c.get('wrapped').fn.().raku;
say '';
say 'and a type object or Nil is refused outright:';
my $r = try $c.register('t', Int);
say '  register("t", Int) -> ', $! ?? 'X::Multi::NoMatch' !! 'accepted';
```

```output
get("cb")       : "I AM THE VALUE"
  is it Code ?  : False

the Callable:D candidate is NARROWER than Any:D, so register always
takes the lazy branch and get hands you the RETURN VALUE. A registry
of handlers or factories is impossible without wrapping each one:
  wrapped       : "I AM THE VALUE"

and a type object or Nil is refused outright:
  register("t", Int) -> X::Multi::NoMatch
```

## The one thing to know

An initialiser that throws leaves that entry's `Lock` locked forever. Every
later `get` of that name **from another thread** blocks for good.

```raku name="poisoned"
use Object::Container;

my $c = Object::Container.new;
my $calls = 0;
$c.register('bad', sub { $calls++; die 'initializer failed' });

my $first = try $c.get('bad');
say 'first get     : ', $! ?? 'threw — ' ~ $!.message !! 'returned';
say 'calls so far  : ', $calls;
say '';
say 'get-instance does  $!lock.lock; … $!instance = $!initializer(); …';
say '$!lock.unlock  with no LEAVE and no .protect — so the throw skips';
say 'the unlock.';
say '';
say 'the SAME thread can still get through, because Lock is reentrant';
say 'per-thread:';
my $second = try $c.get('bad');
say '  second get on this thread : ', $! ?? 'threw again' !! 'returned';
say '  calls now                 : ', $calls;
say '';
say 'a SECOND thread blocks forever. And each entry has its own Lock, so';
say 'other keys keep working — which makes it far harder to diagnose:';
$c.register('ok', sub { 'healthy' });
say '  a different key still works : ', $c.get('ok').raku;
say '';
say 'wrap your initialisers so they cannot throw.';
```

```output
first get     : threw — initializer failed
calls so far  : 1

get-instance does  $!lock.lock; … $!instance = $!initializer(); …
$!lock.unlock  with no LEAVE and no .protect — so the throw skips
the unlock.

the SAME thread can still get through, because Lock is reentrant
per-thread:
  second get on this thread : threw again
  calls now                 : 2

a SECOND thread blocks forever. And each entry has its own Lock, so
other keys keep working — which makes it far harder to diagnose:
  a different key still works : "healthy"

wrap your initialisers so they cannot throw.
```

## Where the two engines differ

One case, and it is about a self-referential initialiser — an initialiser that
asks the container for the key it is building. Raku++ has a recursion-depth
guard and converts the runaway into a catchable `X::Recursion`; Rakudo spins
until you kill it.

```raku name="portable"
use Object::Container;

# an initialiser that cannot throw, and cannot recurse
my $c = Object::Container.new;
$c.register('config', sub {
    my $r = try { %( retries => 3, timeout => 30 ) };
    $r // %()
});
say 'config : ', $c.get('config').raku;
say '';
say 'an initialiser returning Nil is cached as Any and NOT retried:';
my $n = 0;
$c.register('nil', sub { $n++; Nil });
$c.get('nil'); $c.get('nil');
say '  get twice, initialiser ran : ', $n, ' time(s)';
say '';
say 'and get-instance`s double-checked-lock fast path returns while still';
say 'holding the lock — unreachable single-threaded, the same leak in a';
say 'race. Treat this container as single-threaded, or build your own.';
```

```output
config : ${:retries(3), :timeout(30)}

an initialiser returning Nil is cached as Any and NOT retried:
  get twice, initialiser ran : 1 time(s)

and get-instance`s double-checked-lock fast path returns while still
holding the lock — unreachable single-threaded, the same leak in a
race. Treat this container as single-threaded, or build your own.
```
