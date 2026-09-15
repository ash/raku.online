#!/usr/bin/env rakupp
# Math::Random — The one thing to know
# https://raku.online/modules/math-random/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Math::Random
#     rakupp 02-javastyle.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::Random::JavaStyle;

my $j = Math::Random::JavaStyle.bless;
$j.setSeed(12345);
my @bits = (^2000).map({ $j.nextBoolean });
say 'true: ', +@bits.grep(*.so), '  false: ', +@bits.grep(!*.so);

my $k = Math::Random::JavaStyle.bless;
$k.setSeed(7);
say 'nxt(1) draws: ', (^6).map({ $k.nxt(1) }).join(', ');
say 'should all be 0 or 1';

say (try Math::Random::JavaStyle.new(42)) // 'new(42): refused';

# Output:
#     true: 2000  false: 0
#     nxt(1) draws: 131073, 131073, 131073, 131072, 131072, 131072
#     should all be 0 or 1
#     new(42): refused
