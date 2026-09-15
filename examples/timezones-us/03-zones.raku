#!/usr/bin/env rakupp
# Timezones::US — The zone tables
# https://raku.online/modules/timezones-us/#the-zone-tables
#
# Install what it needs, then run it:
#     rakupp install Timezones::US
#     rakupp 03-zones.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Timezones::US;

say 'zones : ', @tz.elems;
for @tz -> $z {
    say sprintf('  %-6s %+3d  %s', $z, %utc-offsets{$z}, %tzones{$z}<name>);
}
say '';
say 'DST exceptions the module knows about: ', %dst-exceptions.keys.sort.join(', ');

# Output:
#     zones : 9
#       ast     -4  Atlantic
#       est     -5  Eastern
#       cst     -6  Central
#       mst     -7  Mountain
#       pst     -8  Pacific
#       akst    -9  Alaska
#       hast   -10  Hawaii-Aleutian
#       wst    -11  Samoa
#       chst   +10  Chamorro
#     
#     DST exceptions the module knows about: mst
