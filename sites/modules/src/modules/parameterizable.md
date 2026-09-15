---
name: Parameterizable
version: 0.0.3
auth: zef:dumarchie
kind: Distribution · metaprogramming
summary: Gives a class the `Foo[Bar]` subscript syntax by supplying a
  `^parameterize` metamethod that mixes in a role you choose.
status: divergent
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:dumarchie/Parameterizable
source: git://github.com/dumarchie/raku-parameterizable.git
---

## What it is for

`Array[Int]` and `Hash[Str]` read well, and the syntax is not reserved for the
core: any type can answer `[…]` if its metaclass defines `^parameterize`.
Writing that metamethod by hand means knowing the metamodel; this distribution
writes it for you.

You inherit from `Parameterizable` and supply a `MIXIN` method that returns a
role for the given arguments.

## Using it

```raku name="basics"
use Parameterizable;

role Typed[::T] {
    method of { T }
    method tag { 'TYPED' }
}
class Box is Parameterizable {
    has $.value;
    method MIXIN(::T) { Typed[T] }
}

say 'Box[Int].^name        : ', Box[Int].^name;
say 'Box[Int] ~~ Box       : ', (Box[Int] ~~ Box);
say 'Box[Int] === Box[Int] : ', (Box[Int] === Box[Int]);
say 'Box[Int] is Box ?     : ', (Box[Int] === Box);
say '';
say 'a value parameter works too:';
role Tag[$t] { method tag { "TAGGED-$t" } }
class C is Parameterizable {
    method MIXIN($t) { Tag[$t] }
}
say '  C[5].tag   : ', C[5].tag;
say '  C["s"].tag : ', C['s'].tag;
```

```output
Box[Int].^name        : Box[Int]
Box[Int] ~~ Box       : True
Box[Int] === Box[Int] : True
Box[Int] is Box ?     : False

a value parameter works too:
  C[5].tag   : TAGGED-5
  C["s"].tag : TAGGED-s
```

## The one thing to know

Failures are resolved at **compile time**, so `try` cannot catch them.

```raku name="compile-time"
use Parameterizable;

say 'Foo[Bar] in source is resolved during compilation, so the module`s';
say 'friendly die surfaces as ===SORRY!=== and no `try` helps:';
say '';
say '  class NoMixin is Parameterizable { }';
say '  try NoMixin[Int];        # still a compile error';
say '  -> "Can not parameterize NoMixin with Int"';
say '';
say 'called by hand at run time, the same failure IS catchable, and the';
say 'message is identical on both engines:';
role Typed[::T] { method of { T } }
class Box is Parameterizable { method MIXIN(::T) { Typed[T] } }
class NoMixin is Parameterizable { }

for Box, NoMixin -> $cls {
    my $r = try $cls.^parameterize(Int);
    say sprintf('  %-8s.^parameterize(Int) -> %s', $cls.^name,
                $! ?? $!.message !! $r.^name);
}
my $v = try Box.^parameterize(5);
say '  Box.^parameterize(5)      -> ', $! ?? $!.message !! $v.^name;
say '';
say 'so build your parameterised types through ^parameterize when you';
say 'need to handle failure, and reserve the [ ] syntax for types you';
say 'know are valid.';
```

```output
Foo[Bar] in source is resolved during compilation, so the module`s
friendly die surfaces as ===SORRY!=== and no `try` helps:

  class NoMixin is Parameterizable { }
  try NoMixin[Int];        # still a compile error
  -> "Can not parameterize NoMixin with Int"

called by hand at run time, the same failure IS catchable, and the
message is identical on both engines:
  Box     .^parameterize(Int) -> Box[Int]
  NoMixin .^parameterize(Int) -> Can not parameterize NoMixin with Int
  Box.^parameterize(5)      -> Box[Int]

so build your parameterised types through ^parameterize when you
need to handle failure, and reserve the [ ] syntax for types you
know are valid.
```

## The generated name loses value parameters

```raku name="names"
use Parameterizable;

role Cap[$n] { method limit { $n } }
class Capped is Parameterizable { method MIXIN($n) { Cap[$n] } }

say 'Capped[5].^name  : ', Capped[5].^name;
say 'Capped[7].^name  : ', Capped[7].^name;
say 'same name ?      : ', Capped[5].^name eq Capped[7].^name;
say 'same type ?      : ', (Capped[5] === Capped[7]);
say '';
say 'the name is built from @pos.map(*.^name), so every VALUE parameter';
say 'collapses to its type`s name. Two genuinely different types both';
say 'print as Capped[Int] — debug output, .gist and error messages cannot';
say 'tell them apart.';
say '';
say 'they are still distinct types, and their methods still answer:';
say '  Capped[5].limit : ', Capped[5].limit;
say '  Capped[7].limit : ', Capped[7].limit;
```

```output
Capped[5].^name  : Capped[Int]
Capped[7].^name  : Capped[Int]
same name ?      : True
same type ?      : False

the name is built from @pos.map(*.^name), so every VALUE parameter
collapses to its type`s name. Two genuinely different types both
print as Capped[Int] — debug output, .gist and error messages cannot
tell them apart.

they are still distinct types, and their methods still answer:
  Capped[5].limit : 5
  Capped[7].limit : 7
```

## Where the two engines differ

Under Raku++, `Foo[SomeType]` never reaches your `^parameterize` — a built-in
parameterisation path handles it, renaming the type and composing nothing. So
the module's headline use case is a silent no-op there: you get a type named
`Box[Int]` with none of the role's methods, and no error anywhere.

```raku name="portable"
use Parameterizable;

role Typed[::T] { method of { T }; method tag { 'TYPED' } }
class Box is Parameterizable { method MIXIN(::T) { Typed[T] } }

say 'the portable spelling is the metamethod, which routes correctly on';
say 'both engines:';
my $typed = Box.^parameterize(Int);
say '  Box.^parameterize(Int).^name : ', $typed.^name;
say '  .tag                          : ', $typed.tag;
say '  .of resolves the parameter    : engine-dependent — see below';
say '';
say 'the subscript form Box[Int] composes the role on Rakudo and does not';
say 'on Raku++. A VALUE parameter — Box[5] — routes correctly on both,';
say 'which is why the earlier examples use one.';
say '';
say 'so: if you are writing a library that must work on both engines,';
say 'expose a constructor rather than the subscript:';
say '  method of(::T) { self.^parameterize(T) }';
class Typed-Box is Parameterizable {
    method MIXIN(::T) { Typed[T] }
    method of-type(::T) { self.^parameterize(T) }
}
say '  Typed-Box.of-type(Str).tag : ', Typed-Box.of-type(Str).tag;
```

```output
the portable spelling is the metamethod, which routes correctly on
both engines:
  Box.^parameterize(Int).^name : Box[Int]
  .tag                          : TYPED
  .of resolves the parameter    : engine-dependent — see below

the subscript form Box[Int] composes the role on Rakudo and does not
on Raku++. A VALUE parameter — Box[5] — routes correctly on both,
which is why the earlier examples use one.

so: if you are writing a library that must work on both engines,
expose a constructor rather than the subscript:
  method of(::T) { self.^parameterize(T) }
  Typed-Box.of-type(Str).tag : TYPED
```

Two more differences to know about. An instance keeps the mixin under Rakudo
(`.^name` reports `Box[Int]`, and `.of` works on the instance) and does not
under Raku++. And a role's type capture read back through a method — the
`method of { T }` above — answers the bound type under Rakudo and the capture
name under Raku++, so store the parameter in an attribute if you need to read
it later.
