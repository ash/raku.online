#!/usr/bin/env rakupp
# P5reverse — Where the two engines differ
# https://raku.online/modules/p5reverse/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install P5reverse
#     rakupp 03-multi-arg.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5reverse;

say 'Perl`s `reverse $a, $b, $c` has no candidate here. Build the list:';
say '  reverse((1, 2, 3))          = ', reverse((1, 2, 3)).raku;
my @a = 1, 2;
my @b = 3, 4;
say '  reverse((|@a, |@b))         = ', reverse((|@a, |@b)).raku;
say '';
say 'the bare `reverse(1, 2, 3)` is "===SORRY!=== Calling reverse(Int,';
say 'Int, Int) will never work with any of these multi signatures" on';
say 'Rakudo, and a run-time dispatch failure on Raku++. Neither runs it.';
say '';
say 'core Raku`s own .reverse is the method form and takes no arguments';
say 'at all:';
say '  "abc".flip      = ', 'abc'.flip.raku, '   <- the Str one';
say '  (1, 2, 3).reverse = ', (1, 2, 3).reverse.raku, '  <- the List one';
say '';
say 'porting to those two is the end state; P5reverse is the step that';
say 'lets the rest of the file keep compiling in the meantime.';

# Output:
#     Perl`s `reverse $a, $b, $c` has no candidate here. Build the list:
#       reverse((1, 2, 3))          = (3, 2, 1)
#       reverse((|@a, |@b))         = (4, 3, 2, 1)
#     
#     the bare `reverse(1, 2, 3)` is "===SORRY!=== Calling reverse(Int,
#     Int, Int) will never work with any of these multi signatures" on
#     Rakudo, and a run-time dispatch failure on Raku++. Neither runs it.
#     
#     core Raku`s own .reverse is the method form and takes no arguments
#     at all:
#       "abc".flip      = "cba"   <- the Str one
#       (1, 2, 3).reverse = (3, 2, 1).Seq  <- the List one
#     
#     porting to those two is the end state; P5reverse is the step that
#     lets the rest of the file keep compiling in the meantime.
