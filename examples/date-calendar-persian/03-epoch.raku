#!/usr/bin/env rakupp
# Date::Calendar::Persian — The epoch
# https://raku.online/modules/date-calendar-persian/#the-epoch
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::Persian
#     rakupp 03-epoch.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Persian;

for '0622-03-22', '1000-01-01', '2000-01-01' -> $d {
    my $p = Date::Calendar::Persian.new-from-date(Date.new($d));
    say sprintf('%s -> %s   back=%s exact=%s',
        $d, $p.gist, $p.to-date, $p.to-date == Date.new($d));
}
say '';
my $r = try Date::Calendar::Persian.new-from-date(Date.new('0500-01-01'));
say 'before the epoch : ', $! ?? 'refused' !! 'accepted';

# Output:
#     0622-03-22 -> 0001-01-01   back=0622-03-22 exact=True
#     1000-01-01 -> 0378-10-11   back=1000-01-01 exact=True
#     2000-01-01 -> 1378-10-11   back=2000-01-01 exact=True
#     
#     before the epoch : refused
