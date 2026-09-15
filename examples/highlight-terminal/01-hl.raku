#!/usr/bin/env rakupp
# Highlight::Terminal — Composing and colouring
# https://raku.online/modules/highlight-terminal/#composing-and-colouring
#
# Install what it needs, then run it:
#     rakupp install Highlight::Terminal
#     rakupp 01-hl.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Highlight::Terminal;

class HL does Highlight::Terminal {}
my $h = HL.new;

say 'table entries       : ', $h.map.elems;
say 'entries with colour : ', $h.map.values.grep(*.defined).elems;
say '';
for <version arrow block multi> -> $t {
    say sprintf('%-8s %s', $t, $h.hl($t, 'TEXT').raku);
}
say 'unknown category    : ', $h.hl('no-such-category', 'TEXT').raku;

# Output:
#     table entries       : 90
#     entries with colour : 42
#     
#     version  "\x[1B][33;4mTEXT\x[1B][m"
#     arrow    "\x[1B][35;1mTEXT\x[1B][m"
#     block    "\x[1B][35mTEXT\x[1B][m"
#     multi    "\x[1B][32;1mTEXT\x[1B][m"
#     unknown category    : "TEXT"
