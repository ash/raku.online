#!/usr/bin/env rakupp
# Math::Polynomial::Chebyshev — `:method<trig>` costs the exactness
# https://raku.online/modules/math-polynomial-chebyshev/#method-costs-the-exactness
#
# Install what it needs, then run it:
#     rakupp install Math::Polynomial::Chebyshev
#     rakupp 04-trig.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::Polynomial::Chebyshev;

say 'the recursion is exact where it can be:';
say '  chebyshev-t(3, 2)                 = ', chebyshev-t(3, 2);
say '  chebyshev-t(3, 2, :method<trig>)  = ', chebyshev-t(3, 2, :method<trig>);
say '';
say 'the trigonometric identity is a float path, so you pay accuracy for';
say 'nothing. It is also T-only:';
my $r = try chebyshev-u(3, 0.5, :method<trig>);
say '  chebyshev-u(…, :method<trig>) -> ', $! ?? $!.message !! $r;
say '';
say 'an unrecognised method is a clean die, as is a non-numeric argument:';
for :method<bogus>, :method<rec> -> $m {
    my $v = try chebyshev-t(3, 0.5, |$m);
    say sprintf('  %-18s -> %s', $m.raku, $! ?? 'refused' !! $v);
}

# Output:
#     the recursion is exact where it can be:
#       chebyshev-t(3, 2)                 = 26
#       chebyshev-t(3, 2, :method<trig>)  = 25.99999999999999
#     
#     the trigonometric identity is a float path, so you pay accuracy for
#     nothing. It is also T-only:
#       chebyshev-u(…, :method<trig>) -> Trigonometric method is implemented only for Chebyshev T (first kind) polynomials.
#     
#     an unrecognised method is a clean die, as is a non-numeric argument:
#       :method("bogus")   -> refused
#       :method("rec")     -> -1
