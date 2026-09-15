#!/usr/bin/env rakupp
# DateTime::Format::LikeGo — Formatting
# https://raku.online/modules/datetime-format-likego/#formatting
#
# Install what it needs, then run it:
#     rakupp install DateTime::Format::LikeGo
#     rakupp 01-format.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DateTime::Format::LikeGo;

my $dt = DateTime.new(2025, 3, 9, 15, 4, 5, :timezone(0));

for '2006-01-02',
    '2006-01-02 15:04:05',
    '01/02/06',
    '15:04',
    '02 Jan 2006',
    '_2 January 2006' -> $fmt {
    say sprintf('%-22s -> %s', $fmt, go-date-format($fmt, $dt));
}

# Output:
#     2006-01-02             -> 2025-03-09
#     2006-01-02 15:04:05    -> 2025-03-09 15:04:05
#     01/02/06               -> 03/09/25
#     15:04                  -> 15:04
#     02 Jan 2006            -> 09 Mar 2025
#     _2 January 2006        ->  9 March 2025
