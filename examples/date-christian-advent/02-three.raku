#!/usr/bin/env rakupp
# Date::Christian::Advent — The three routines
# https://raku.online/modules/date-christian-advent/#the-three-routines
#
# Install what it needs, then run it:
#     rakupp install Date::Christian::Advent
#     rakupp 02-three.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Christian::Advent;

my @bad;
for 1583 .. 2500 -> $y {
    my ($a, $b, $c) = Advent-Sunday($y), Advent-Sunday2($y), Advent-Sunday3($y);
    @bad.push("$y: $a / $b / $c") unless $a == $b == $c;
}
say 'years scanned : ', 2500 - 1583 + 1;
say 'disagreements : ', @bad.elems;
say '';
say 'one year per weekday position of 30 November:';
my %done;
for 2000 .. 2050 -> $y {
    my $d = Date.new($y, 11, 30).day-of-week;
    next if %done{$d}++;
    say sprintf('  30 Nov is weekday %d  (%d) : %s  %s  %s',
        $d, $y, Advent-Sunday($y), Advent-Sunday2($y), Advent-Sunday3($y));
}

# Output:
#     years scanned : 918
#     disagreements : 0
#     
#     one year per weekday position of 30 November:
#       30 Nov is weekday 4  (2000) : 2000-12-03  2000-12-03  2000-12-03
#       30 Nov is weekday 5  (2001) : 2001-12-02  2001-12-02  2001-12-02
#       30 Nov is weekday 6  (2002) : 2002-12-01  2002-12-01  2002-12-01
#       30 Nov is weekday 7  (2003) : 2003-11-30  2003-11-30  2003-11-30
#       30 Nov is weekday 2  (2004) : 2004-11-28  2004-11-28  2004-11-28
#       30 Nov is weekday 3  (2005) : 2005-11-27  2005-11-27  2005-11-27
#       30 Nov is weekday 1  (2009) : 2009-11-29  2009-11-29  2009-11-29
