#!/usr/bin/env rakupp
# Numeric::Nearest — The one thing to know
# https://raku.online/modules/numeric-nearest/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Numeric::Nearest
#     rakupp 03-small.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Numeric::Nearest;

for 2, 3, 4, 5, 6 -> $n {
    my @grid = (^$n).map(* * 10);
    my $r = try nearestPairs((5, 15), @grid).map(*.raku).join(' ');
    say sprintf('  a %d-element list -> %s', $n, $! ?? 'DIES' !! $r);
}
say '';
say 'it threads the previous key`s index in as :start, and the search';
say 'loop is bounded by $list.elems iterations — one probe short once a';
say 'start hint has been consumed. The search then falls off the end';
say 'without assigning a result, and nearestPairs calls .key on it.';
say '';
say 'nearestPair on its own is correct for EVERY list length; only the';
say 'plural form is affected, and only below five elements — which is';
say 'exactly the size you reach for when writing a first test.';
say '';
say 'map the singular form yourself:';
my @grid = 0, 10, 20;
say '  ', (5, 15).map({ nearestPair($_, @grid) }).map(*.raku).join('  ');

# Output:
#       a 2-element list -> 1 => 10 1 => 10
#       a 3-element list -> DIES
#       a 4-element list -> 1 => 10 2 => 20
#       a 5-element list -> 1 => 10 2 => 20
#       a 6-element list -> 1 => 10 2 => 20
#     
#     it threads the previous key`s index in as :start, and the search
#     loop is bounded by $list.elems iterations — one probe short once a
#     start hint has been consumed. The search then falls off the end
#     without assigning a result, and nearestPairs calls .key on it.
#     
#     nearestPair on its own is correct for EVERY list length; only the
#     plural form is affected, and only below five elements — which is
#     exactly the size you reach for when writing a first test.
#     
#     map the singular form yourself:
#       1 => 10  2 => 20
