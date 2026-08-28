#!/usr/bin/env rakupp
# DateTime::Format — What it is for
# https://raku.online/modules/datetime-format/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install DateTime::Format
#     rakupp 01-strftime.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DateTime::Format;

my $dt = DateTime.new('2026-08-28T14:30:00+02:00');
say strftime('%Y-%m-%d %H:%M', $dt);
say strftime('%A, %B %d', $dt);
say strftime('%a %d %b %Y %T %z', $dt);

# Output:
#     2026-08-28 14:30
#     Friday, August 28
#     Fri 28 Aug 2026 14:30:00 +0200
