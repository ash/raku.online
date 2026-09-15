#!/usr/bin/env rakupp
# JSON::Pretty::Sorted — The one thing to know
# https://raku.online/modules/json-pretty-sorted/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install JSON::Pretty::Sorted
#     rakupp 04-sorter-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Pretty::Sorted;

my %data = zebra => 1, apple => 2, mango => 3;
say 'with no sorter, the default is { 0 } — a constant key,';
say 'so .sort is stable and simply preserves hash order.';
say '';
say 'and a key sorter reaches ARRAY elements too:';
my $r = try to-json({ b => [3, 1, 2], a => 'x' }, sorter => { $^x.key cmp $^y.key });
say '  ', $! ?? 'threw ' ~ $!.^name !! 'worked';
say '';
say 'the sorter has to handle both Pairs and bare elements:';
my &safe = { ($^x ~~ Pair ?? $x.key !! $x) cmp ($^y ~~ Pair ?? $y.key !! $y) };
say to-json({ b => [3, 1, 2], a => 'x' }, sorter => &safe);

# Output:
#     with no sorter, the default is { 0 } — a constant key,
#     so .sort is stable and simply preserves hash order.
#     
#     and a key sorter reaches ARRAY elements too:
#       threw X::Method::NotFound
#     
#     the sorter has to handle both Pairs and bare elements:
#     {
#       "a" : "x",
#       "b" : [
#         1,
#         2,
#         3
#       ]
#     }
