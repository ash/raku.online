#!/usr/bin/env rakupp
# File::Find — It is lazy, and that matters
# https://raku.online/modules/file-find/#it-is-lazy-and-that-matters
#
# Install what it needs, then run it:
#     rakupp install File::Find
#     rakupp 03-lazy.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Find;

my $root = $*TMPDIR.add("find-lazy-$*PID");
LEAVE { run 'rm', '-rf', ~$root }
$root.mkdir;
$root.add("f$_.txt").spurt('x') for ^50;

my $seq = find(dir => $root);
say $seq.^name;
say $seq.head(3).elems;
say find(dir => $root, name => /f1 \d '.txt'/).elems;

# Output:
#     Seq
#     3
#     10
