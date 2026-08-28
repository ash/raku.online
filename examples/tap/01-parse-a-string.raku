#!/usr/bin/env rakupp
# TAP — What it is for
# https://raku.online/modules/tap/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install TAP
#     rakupp 01-parse-a-string.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TAP;

my $tap = q:to/END/;
    1..4
    ok 1 - addition
    ok 2 - subtraction
    not ok 3 - division
    ok 4 - modulo # TODO edge case
    END

my $parser = TAP::Source::String.new(:content($tap)).parse;
my $result = await $parser;
say $result.tests-planned;
say $result.tests-run;
say $result.passed;
say $result.failed;
say $result.has-problems;

# Output:
#     4
#     4
#     3
#     [3]
#     True
