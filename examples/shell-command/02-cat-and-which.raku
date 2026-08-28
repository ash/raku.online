#!/usr/bin/env rakupp
# Shell::Command — The rest of the toolbox
# https://raku.online/modules/shell-command/#the-rest-of-the-toolbox
#
# Install what it needs, then run it:
#     rakupp install Shell::Command
#     rakupp 02-cat-and-which.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Shell::Command;

my $work = $*TMPDIR.add("sc-cat-$*PID").Str;
mkpath $work;
"$work/one.txt".IO.spurt('line one');
"$work/two.txt".IO.spurt('line two');

cat "$work/one.txt", "$work/two.txt";

say which('sh');
rm_rf $work;

# Output:
#     line one
#     line two
#     /bin/sh
