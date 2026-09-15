#!/usr/bin/env rakupp
# Timezones::US — The one thing to know
# https://raku.online/modules/timezones-us/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Timezones::US
#     rakupp 04-minute.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Timezones::US;

my $t = DateTime.new(2025, 11, 2, 2, 1, 0);
say 'instant                      : ', $t;
say '  is-dst(localtime => $t)     : ', is-dst(localtime => $t);
say '  is-dst(:year …, :minute(1)) : ',
    is-dst(year => 2025, month => 11, day => 2, hour => 2, minute => 1);
say '';
say ':second IS forwarded, which is what makes this hard to spot —';
my $s = DateTime.new(2025, 11, 2, 2, 0, 1);
say '  is-dst(localtime => $s)     : ', is-dst(localtime => $s);
say '  is-dst(:year …, :second(1)) : ',
    is-dst(year => 2025, month => 11, day => 2, hour => 2, second => 1);

# Output:
#     instant                      : 2025-11-02T02:01:00Z
#       is-dst(localtime => $t)     : False
#       is-dst(:year …, :minute(1)) : True
#     
#     :second IS forwarded, which is what makes this hard to spot —
#       is-dst(localtime => $s)     : False
#       is-dst(:year …, :second(1)) : False
