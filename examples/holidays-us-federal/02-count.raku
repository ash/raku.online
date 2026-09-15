#!/usr/bin/env rakupp
# Holidays::US::Federal — Counting the shifts
# https://raku.online/modules/holidays-us-federal/#counting-the-shifts
#
# Install what it needs, then run it:
#     rakupp install Holidays::US::Federal
#     rakupp 02-count.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Holidays::US::Federal;

for 2021, 2024, 2026 -> $y {
    my %h = get-fedholidays(:year($y), :set-id('X'));
    my @shifted = %h.keys.grep({
        %h{$_}.values[0].date ne %h{$_}.values[0].date-observed
    });
    say sprintf('%d : %2d holidays, %d observed on a different day',
        $y, %h.elems, @shifted.elems);
}

# Output:
#     2021 : 11 holidays, 3 observed on a different day
#     2024 : 11 holidays, 0 observed on a different day
#     2026 : 11 holidays, 1 observed on a different day
