#!/usr/bin/env rakupp
# Date::Calendar::MayaAztec — Where the two engines differ
# https://raku.online/modules/date-calendar-mayaaztec/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::MayaAztec
#     rakupp 05-floor.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Maya;

my $zero = Date::Calendar::Maya.new(long-count => '0.0.0.0.0');
say 'long count zero : ', $zero.to-date, '  (MJD ', $zero.daycount, ')';
say 'one day later   : ',
    Date::Calendar::Maya.new-from-daycount($zero.daycount + 1).long-count;
my $r = try Date::Calendar::Maya.new-from-daycount($zero.daycount - 1);
say 'one day EARLIER : ', $! ?? 'refused' !! $r.long-count;
say '';
say 'Raku++ raises a where-constraint failure on $!kin; Rakudo fails to bind';
say '$baktun at all. The cause is Int.polymod on a negative invocant, which';
say 'Raku++ answers with negative components and Rakudo refuses outright.';

# Output:
#     long count zero : -3113-08-11  (MJD -1815718)
#     one day later   : 0.0.0.0.1
#     one day EARLIER : refused
#     
#     Raku++ raises a where-constraint failure on $!kin; Rakudo fails to bind
#     $baktun at all. The cause is Int.polymod on a negative invocant, which
#     Raku++ answers with negative components and Rakudo refuses outright.
