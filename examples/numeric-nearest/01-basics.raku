#!/usr/bin/env rakupp
# Numeric::Nearest — Finding
# https://raku.online/modules/numeric-nearest/#finding
#
# Install what it needs, then run it:
#     rakupp install Numeric::Nearest
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Numeric::Nearest;

my @grid = 0, 10, 20, 30, 40, 50;
for -5, 4, 5, 14, 15, 99 -> $key {
    say sprintf('  key %3d -> %s', $key, nearestPair($key, @grid).raku);
}
say '';
say 'the result is an index => value Pair, and it clamps at both ends.';
say 'an exact tie goes to the HIGHER index:';
say '  nearestPair(5, (0, 10)) = ', nearestPair(5, (0, 10)).raku;
say '';
my $r = try nearestPair(1, ());
say '  an empty list -> ', $! ?? 'throws X::OutOfRange' !! $r.raku;

# Output:
#       key  -5 -> 0 => 0
#       key   4 -> 0 => 0
#       key   5 -> 1 => 10
#       key  14 -> 1 => 10
#       key  15 -> 2 => 20
#       key  99 -> 5 => 50
#     
#     the result is an index => value Pair, and it clamps at both ends.
#     an exact tie goes to the HIGHER index:
#       nearestPair(5, (0, 10)) = 1 => 10
#     
#       an empty list -> throws X::OutOfRange
