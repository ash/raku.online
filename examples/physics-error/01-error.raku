#!/usr/bin/env rakupp
# Physics::Error — Holding an uncertainty
# https://raku.online/modules/physics-error/#holding-an-uncertainty
#
# Install what it needs, then run it:
#     rakupp install Physics::Error
#     rakupp 01-error.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Physics::Error;

my $abs = Error.new(:error(0.05));
$abs.bind-mea-value(9.81);

say 'an absolute 0.05 on a measured 9.81:';
say '  .absolute : ', $abs.absolute;
say '  .relative : ', $abs.relative.round(0.000001);
say '  .percent  : ', $abs.percent;
say '  .Str      : ', $abs.Str;
say '';
my $pct = Error.new(:error('2%'), :value(200));
$pct.bind-mea-value(200);
say "the same error stated as '2%' of 200:";
say '  .absolute : ', $pct.absolute;
say '  .relative : ', $pct.relative;
say '  .percent  : ', $pct.percent;

# Output:
#     an absolute 0.05 on a measured 9.81:
#       .absolute : 0.05
#       .relative : 0.005097
#       .percent  : 0.5%
#       .Str      : 0.05
#     
#     the same error stated as '2%' of 200:
#       .absolute : 4
#       .relative : 0.02
#       .percent  : 2%
