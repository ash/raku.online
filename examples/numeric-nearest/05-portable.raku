#!/usr/bin/env rakupp
# Numeric::Nearest — Where the two engines differ
# https://raku.online/modules/numeric-nearest/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Numeric::Nearest
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Numeric::Nearest;

# the wrapper worth having
sub nearest($key, @sorted) {
    die 'nearest: empty list' unless @sorted;
    nearestPair($key, @sorted)
}
sub nearest-all(@keys, @sorted) {
    @keys.map({ nearest($_, @sorted) })
}

my @grid = 0, 10, 20;
say 'nearest-all over a 3-element grid : ',
    nearest-all((5, 15, 99), @grid).map(*.raku).join('  ');
my $r = try nearest(1, ());
say 'nearest(1, ())                    : ', $! ?? $!.message !! $r.raku;
say '';
say 'that avoids both the small-list crash and the empty-list wording,';
say 'and costs one .map.';

# Output:
#     nearest-all over a 3-element grid : 1 => 10  2 => 20  2 => 20
#     nearest(1, ())                    : nearest: empty list
#     
#     that avoids both the small-list crash and the empty-list wording,
#     and costs one .map.
