#!/usr/bin/env rakupp
# Date::Event — The one thing to know
# https://raku.online/modules/date-event/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Date::Event
#     rakupp 02-gid-order.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Event;

my $gid = Date::Event.make-gid(:set-id('us-federal'), :id('labor-day'));
say $gid;
say $gid.split('|').join(' then ');

# Output:
#     labor-day|us-federal
#     labor-day then us-federal
