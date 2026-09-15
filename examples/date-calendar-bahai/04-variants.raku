#!/usr/bin/env rakupp
# Date::Calendar::Bahai — Arithmetic against astronomical
# https://raku.online/modules/date-calendar-bahai/#arithmetic-against-astronomical
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::Bahai
#     rakupp 04-variants.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Bahai;
use Date::Calendar::Bahai::Astronomical;

for '2026-09-14', '2022-03-01', '2020-06-01' -> $d {
    my $g = Date.new($d);
    my $a = Date::Calendar::Bahai.new-from-date($g).gist;
    my $s = Date::Calendar::Bahai::Astronomical.new-from-date($g).gist;
    say sprintf('%s  arithmetic=%s  astronomical=%s  %s',
        $d, $a, $s, $a eq $s ?? 'agree' !! 'DIFFER');
}

# Output:
#     2026-09-14  arithmetic=0183-10-07  astronomical=0183-10-07  agree
#     2022-03-01  arithmetic=0178-19-04  astronomical=0178-19-05  DIFFER
#     2020-06-01  arithmetic=0177-04-16  astronomical=0177-04-17  DIFFER
