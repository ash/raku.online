#!/usr/bin/env rakupp
# DateTime::Format::LikeGo — The tokens it knows
# https://raku.online/modules/datetime-format-likego/#the-tokens-it-knows
#
# Install what it needs, then run it:
#     rakupp install DateTime::Format::LikeGo
#     rakupp 02-tokens.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DateTime::Format::LikeGo;

my $dt = DateTime.new(2025, 3, 9, 15, 4, 5, :timezone(0));

say 'the recognised tokens are exactly:';
say '  Mon Monday Jan January 02 _2 01 15 03 _3 04 pm PM 05 06 2006 MST';
say '';
for 'Mon', 'Monday', 'Jan', 'January', '2006', '06', '01', '02', '15', '04', '05' -> $t {
    say sprintf('  %-10s -> %s', $t, go-date-format($t, $dt));
}

# Output:
#     the recognised tokens are exactly:
#       Mon Monday Jan January 02 _2 01 15 03 _3 04 pm PM 05 06 2006 MST
#     
#       Mon        -> Sun
#       Monday     -> Sunday
#       Jan        -> Mar
#       January    -> March
#       2006       -> 2025
#       06         -> 25
#       01         -> 03
#       02         -> 09
#       15         -> 15
#       04         -> 04
#       05         -> 05
