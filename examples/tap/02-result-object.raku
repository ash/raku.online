#!/usr/bin/env rakupp
# TAP — What a run adds up to
# https://raku.online/modules/tap/#what-a-run-adds-up-to
#
# Install what it needs, then run it:
#     rakupp install TAP
#     rakupp 02-result-object.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TAP;

my $tap = q:to/END/;
    1..6
    ok 1 - basic maths
    not ok 2 - the tricky case
    ok 3 - rounding # TODO negative zero undecided
    not ok 4 - overflow handling # TODO needs bigint
    ok 5 - unicode names # SKIP no locale on this box
    ok 6 - cleanup
    END

my $result = await TAP::Source::String.new(:content($tap)).parse;
say 'planned      ', $result.tests-planned;
say 'passed       ', $result.passed;
say 'failed       ', $result.failed;
say 'todo         ', $result.todo;
say 'todo-passed  ', $result.todo-passed;
say 'skipped      ', $result.skipped;

# Output:
#     planned      6
#     passed       5
#     failed       [2]
#     todo         2
#     todo-passed  [3]
#     skipped      1
