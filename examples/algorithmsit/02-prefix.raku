#!/usr/bin/env rakupp
# AlgorithmsIT — Matching
# https://raku.online/modules/algorithmsit/#matching
#
# Install what it needs, then run it:
#     rakupp install AlgorithmsIT
#     rakupp 02-prefix.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use AlgorithmsIT :p1005, :p1006;
use AlgorithmsIT::Classes;

my $pi = Compute-Prefix-Function(ArrayOneBased.new('ababaca'));
say 'Compute-Prefix-Function("ababaca") : ', $pi.gist;
say 'the textbook pi for ababaca        : [ 0, 0, 1, 2, 3, 0, 1 ]';
say '';
say 'the two import tags are the book`s PAGE NUMBERS:';
say '  :p1005 gives KMP-Matcher';
say '  :p1006 gives Compute-Prefix-Function';
say 'a plain `use AlgorithmsIT` imports NEITHER.';

# Output:
#     Compute-Prefix-Function("ababaca") : [ 0, 0, 1, 2, 3, 0, 1 ]
#     the textbook pi for ababaca        : [ 0, 0, 1, 2, 3, 0, 1 ]
#     
#     the two import tags are the book`s PAGE NUMBERS:
#       :p1005 gives KMP-Matcher
#       :p1006 gives Compute-Prefix-Function
#     a plain `use AlgorithmsIT` imports NEITHER.
