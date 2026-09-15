#!/usr/bin/env rakupp
# Data::Transformers — The one thing to know
# https://raku.online/modules/data-transformers/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Data::Transformers
#     rakupp 04-flat-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Transformers::Rescale;

my @flat = 5, 5, 5;           # a flat sensor reading: perfectly ordinary
my @out = |rescale(@flat);

say 'rescale of a constant series : ', @out.List.raku;
say '  type of the first element  : ', @out[0].^name;
say '  numerator/denominator      : ', @out[0].numerator, '/', @out[0].denominator;
say '  is it NaN                  : ', @out[0].Num.isNaN;
say '';
say 'and the consequences:';
say '  [0] == [1]      : ', @out[0] == @out[1], '   — two identical values, unequal';
say '  the sum         : ', @out.sum.Num;
say '  compared to 0.5 : ', @out[0] > 0.5;

# Output:
#     rescale of a constant series : (<0/0>, <0/0>, <0/0>)
#       type of the first element  : Rat
#       numerator/denominator      : 0/0
#       is it NaN                  : True
#     
#     and the consequences:
#       [0] == [1]      : False   — two identical values, unequal
#       the sum         : NaN
#       compared to 0.5 : False
