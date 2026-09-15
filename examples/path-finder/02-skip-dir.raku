#!/usr/bin/env rakupp
# Path::Finder — The one thing to know
# https://raku.online/modules/path-finder/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Path::Finder
#     rakupp 02-skip-dir.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Path::Finder;

my $root = $*TMPDIR.add("pfs-{$*PID}");
$root.mkdir;
$root.add('node_modules').mkdir;
$root.add('node_modules/pkg').mkdir;
$root.add('node_modules/pkg/y.txt').spurt("y\n");
$root.add('src').mkdir;
$root.add('src/x.txt').spurt("x\n");

say 'from the project root : ',
    find($root, :file, :skip-dir('node_modules'), :relative).elems;
say 'started inside it     : ',
    find($root.add('node_modules'), :file, :skip-dir('node_modules'), :relative).elems;
say 'with skip-subdir      : ',
    find($root.add('node_modules'), :file, :skip-subdir('node_modules'), :relative).elems;

sub nuke($d) { for $d.dir { $_.d ?? nuke($_) !! .unlink }; rmdir $d }
nuke($root);

# Output:
#     from the project root : 1
#     started inside it     : 0
#     with skip-subdir      : 1
