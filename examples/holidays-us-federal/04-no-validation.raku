#!/usr/bin/env rakupp
# Holidays::US::Federal — Where the two engines differ
# https://raku.online/modules/holidays-us-federal/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Holidays::US::Federal
#     rakupp 04-no-validation.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Holidays::US::Federal;

for 1776, 1600 -> $y {
    my %h = get-fedholidays(:year($y), :set-id('S'));
    my $june = %h.keys.first({ %h{$_}.values[0].name.contains('Juneteenth') });
    say sprintf('%d : %d holidays returned, including Juneteenth on %s', $y, %h.elems, $june);
}
say '';
say 'Juneteenth became a federal holiday in 2021.';

# Output:
#     1776 : 11 holidays returned, including Juneteenth on 1776-06-19
#     1600 : 11 holidays returned, including Juneteenth on 1600-06-19
#     
#     Juneteenth became a federal holiday in 2021.
