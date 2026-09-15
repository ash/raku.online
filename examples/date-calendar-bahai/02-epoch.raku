#!/usr/bin/env rakupp
# Date::Calendar::Bahai — The epoch
# https://raku.online/modules/date-calendar-bahai/#the-epoch
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::Bahai
#     rakupp 02-epoch.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Bahai;

for '1844-03-21', '1900-01-01', '2000-01-01' -> $d {
    my $b = Date::Calendar::Bahai.new-from-date(Date.new($d));
    say sprintf('%s -> %s   back=%s exact=%s',
        $d, $b.gist, $b.to-date, $b.to-date == Date.new($d));
}
say '';
my $r = try Date::Calendar::Bahai.new-from-date(Date.new('1844-03-20'));
say 'the day before the epoch : ', $! ?? 'refused' !! 'accepted';

# Output:
#     1844-03-21 -> 0001-01-01   back=1844-03-21 exact=True
#     1900-01-01 -> 0056-16-02   back=1900-01-01 exact=True
#     2000-01-01 -> 0156-16-02   back=2000-01-01 exact=True
#     
#     the day before the epoch : refused
