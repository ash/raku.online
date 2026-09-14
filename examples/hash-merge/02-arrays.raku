#!/usr/bin/env rakupp
# Hash::Merge — Merging, and who wins
# https://raku.online/modules/hash-merge/#merging-and-who-wins
#
# Install what it needs, then run it:
#     rakupp install Hash::Merge
#     rakupp 02-arrays.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Hash::Merge;

my %a = tags => ['red', 'green'];
my %b = tags => ['blue'];

say merge-hash(%a, %b)<tags>.join(',');
say merge-hash(%a, %b, :!positional-append)<tags>.join(',');
say merge-hash(%a, %b, :!deep)<tags>.join(',');

# Output:
#     red,green,blue
#     blue
#     red,green,blue
