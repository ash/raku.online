#!/usr/bin/env rakupp
# sublist — Using it
# https://raku.online/modules/sublist/#using-it
#
# Install what it needs, then run it:
#     rakupp install sublist
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use sublist;

say 'index   : ', sublist::index(<a b>, <x a b>).raku;
say 'indices : ', sublist::indices(<a b>, <x a b c a b>).List.raku;
say '';
say 'not present     : ', sublist::index(<z z>, <x a b>).raku;
say 'at offset 0     : ', sublist::index(<x a>, <x a b>).raku;
say 'needle longer   : ', sublist::index(<a b c>, <a b>).raku;
say 'overlapping     : ', sublist::indices(<a a>, <a a a>).List.raku;
say '';
say 'note the qualified spelling. Both subs are `our` with NO `is export`,';
say 'so `use sublist` brings in nothing — see below.';

# Output:
#     index   : 1
#     indices : (1, 4)
#     
#     not present     : Nil
#     at offset 0     : 0
#     needle longer   : Nil
#     overlapping     : (0, 1)
#     
#     note the qualified spelling. Both subs are `our` with NO `is export`,
#     so `use sublist` brings in nothing — see below.
