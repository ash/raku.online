#!/usr/bin/env rakupp
# Locale::US — The one thing to know
# https://raku.online/modules/locale-us/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Locale::US
#     rakupp 02-table.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Locale::US;

my @codes = all-state-codes.sort;
say 'rows in the table : ', @codes.elems;
say '';
my @extras = @codes.grep({ $_ !~~ any(<AL AK AZ AR CA CO CT DE FL GA HI ID IL IN
    IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI
    SC SD TN TX UT VT VA WA WV WI WY>) });
say 'the nine that are not one of the fifty states:';
for @extras -> $c { say sprintf('  %s = %s', $c, code-to-state($c)) }
say '';
say 'so `all-state-codes.elems == 50` is false, and any UI that renders';
say 'this list as "the states" is wrong. There is no UM row (U.S. Minor';
say 'Outlying Islands): code-to-state("UM").defined = ',
    code-to-state('UM').defined;

# Output:
#     rows in the table : 59
#     
#     the nine that are not one of the fifty states:
#       AS = AMERICAN SAMOA
#       DC = DISTRICT OF COLUMBIA
#       FM = FEDERATED STATES OF MICRONESIA
#       GU = GUAM
#       MH = MARSHALL ISLANDS
#       MP = NORTHERN MARIANA ISLANDS
#       PR = PUERTO RICO
#       PW = PALAU
#       VI = VIRGIN ISLANDS
#     
#     so `all-state-codes.elems == 50` is false, and any UI that renders
#     this list as "the states" is wrong. There is no UM row (U.S. Minor
#     Outlying Islands): code-to-state("UM").defined = False
