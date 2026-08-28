#!/usr/bin/env rakupp
# TAP — The report, taken apart
# https://raku.online/modules/tap/#the-report-taken-apart
#
# Install what it needs, then run it:
#     rakupp install TAP
#     rakupp 04-failure-report.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TAP;

my $tap = q:to/END/;
    1..3
    ok 1 - the server starts
    not ok 2 - it answers on the right port
    ok 3 - it stops again
    END

my $result = await TAP::Source::String.new(:content($tap), :name<t/server.rakutest>).parse;

my $aggregator = TAP::Aggregator.new;
$aggregator.add-result($result);

my $formatter = TAP::Formatter::Text.new(:names[$result.name]);
print $formatter.format-summary($aggregator, Duration);

# Output:
#     
#     Test Summary Report
#     -------------------
#     t/server.rakutest (Wstat: (none) Tests: 3 Failed: 1)
#       Failed tests:  2
#     Files=1, Tests=3
#     Result: FAILED
