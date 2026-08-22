#!/usr/bin/env rakupp
# File::Find — What it is for
# https://raku.online/ecosystem/file-find/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install File::Find
#     rakupp 01-tour.raku
#
# Run under Raku++ 3.6.0 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use File::Find;

my $root = $*TMPDIR.add("find-demo-$*PID");
LEAVE { run 'rm', '-rf', ~$root }
$root.add('src/deep').mkdir;
$root.add('README.md').spurt('readme');
$root.add('src/a.raku').spurt('say 1');
$root.add('src/deep/b.raku').spurt('say 2');

say find(dir => $root).elems;
say find(dir => $root, name => /\.raku$/).map(*.basename).sort.join(' ');
say find(dir => $root, type => 'dir').map(*.basename).sort.join(' ');

# Output:
#     5
#     a.raku b.raku
#     deep src
