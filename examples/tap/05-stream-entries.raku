#!/usr/bin/env rakupp
# TAP — Watching entries as they stream
# https://raku.online/modules/tap/#watching-entries-as-they-stream
#
# Install what it needs, then run it:
#     rakupp install TAP
#     rakupp 05-stream-entries.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TAP;

class Narrator does TAP::Entry::Handler {
    method handle-entry($entry) {
        given $entry {
            when TAP::Plan    { say "plan: {.tests} tests promised" }
            when TAP::Test    { say "test {.number}: {.ok ?? 'ok' !! 'NOT ok'} — {.description}" }
            when TAP::Comment { say "note: {.comment}" }
        }
    }
    method end-entries() { say "-- stream ended --" }
}

my $tap = q:to/END/;
    1..2
    # starting up
    ok 1 - config loads
    not ok 2 - server answers
    END

await TAP::Source::String.new(:content($tap)).parse(:handlers[Narrator.new]);

# Output:
#     plan: 2 tests promised
#     note: starting up
#     test 1: ok — config loads
#     test 2: NOT ok — server answers
#     -- stream ended --
