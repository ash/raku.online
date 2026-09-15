#!/usr/bin/env rakupp
# Today — Using it
# https://raku.online/modules/today/#using-it
#
# Install what it needs, then run it:
#     rakupp install Today
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Today;

say 'today ~~ Date            : ', today ~~ Date;
say 'today == Date.today      : ', today == Date.today;
say 'today.^name              : ', today.^name;
say 'yesterday                : ', (today - 1) == Date.today.earlier(:1day);
say 'a week out               : ', (today.later(:7days) - today) == 7;
say 'two reads agree          : ', today == today;
say '';
say 'it reads like a literal, which is the point:';
say '  days left in the month : ',
    today.later(:1month).truncated-to('month') - today;

# Output:
#     today ~~ Date            : True
#     today == Date.today      : True
#     today.^name              : Date
#     yesterday                : True
#     a week out               : True
#     two reads agree          : True
#     
#     it reads like a literal, which is the point:
#       days left in the month : 16
