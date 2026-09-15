#!/usr/bin/env rakupp
# Date::Easter — The moveable feasts
# https://raku.online/modules/date-easter/#the-moveable-feasts
#
# Install what it needs, then run it:
#     rakupp install Date::Easter
#     rakupp 03-feasts.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Easter;

my $h := get-easter-events-hashlist(:year(2025));

say 'return type : ', $h.^name;
say 'keyed by    : ', $h.keyof.^name;
say '';
for $h.keys.sort -> $d {
    for $h{$d}.list -> $e {
        say sprintf('%s  %-14s %s', $d, $e.short-name, $e.name);
    }
}

# Output:
#     return type : Hash[Array,Date]
#     keyed by    : Date
#     
#     2025-03-05  Ash Wed.       Ash Wednesday
#     2025-04-13  Palm Sun.      Palm Sunday
#     2025-04-18  Good Fri.      Good Friday
#     2025-04-20  Easter         Easter Sunday
#     2025-05-30  Ascension D.   Ascension Day
#     2025-06-09  Pentecost      Pentecost
