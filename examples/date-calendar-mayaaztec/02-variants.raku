#!/usr/bin/env rakupp
# Date::Calendar::MayaAztec — A day under every cycle
# https://raku.online/modules/date-calendar-mayaaztec/#a-day-under-every-cycle
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::MayaAztec
#     rakupp 02-variants.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Maya;
use Date::Calendar::Maya::Spinden;
use Date::Calendar::Maya::Astronomical;
use Date::Calendar::Aztec;
use Date::Calendar::Aztec::Cortes;

my $d = Date.new(2020, 6, 20);
for Date::Calendar::Maya, Date::Calendar::Maya::Spinden,
    Date::Calendar::Maya::Astronomical -> $cls {
    my $m = $cls.new-from-date($d);
    say sprintf('%-40s epoch %6d  %s', $cls.^name, $m.epoch, $m.long-count);
}
say '';
for Date::Calendar::Aztec, Date::Calendar::Aztec::Cortes -> $cls {
    my $a = $cls.new-from-date($d);
    say sprintf('%-40s %s', $cls.^name, $a.gist);
}

# Output:
#     Date::Calendar::Maya                     epoch 584283  13.0.7.10.18
#     Date::Calendar::Maya::Spinden            epoch 489384  13.13.11.3.17
#     Date::Calendar::Maya::Astronomical       epoch 584285  13.0.7.10.16
#     
#     Date::Calendar::Aztec                    20-13 12-18
#     Date::Calendar::Aztec::Cortes            3-14 2-1
