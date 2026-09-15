#!/usr/bin/env rakupp
# Sort::Naturally — The two transforms are not interchangeable
# https://raku.online/modules/sort-naturally/#the-two-transforms-are-not-interchangeable
#
# Install what it needs, then run it:
#     rakupp install Sort::Naturally
#     rakupp 04-p5.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Sort::Naturally;

my @mixed = <ab a10 az a1 aa a9z b2 b>;
say 'plain .sort  : ', @mixed.sort.join(' ');
say 'naturally    : ', @mixed.sort({ .&naturally }).join(' ');
say 'p5naturally  : ', @mixed.sort({ .&p5naturally }).join(' ');
say '';
say 'naturally puts digits BEFORE letters; p5naturally puts them after,';
say 'because its key prefix for a non-leading run is "z{". Swapping one';
say 'for the other silently reorders your output.';
say '';
say 'both are total orders, with case as a tiebreak:';
say '  ', <b A a B aA Aa>.sort({ .&naturally }).join(' ');

# Output:
#     plain .sort  : a1 a10 a9z aa ab az b b2
#     naturally    : a1 a9z a10 aa ab az b b2
#     p5naturally  : aa ab az a1 a9z a10 b b2
#     
#     naturally puts digits BEFORE letters; p5naturally puts them after,
#     because its key prefix for a non-leading run is "z{". Swapping one
#     for the other silently reorders your output.
#     
#     both are total orders, with case as a tiebreak:
#       A a Aa aA B b
