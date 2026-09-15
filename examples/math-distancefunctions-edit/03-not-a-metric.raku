#!/usr/bin/env rakupp
# Math::DistanceFunctions::Edit — The one thing to know
# https://raku.online/modules/math-distancefunctions-edit/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Math::DistanceFunctions::Edit
#     rakupp 03-not-a-metric.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::DistanceFunctions::Edit;

my $direct = edit-distance('ca', 'abc');
my $via    = edit-distance('ca', 'ac') + edit-distance('ac', 'abc');
say $direct;
say $via;
say $direct <= $via;

# Output:
#     3
#     2
#     False
