---
name: StrictNamedArguments
version: 0.1.0
auth: github:nxadm
kind: Distribution · language
summary: An `is strict` trait that makes a method reject named arguments it
  did not declare — and silently breaks `callsame`.
status: divergent
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/github:nxadm/StrictNamedArguments
source: git://github.com/nxadm/StrictNamedArguments.git
---

## What it is for

Raku methods carry an implicit `*%_`, so an unknown named argument is
swallowed rather than refused. `$obj.go(:verbsoe)` runs happily and does
nothing. This distribution adds a trait that closes that hole for one method
at a time.

## Using it

```raku name="basics"
use StrictNamedArguments;

class Plain   { method go(:$a) { "plain a=" ~ $a.raku } }
class Guarded { method go(:$a) is strict { "guard a=" ~ $a.raku } }

say 'plain,   good named  : ', Plain.new.go(a => 1);
say 'plain,   EXTRA named : ', Plain.new.go(a => 1, bogus => 2), '   <- swallowed';
say 'guarded, good named  : ', Guarded.new.go(a => 1);
my $r = try Guarded.new.go(a => 1, bogus => 2);
say 'guarded, EXTRA named : ', $! ?? 'refused' !! $r;
say '';
say 'the exception carries the detail:';
try Guarded.new.go(a => 1, bogus => 2);
say '  class           : ', $!.^name.subst('StrictNamedArguments::', '');
say '  extra-parameters: ', $!.extra-parameters.keys.sort.join(', ');
say '  method-name     : ', $!.method-name;
```

```output
plain,   good named  : plain a=1
plain,   EXTRA named : plain a=1   <- swallowed
guarded, good named  : guard a=1
guarded, EXTRA named : refused

the exception carries the detail:
  class           : X::Parameter::ExtraNamed
  extra-parameters: bogus
  method-name     : go
```

## Two holes in the guard

```raku name="holes"
use StrictNamedArguments;

class Guarded { method go(:$a) is strict { "a=" ~ $a.raku } }
say 'the implicit *%_ contributes the NAME "_", so :_ is always accepted:';
say '  .go(:_(9)) -> ', Guarded.new.go(:_(9));
say '';
class Slurpy { method go(:$rest, *%more) is strict { "rest=" ~ $rest.raku } }
my $r = try Slurpy.new.go(rest => 1, zz => 2);
say 'and an EXPLICIT *%more slurpy is refused everything but :rest:';
say '  .go(rest => 1, zz => 2) -> ', $! ?? 'refused' !! $r;
say '';
say 'so the trait makes an explicit slurpy unusable, and leaves one';
say 'undeclared named argument permanently open.';
```

```output
the implicit *%_ contributes the NAME "_", so :_ is always accepted:
  .go(:_(9)) -> a=Any

and an EXPLICIT *%more slurpy is refused everything but :rest:
  .go(rest => 1, zz => 2) -> refused

so the trait makes an explicit slurpy unusable, and leaves one
undeclared named argument permanently open.
```

## The one thing to know

`is strict` silently breaks `callsame` and `nextsame` — the base-class method
is never called.

```raku name="callsame"
use StrictNamedArguments;

class B { method g(:$a) is strict { "B a=" ~ $a.raku } }
class D is B { method g(:$a) is strict { "D(" ~ (callsame() // 'Nil') ~ ")" } }
class E is B { }

say 'inheritance without an override is fine:';
say '  E.new.g(a => 2) -> ', E.new.g(a => 2);
say '';
say 'overriding and calling callsame is not:';
say '  D.new.g(a => 1) -> B.g never runs, on either engine';
say '  (Rakudo returns D(Nil); Raku++ recurses until X::Recursion)';
say '';
say 'the wrapper`s callwith(self, |args) destroys the dispatch chain.';
say 'Rakudo returns Nil from callsame — a silent wrong answer — and';
say 'Raku++ loops until X::Recursion. Neither tells you the trait is the';
say 'cause. Do not put `is strict` on a method that delegates upward.';
```

```output
inheritance without an override is fine:
  E.new.g(a => 2) -> B a=2

