#!/usr/bin/env rakupp
# File::Find — The filters
# https://raku.online/ecosystem/file-find/#the-filters
#
# Install what it needs, then run it:
#     rakupp install File::Find
#     rakupp 02-filters.raku
#
# Run under Raku++ 3.6.0 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use File::Find;

my $root = $*TMPDIR.add("find-excl-$*PID");
LEAVE { run 'rm', '-rf', ~$root }
$root.add('keep').mkdir;
$root.add('.git').mkdir;
$root.add('keep/a.txt').spurt('a');
$root.add('.git/objects').spurt('junk');

say find(dir => $root, exclude => /'.git'/).map(*.basename).sort.join(' ');
say find(dir => $root, recursive => False).map(*.basename).sort.join(' ');

# Output:
#     a.txt keep
#     .git keep
