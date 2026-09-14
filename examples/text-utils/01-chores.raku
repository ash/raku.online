#!/usr/bin/env rakupp
# Text::Utils — The chores
# https://raku.online/modules/text-utils/#the-chores
#
# Install what it needs, then run it:
#     rakupp install Text::Utils
#     rakupp 01-chores.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Utils :ALL;

say commify(1234567);
say commify(1234567.891, :decimals(2));
say normalize-string("  a   b\t\tc  \n d ");
say normalize-string("a\t\tb  c", :c<s>).raku;
say list2text(<apples pears plums>);
say list2text(<apples pears plums>, :!optional-comma);
say count-substrs('banana', 'an');
say strip-comment('x = 1 # set x', :normalize).raku;
say strip-comment('x = 1 # set x', :save-comment).raku;

# Output:
#     1,234,567
#     1,234,567.89
#     a b c d
#     "a b c"
#     apples, pears, and plums
#     apples, pears and plums
#     2
#     "x = 1"
#     ("x = 1 ", "# set x")
