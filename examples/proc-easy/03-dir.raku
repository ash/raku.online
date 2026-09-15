#!/usr/bin/env rakupp
# Proc::Easy — Running somewhere else
# https://raku.online/modules/proc-easy/#running-somewhere-else
#
# Install what it needs, then run it:
#     rakupp install Proc::Easy
#     rakupp 03-dir.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Proc::Easy;

my $dir = $*TMPDIR.add("pe-{$*PID}");
$dir.mkdir;
LEAVE { $dir.rmdir }

my $before = $*CWD;
my $out = run-command('pwd', :out, :dir($dir.Str));
say 'ran in the fixture      : ', $out.chomp.ends-with("pe-{$*PID}");
say 'and came back afterwards : ', $*CWD.absolute eq $before.absolute;

# Output:
#     ran in the fixture      : True
#     and came back afterwards : True