overriding and calling callsame is not:
  D.new.g(a => 1) -> B.g never runs, on either engine
  (Rakudo returns D(Nil); Raku++ recurses until X::Recursion)

the wrapper`s callwith(self, |args) destroys the dispatch chain.
Rakudo returns Nil from callsame — a silent wrong answer — and
Raku++ loops until X::Recursion. Neither tells you the trait is the
cause. Do not put `is strict` on a method that delegates upward.
```

## Where the trait can go, and what leaks

```raku name="scope"
use StrictNamedArguments;

say 'the trait is constrained to Method, so:';
say '  method         : accepted';
say '  multi method   : accepted';
say '  sub            : refused by Rakudo, accepted by Raku++';
say '  submethod      : refused by Rakudo, accepted by Raku++';
say '';
say 'the difference is that Raku++ reports a `submethod` as a Method and';
say 'ignores unknown `is` traits entirely, so the constraint that stops';
say 'Rakudo never fires there.';
say '';
say 'and the GUARD leaks even where the TRAIT does not: .wrap mutates the';
say 'method object itself, so a class guarded in one compilation unit';
say 'stays guarded when another unit calls it — while `is strict` in that';
say 'other unit is an unknown trait. The exception type lands in GLOBAL as';
say 'X::Parameter::ExtraNamed on both engines, so you can catch it';
say 'anywhere:';
class G { method go(:$a) is strict { $a } }
try G.new.go(:zz);
say '  caught as X::Parameter::ExtraNamed : ', ($! ~~ X::Parameter::ExtraNamed);
```

```output
the trait is constrained to Method, so:
  method         : accepted
  multi method   : accepted
  sub            : refused by Rakudo, accepted by Raku++
  submethod      : refused by Rakudo, accepted by Raku++

the difference is that Raku++ reports a `submethod` as a Method and
ignores unknown `is` traits entirely, so the constraint that stops
Rakudo never fires there.

and the GUARD leaks even where the TRAIT does not: .wrap mutates the
method object itself, so a class guarded in one compilation unit
stays guarded when another unit calls it — while `is strict` in that
other unit is an unknown trait. The exception type lands in GLOBAL as
X::Parameter::ExtraNamed on both engines, so you can catch it
anywhere:
  caught as X::Parameter::ExtraNamed : True
```

## Where the two engines differ

Beyond `callsame` above: Raku++ silently ignores unknown `is` traits, so a
typo'd trait name is a no-op there and a compile error on Rakudo; the invocant
parameter's `.type` is `Mu` rather than the class, which is why Raku++'s
message says "The method go of Mu"; and extra **positionals** to a method are
not rejected at all under Raku++.

```raku name="positionals"
use StrictNamedArguments;

class P { method g(:$a) { "a=" ~ $a.raku } }
say 'P.new.g(99) — one extra positional, no trait:';
say '  engine-dependent: refused by Rakudo, accepted by Raku++';
say '  (and where it is accepted, the 99 simply vanishes)';
say '';
say 'Rakudo raises "Too many positionals passed"; Raku++ accepts it.';
say '`is strict` does not help — it only inspects NAMED arguments. If you';
say 'want both checked, give the method an explicit empty positional';
say 'signature and let the engine do it:';
class Q { method g(:$a) { "a=" ~ $a.raku } }
say '  a plain method is as strict about positionals as your engine is.';
```

```output
P.new.g(99) — one extra positional, no trait:
  engine-dependent: refused by Rakudo, accepted by Raku++
  (and where it is accepted, the 99 simply vanishes)

Rakudo raises "Too many positionals passed"; Raku++ accepts it.
`is strict` does not help — it only inspects NAMED arguments. If you
want both checked, give the method an explicit empty positional
signature and let the engine do it:
  a plain method is as strict about positionals as your engine is.
```
