#!/usr/bin/env rakupp
# Parameterizable — Where the two engines differ
# https://raku.online/modules/parameterizable/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Parameterizable
#     rakupp 04-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     the portable spelling is the metamethod, which routes correctly on
#     both engines:
#       Box.^parameterize(Int).^name : Box[Int]
#       .tag                          : TYPED
#       .of resolves the parameter    : engine-dependent — see below
#     
#     the subscript form Box[Int] composes the role on Rakudo and does not
#     on Raku++. A VALUE parameter — Box[5] — routes correctly on both,
#     which is why the earlier examples use one.
#     
#     so: if you are writing a library that must work on both engines,
#     expose a constructor rather than the subscript:
#       method of(::T) { self.^parameterize(T) }
#       Typed-Box.of-type(Str).tag : TYPED
