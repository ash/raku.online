#!/usr/bin/env rakupp
# File::Directory::Tree — Emptying without removing
# https://raku.online/modules/file-directory-tree/#emptying-without-removing
#
# Install what it needs, then run it:
#     rakupp install File::Directory::Tree
#     rakupp 02-empty-directory.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Directory::Tree;

my $work = $*TMPDIR.add("fdt-empty-$*PID");
mktree $work.add('cache/a/b');
$work.add('cache/one.txt').spurt('x');
$work.add('cache/a/two.txt').spurt('y');

say empty-directory($work.add('cache'));
say $work.add('cache').d;
say $work.add('cache').dir.elems;
rmtree $work;

# Output:
#     True
#     True
#     0
