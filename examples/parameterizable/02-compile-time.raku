#!/usr/bin/env rakupp
# Parameterizable — The one thing to know
# https://raku.online/modules/parameterizable/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Parameterizable
#     rakupp 02-compile-time.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     Foo[Bar] in source is resolved during compilation, so the module`s
#     friendly die surfaces as ===SORRY!=== and no `try` helps:
#     
#       class NoMixin is Parameterizable { }
#       try NoMixin[Int];        # still a compile error
#       -> "Can not parameterize NoMixin with Int"
#     
#     called by hand at run time, the same failure IS catchable, and the
#     message is identical on both engines:
#       Box     .^parameterize(Int) -> Box[Int]
#       NoMixin .^parameterize(Int) -> Can not parameterize NoMixin with Int
#       Box.^parameterize(5)      -> Box[Int]
#     
#     so build your parameterised types through ^parameterize when you
#     need to handle failure, and reserve the [ ] syntax for types you
#     know are valid.
