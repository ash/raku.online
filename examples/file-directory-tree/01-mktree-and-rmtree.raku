#!/usr/bin/env rakupp
# File::Directory::Tree — What it is for
# https://raku.online/modules/file-directory-tree/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install File::Directory::Tree
#     rakupp 01-mktree-and-rmtree.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Directory::Tree;

my $root = $*TMPDIR.add("fdt-demo-$*PID");
mktree $root.add('deep/deeper/deepest');
say $root.add('deep/deeper/deepest').d;

$root.add('deep/note.txt').spurt('hello');
say rmtree($root.add('deep'));
say $root.add('deep').e;
say $root.d;
rmtree $root;
say $root.e;

# Output:
#     True
#     True
#     False
#     True
#     False
