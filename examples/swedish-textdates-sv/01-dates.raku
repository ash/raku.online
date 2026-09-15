#!/usr/bin/env rakupp
# Swedish::TextDates_sv — Spelling a date out
# https://raku.online/modules/swedish-textdates-sv/#spelling-a-date-out
#
# Install what it needs, then run it:
#     rakupp install Swedish::TextDates_sv
#     rakupp 01-dates.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Swedish::TextDates_sv;

for '2017-07-12', '2020-02-29', '2024-12-01', '2017-1-2' -> $d {
    my $w = Whole-Date-Names_sv.new(whole_date => $d);
    say sprintf('%-12s fancy: %-28s formal: %s',
                $d, $w.fancy-date.join(' '), $w.formal-date.join(' '));
}
say '';
say 'single-digit fields are accepted, so the format is looser than';
say 'yyyy-mm-dd suggests.';

# Output:
#     2017-07-12   fancy: tolfte juli 2017             formal: 12 juli 2017
#     2020-02-29   fancy: tjugonionde februari 2020    formal: 29 feb 2020
#     2024-12-01   fancy: första december 2024         formal: 1 dec 2024
#     2017-1-2     fancy: andra januari 2017           formal: 2 jan 2017
#     
#     single-digit fields are accepted, so the format is looser than
#     yyyy-mm-dd suggests.
