#!/usr/bin/env rakupp
# Swedish::TextDates_sv — Where the two engines differ
# https://raku.online/modules/swedish-textdates-sv/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Swedish::TextDates_sv
#     rakupp 05-enum.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

my enum Weekday «:måndag(1) tisdag onsdag torsdag»;
say 'a non-ASCII colonpair key seeds the enum:';
for Weekday.enums.sort(*.value) -> $p {
    say sprintf('  %-9s %d', $p.key, $p.value);
}

# Output:
#     a non-ASCII colonpair key seeds the enum:
#       måndag    1
#       tisdag    2
#       onsdag    3
#       torsdag   4
