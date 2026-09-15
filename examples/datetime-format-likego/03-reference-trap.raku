#!/usr/bin/env rakupp
# DateTime::Format::LikeGo — The one thing to know
# https://raku.online/modules/datetime-format-likego/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install DateTime::Format::LikeGo
#     rakupp 03-reference-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DateTime::Format::LikeGo;

my $dt = DateTime.new(2025, 3, 9, 15, 4, 5, :timezone(0));

for 'Mon Jan 2 15:04:05 2006',
    'Monday, January 2, 2006',
    '3:04PM',
    'Jan 2, 2006',
    '1/2/2006',
    '2006-01-02T15:04:05Z07:00',
    '15:04:05.000' -> $fmt {
    my $r = try go-date-format($fmt, $dt);
    say sprintf('%-30s -> %s', $fmt, $! ?? 'refused' !! $r);
}

# Output:
#     Mon Jan 2 15:04:05 2006        -> refused
#     Monday, January 2, 2006        -> refused
#     3:04PM                         -> refused
#     Jan 2, 2006                    -> refused
#     1/2/2006                       -> refused
#     2006-01-02T15:04:05Z07:00      -> refused
#     15:04:05.000                   -> refused
