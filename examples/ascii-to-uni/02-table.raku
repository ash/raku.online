#!/usr/bin/env rakupp
# ASCII::To::Uni — Your own table
# https://raku.online/modules/ascii-to-uni/#your-own-table
#
# Install what it needs, then run it:
#     rakupp install ASCII::To::Uni
#     rakupp 02-table.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use ASCII::To::Uni;

my Str $t = 'alpha beta gamma';
convert-string($t, table => { 'alpha' => 'A', 'beta' => 'B' });
say $t;

# Output:
#     A B gamma
