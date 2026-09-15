#!/usr/bin/env rakupp
# LCS::All — The one thing to know
# https://raku.online/modules/lcs-all/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install LCS::All
#     rakupp 03-depth-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use LCS::All;

my @disjoint = allLCS([<a b>], [<c d>]);

say 'allLCS on two disjoint sequences:';
say '  the whole return value : ', @disjoint.raku;
say '  .elems                 : ', @disjoint.elems;
say '  is it true?            : ', ?@disjoint;
say '';
say 'the genuinely empty thing is three subscripts down:';
say '  [0].elems     : ', @disjoint[0].elems;
say '  [0][0].elems  : ', @disjoint[0][0].elems;
say '';
say 'so this test is always true and tells you nothing:';
say '  if allLCS(...) { ... }   ->  ', ?allLCS([<a b>], [<c d>]);
say 'and this is the one that works:';
say '  allLCS(...)[0][0].elems  ->  ', allLCS([<a b>], [<c d>])[0][0].elems;

# Output:
#     allLCS on two disjoint sequences:
#       the whole return value : [[[],],]
#       .elems                 : 1
#       is it true?            : True
#     
#     the genuinely empty thing is three subscripts down:
#       [0].elems     : 1
#       [0][0].elems  : 0
#     
#     so this test is always true and tells you nothing:
#       if allLCS(...) { ... }   ->  True
#     and this is the one that works:
#       allLCS(...)[0][0].elems  ->  1
