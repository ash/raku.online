#!/usr/bin/env rakupp
# Date::Event — An event
# https://raku.online/modules/date-event/#an-event
#
# Install what it needs, then run it:
#     rakupp install Date::Event
#     rakupp 01-event.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Event;

my $labor-day = Date::Event.new(
    :set-id('us-federal'),
    :id('labor-day'),
    :name('Labor Day'),
    :short-name('Labor'),
    :Etype(EType::Holiday),
    :date(Date.new('2026-09-07')),
    :date-observed(Date.new('2026-09-07')),
    :notes('first Monday in September'),
    :is-calculated(True),
);

say $labor-day.name, ' / ', $labor-day.short-name;
say $labor-day.set-id, ' ', $labor-day.id;
say $labor-day.Etype, ' = ', $labor-day.Etype.value;
say $labor-day.date, ' observed ', $labor-day.date-observed;
say $labor-day.is-calculated;
say EType.enums.sort(*.value).map(*.key).join(' ');

# Output:
#     Labor Day / Labor
#     us-federal labor-day
#     Holiday = 100
#     2026-09-07 observed 2026-09-07
#     True
#     Unknown Birth Christening Baptism BarMitzvah BatMitzvah Graduation Wedding Anniversary Retirement Death Birthday Liturgy Holiday Astro Other
