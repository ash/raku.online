#!/usr/bin/env rakupp
# Date::Calendar::Hijri — The epoch
# https://raku.online/modules/date-calendar-hijri/#the-epoch
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::Hijri
#     rakupp 02-epoch.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Hijri;

for '0622-07-19', '0700-01-01', '1900-01-01' -> $d {
    my $h = Date::Calendar::Hijri.new-from-date(Date.new($d));
    say sprintf('%s -> %s   back=%s exact=%s',
        $d, $h.gist, $h.to-date, $h.to-date == Date.new($d));
}
say '';
say 'earlier than that is refused:';
my $r = try Date::Calendar::Hijri.new-from-date(Date.new('0622-07-18'));
say '  0622-07-18 : ', $! ?? 'refused' !! 'accepted';

# Output:
#     0622-07-19 -> 0001-01-01   back=0622-07-19 exact=True
#     0700-01-01 -> 0080-11-01   back=0700-01-01 exact=True
#     1900-01-01 -> 1317-08-28   back=1900-01-01 exact=True
#     
#     earlier than that is refused:
#       0622-07-18 : refused
