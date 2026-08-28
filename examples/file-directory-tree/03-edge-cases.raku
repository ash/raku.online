#!/usr/bin/env rakupp
# File::Directory::Tree — What the edges do
# https://raku.online/modules/file-directory-tree/#what-the-edges-do
#
# Install what it needs, then run it:
#     rakupp install File::Directory::Tree
#     rakupp 03-edge-cases.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Directory::Tree;

my $work = $*TMPDIR.add("fdt-edges-$*PID");
mktree $work;

say rmtree($work.add('never/existed'));

my $file = $work.add('plain.txt');
$file.spurt('z');
say rmtree($file).so;
say $file.e;

rmtree $work;

# Output:
#     True
#     False
#     True
