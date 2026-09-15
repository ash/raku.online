#!/usr/bin/env rakupp
# List::Allmax — Where the two engines differ
# https://raku.online/modules/list-allmax/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install List::Allmax
#     rakupp 05-lazy.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use List::Allmax;

say 'Rakudo refuses a lazy list outright:';
say '  all-max(1..Inf)  ->  X::Cannot::Lazy, "Cannot all-max a lazy list"';
say '';
say 'Raku++ materialises it and answers from whatever it happened to';
say 'collect — 10000 elements for a Range, 64 for an infinite gather, and';
say 'ZERO for an infinite .map, which comes back as an empty Array.';
say '';
say 'three different silent truncations, none of them an error.';
say '';
say 'bound the source yourself before you hand it over:';
say '  all-max((1..Inf).head(1000))          = ', all-max((1..Inf).head(1000)).raku;
say '  all-max((1..Inf).map(* * 2).head(10)) = ', all-max((1..Inf).map(* * 2).head(10)).raku;
say '';
say 'a finite list behaves identically on both engines, which is every';
say 'other example on this page.';

# Output:
#     Rakudo refuses a lazy list outright:
#       all-max(1..Inf)  ->  X::Cannot::Lazy, "Cannot all-max a lazy list"
#     
#     Raku++ materialises it and answers from whatever it happened to
#     collect — 10000 elements for a Range, 64 for an infinite gather, and
#     ZERO for an infinite .map, which comes back as an empty Array.
#     
#     three different silent truncations, none of them an error.
#     
#     bound the source yourself before you hand it over:
#       all-max((1..Inf).head(1000))          = [1000]
#       all-max((1..Inf).map(* * 2).head(10)) = [20]
#     
#     a finite list behaves identically on both engines, which is every
#     other example on this page.
