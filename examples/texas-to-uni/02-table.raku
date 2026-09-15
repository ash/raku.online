#!/usr/bin/env rakupp
# Texas::To::Uni — Converting a string
# https://raku.online/modules/texas-to-uni/#converting-a-string
#
# Install what it needs, then run it:
#     rakupp install Texas::To::Uni
#     rakupp 02-table.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Texas::To::Uni;

my $s = 'a AND b (<=) c';
convert-string($s, table => Map.new('AND', "\c[LOGICAL AND]"));
say 'with a custom table : ', $s;
say '  only AND was converted — (<=) was left alone, because the custom';
say '  table is the whole table.';

# Output:
#     with a custom table : a ∧ b (<=) c
#       only AND was converted — (<=) was left alone, because the custom
#       table is the whole table.
