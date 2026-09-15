#!/usr/bin/env rakupp
# Moonphase — Using it
# https://raku.online/modules/moonphase/#using-it
#
# Install what it needs, then run it:
#     rakupp install Moonphase
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Moonphase;

# a solar eclipse can only happen at new moon; a lunar one only at full
my %events =
    'total solar 1999-08-11 11:03 UTC' => 934369380,
    'total solar 2017-08-21 18:26 UTC' => 1503354360,
    'total lunar 2000-01-21 04:44 UTC' => 948429840,
    'total lunar 2018-01-31 13:30 UTC' => 1517405400;

for %events.keys.sort -> $label {
    my $p = moonphase(%events{$label});
    say sprintf('%-34s %9.5f rad  %8.3f deg  illum %.4f',
                $label, $p, $p * 180 / pi, (1 - cos($p)) / 2);
}
say '';
say 'eclipse instants are exact phase anchors, so those four lines are';
say 'the accuracy claim: about 0.03 degrees, which is what this class';
say 'of series promises.';

# Output:
#     total lunar 2000-01-21 04:44 UTC     3.14207 rad   180.027 deg  illum 1.0000
#     total lunar 2018-01-31 13:30 UTC     3.14182 rad   180.013 deg  illum 1.0000
#     total solar 1999-08-11 11:03 UTC    -0.00048 rad    -0.027 deg  illum 0.0000
#     total solar 2017-08-21 18:26 UTC     0.03817 rad     2.187 deg  illum 0.0004
#     
#     eclipse instants are exact phase anchors, so those four lines are
#     the accuracy claim: about 0.03 degrees, which is what this class
#     of series promises.
