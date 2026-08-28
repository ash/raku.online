#!/usr/bin/env rakupp
# TAP — Watching entries as they stream
# https://raku.online/modules/tap/#watching-entries-as-they-stream
#
# Install what it needs, then run it:
#     rakupp install TAP
#     rakupp 06-subtests.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TAP;

my $tap = q:to/END/;
    1..2
        ok 1 - opens
        ok 2 - closes
        1..2
    ok 1 - the file half
    ok 2 - the network half
    END

class Peek does TAP::Entry::Handler {
    method handle-entry($e) {
        say $e.^name, ($e ~~ TAP::Sub-Test ?? " with {$e.entries.elems} entries" !! '');
    }
}
my $r = await TAP::Source::String.new(:content($tap)).parse(:handlers[Peek.new]);
say $r.passed, '/', $r.tests-run;

# Output:
#     TAP::Plan
#     TAP::Sub-Test with 3 entries
#     TAP::Test
#     2/2
