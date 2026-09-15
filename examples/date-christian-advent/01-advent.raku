#!/usr/bin/env rakupp
# Date::Christian::Advent — Finding Advent Sunday
# https://raku.online/modules/date-christian-advent/#finding-advent-sunday
#
# Install what it needs, then run it:
#     rakupp install Date::Christian::Advent
#     rakupp 01-advent.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Christian::Advent;

my %published =
    2000 => '2000-12-03', 2012 => '2012-12-02', 2016 => '2016-11-27',
    2020 => '2020-11-29', 2021 => '2021-11-28', 2022 => '2022-11-27',
    2023 => '2023-12-03', 2024 => '2024-12-01', 2025 => '2025-11-30',
    2026 => '2026-11-29';

for %published.keys.sort({ +$_ }) -> $y {
    my $a = Advent-Sunday(+$y);
    say sprintf('%s  %s  published=%s  %s   (30 Nov is a %s)',
        $y, $a.Str, %published{$y},
        $a.Str eq %published{$y} ?? 'match' !! 'DIFFERS',
        <Mon Tue Wed Thu Fri Sat Sun>[Date.new(+$y, 11, 30).day-of-week - 1]);
}

# Output:
#     2000  2000-12-03  published=2000-12-03  match   (30 Nov is a Thu)
#     2012  2012-12-02  published=2012-12-02  match   (30 Nov is a Fri)
#     2016  2016-11-27  published=2016-11-27  match   (30 Nov is a Wed)
#     2020  2020-11-29  published=2020-11-29  match   (30 Nov is a Mon)
#     2021  2021-11-28  published=2021-11-28  match   (30 Nov is a Tue)
#     2022  2022-11-27  published=2022-11-27  match   (30 Nov is a Wed)
#     2023  2023-12-03  published=2023-12-03  match   (30 Nov is a Thu)
#     2024  2024-12-01  published=2024-12-01  match   (30 Nov is a Sat)
#     2025  2025-11-30  published=2025-11-30  match   (30 Nov is a Sun)
#     2026  2026-11-29  published=2026-11-29  match   (30 Nov is a Mon)
