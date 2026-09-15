#!/usr/bin/env rakupp
# DateTime::Math — The operators
# https://raku.online/modules/datetime-math/#the-operators
#
# Install what it needs, then run it:
#     rakupp install DateTime::Math
#     rakupp 03-core-minus.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DateTime::Math;

my $a = DateTime.new(2024, 2, 28, 12, 0, 0, :timezone(0));
my $b = DateTime.new(2024, 3,  1, 12, 0, 0, :timezone(0));
my $d = $b - $a;
say 'DateTime - DateTime still works : ', $d, ' (a ', $d.^name, ')';

# Output:
#     DateTime - DateTime still works : 172800 (a Duration)
