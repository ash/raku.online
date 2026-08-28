#!/usr/bin/env rakupp
# TAP — Running files: the harness
# https://raku.online/modules/tap/#running-files-the-harness
#
# Install what it needs, then run it:
#     rakupp install TAP
#     rakupp 03-run-tap-files.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TAP;

my $dir = $*TMPDIR.add("tap-demo-$*PID");
mkdir $dir;
$dir.add('results.tap').spurt(q:to/END/);
    TAP version 13
    1..3
    ok 1 - the server starts
    ok 2 - it answers on the right port
    ok 3 - it stops again
    END

indir $dir, {
    my $aggregator = await TAP::Harness.new.run('results.tap');
    say '';
    say $aggregator.passed, '/', $aggregator.tests-run, ' passed';
}

unlink $dir.add('results.tap'); rmdir $dir;

# Output:
#     results.tap .. ok
#     All tests successful.
#     Files=1, Tests=3,  0 wallclock secs
#     Result: PASS
#     
#     3/3 passed
