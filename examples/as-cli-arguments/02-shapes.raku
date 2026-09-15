#!/usr/bin/env rakupp
# as-cli-arguments — The other three candidates
# https://raku.online/modules/as-cli-arguments/#the-other-three-candidates
#
# Install what it needs, then run it:
#     rakupp install as-cli-arguments
#     rakupp 02-shapes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use as-cli-arguments;

my %h = apple => 'a', zebra => 'z', mango => 'm';
say 'a Hash is rendered in SORTED key order:';
say '  ', as-cli-arguments(%h).raku;
say '';
my @pairs = zebra => 'z', apple => 'a', mango => 'm';
say 'a list of pairs KEEPS your order:';
say '  ', as-cli-arguments(@pairs).raku;
say '';
say 'if you care about option order, pass a list of pairs.';
say '';
my $pair = url => 'http://x';
say 'a single Pair, passed through a variable:';
say '  ', as-cli-arguments($pair).raku;
say '  note the quoting — a value containing whitespace or a colon is';
say '  wrapped in single quotes.';

# Output:
#     a Hash is rendered in SORTED key order:
#       "--apple=a --mango=m --zebra=z"
#     
#     a list of pairs KEEPS your order:
#       "--zebra=z --apple=a --mango=m"
#     
#     if you care about option order, pass a list of pairs.
#     
#     a single Pair, passed through a variable:
#       "--url='http://x'"
#       note the quoting — a value containing whitespace or a colon is
#       wrapped in single quotes.
