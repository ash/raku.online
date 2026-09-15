#!/usr/bin/env rakupp
# Text::Chart — Where the two engines differ
# https://raku.online/modules/text-chart/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Text::Chart
#     rakupp 05-nonnumeric.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Chart;

my @mixed = 1, 'x', 2;
say 'raw data          : ', @mixed.raku;
say 'a chart of it is engine-dependent, so filter first:';
my @clean = @mixed.grep({ .Str ~~ /^ '-'? \d+ ['.' \d+]? $/ })>>.Numeric;
say '  numeric entries : ', @clean.raku;
print vertical(max => 2, |@clean);

# Output:
#     raw data          : [1, "x", 2]
#     a chart of it is engine-dependent, so filter first:
#       numeric entries : [1, 2]
#      █
#     ██
