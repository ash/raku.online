#!/usr/bin/env rakupp
# Shell::Command — What it is for
# https://raku.online/modules/shell-command/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install Shell::Command
#     rakupp 01-cp-and-rm.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Shell::Command;

my $work = $*TMPDIR.add("sc-demo-$*PID").Str;
mkpath "$work/src/deep";
"$work/src/a.txt".IO.spurt('first');
"$work/src/deep/b.txt".IO.spurt('second');

cp "$work/src", "$work/backup", :r;
say "$work/backup/deep/b.txt".IO.slurp;

rm_rf $work;
say $work.IO.e;

# Output:
#     second
#     False
