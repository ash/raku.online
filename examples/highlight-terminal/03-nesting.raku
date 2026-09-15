#!/usr/bin/env rakupp
# Highlight::Terminal — The one thing to know
# https://raku.online/modules/highlight-terminal/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Highlight::Terminal
#     rakupp 03-nesting.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Highlight::Terminal;

class HL does Highlight::Terminal {}
my $h = HL.new;

my $inner = $h.hl('version', 'INNER');
my $outer = $h.hl('block', "before{$inner}after");

say 'inner : ', $inner.raku;
say 'outer : ', $outer.raku;
say 'reset sequences in the outer string : ', +$outer.comb(/ \x1b '[m' /);
say 'the word "after" is preceded by a reset, so it renders with no colour';

# Output:
#     inner : "\x[1B][33;4mINNER\x[1B][m"
#     outer : "\x[1B][35mbefore\x[1B][33;4mINNER\x[1B][mafter\x[1B][m"
#     reset sequences in the outer string : 2
#     the word "after" is preceded by a reset, so it renders with no colour
