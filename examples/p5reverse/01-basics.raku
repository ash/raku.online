#!/usr/bin/env rakupp
# P5reverse — Using it
# https://raku.online/modules/p5reverse/#using-it
#
# Install what it needs, then run it:
#     rakupp install P5reverse
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5reverse;

say 'a Str  : ', reverse('abc').raku;
say 'a List : ', reverse(('a', 'b', 'c')).raku;
say 'an Array : ', reverse([1, 2, 3]).raku;
my $none = try reverse();
say 'nothing  : ', $! ?? 'refused' !! $none.raku;
say '';
say 'three candidates, by type:';
say '  ()                       -> Nil';
say '  (List:D  --> List:D)     -> the list, reversed';
say '  (Str(Any) --> Str:D)     -> the string, reversed';

# Output:
#     a Str  : "cba"
#     a List : ("c", "b", "a")
#     an Array : (3, 2, 1)
#     nothing  : refused
#     
#     three candidates, by type:
#       ()                       -> Nil
#       (List:D  --> List:D)     -> the list, reversed
#       (Str(Any) --> Str:D)     -> the string, reversed
