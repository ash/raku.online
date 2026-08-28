---
name: Method::Also
version: 0.0.10
auth: zef:lizmat
kind: Distribution · language
summary: An "is also" trait that gives one method several names — aliases
  for a friendlier API, or for the protocol hooks Raku itself looks up, with
  no forwarder methods to write.
status: full
license: Artistic-2.0
suite: 1 file, green
tested: 2026-08-28
raku-land: https://raku.land/zef:lizmat/Method::Also
source: https://github.com/lizmat/Method-Also
---

## What it is for

Sometimes one method honestly has two names. You renamed `add` to `push`
and owe your users a release of overlap; your queue class wants to read
naturally to people arriving from either `.enqueue` or `.push` habits; or
you want the *same* body to serve both your public name and a protocol
name Raku looks up by convention. Without this module each alias is a
forwarder method you write and keep in sync. With it, the alias is part of
the declaration:

```raku name="aliases"
use Method::Also;

class Queue {
    has @!items;
    method push($x) is also<enqueue add> { @!items.push($x); self }
    method shift() is also<dequeue> { @!items.shift }
    method elems() is also<Numeric> { @!items.elems }
}

my $q = Queue.new;
$q.enqueue('a');
$q.add('b');
$q.push('c');
say $q.dequeue;
say $q.elems;
say $q + 0;
```

```output
a
2
2
```

Every name in the angle brackets is a real method on the class — same
body, same object, shown by the last line: aliasing `elems` to `Numeric`
is all it takes for a `Queue` to numify, because `+ 0` makes Raku call
`.Numeric`. That trick — pointing a protocol name at a method you already
have — is the quiet superpower here: `Str`, `Bool`, `Numeric`, `gist` are
all just method names something else agrees to call.

## It composes with multis and coercions

The trait goes per candidate, so one spelling of a `multi` can carry the
alias while its siblings stay single-named — and aliasing `gist` to `Str`
makes stringification and `say` agree with one body:

```raku name="multi-and-gist"
use Method::Also;

class Temperature {
    has $.celsius;
    multi method in(Str $unit where 'C') is also<as> { $!celsius }
    multi method in(Str $unit where 'F') { $!celsius * 9/5 + 32 }
    method gist() is also<Str> { "{$!celsius}°C" }
}

my $t = Temperature.new(:celsius(21));
say $t.in('F');
say $t.as('C');
say ~$t;
```

```output
69.8
21
21°C
```

Note what `is also` on a `multi` candidate means: `as` is an alias for the
whole dispatch under that name — but only candidates declared with the
trait travel; here `.as('F')` would not dispatch, which is the behaviour
you asked for by aliasing one candidate.

Keep the trait on **class** methods. Aliasing methods in roles is where
the module's own documentation waves a flag, and this page's testing
agrees — see below.

## Where the two engines differ

Aliases declared in a **role** with several names behave differently:
composing the role above as written works fully under Raku++, while under
Rakudo some of the alias names fail to appear on the composing class
(`.count is also<elems size length>` in a role yielded a working `elems`
and a missing `size` under Rakudo 2026.08). This is upstream-acknowledged
territory rather than a Raku++ gap — the module registers aliases through
compiler internals that treat role specialization differently — but the
portable rule is simple: alias in classes, and everything on this page
holds on both engines.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install Method::Also`; it depends on nothing
   outside the core.
3. **Test** — the distribution's own suite: 1 file, green.
4. **Run** — every example on this page, twice under each engine, as the
   site is built.

This module is worth a pause: it works by adding methods through the
metaobject protocol at composition time, so its suite going green is a
statement about Raku++'s MOP — `add_method` on a `ClassHOW`, trait
handlers running at compile time, and `is hidden-from-backtrace` all
behaving — not about string handling in some `also` helper. Twenty-one
distributions depend on it, `lizmat`'s own among them.
