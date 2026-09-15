#!/usr/bin/env rakupp
# File::Directory::Bubble — Listing a tree
# https://raku.online/modules/file-directory-bubble/#listing-a-tree
#
# Install what it needs, then run it:
#     rakupp install File::Directory::Bubble
#     rakupp 01-down.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Directory::Bubble;

my $root = $*TMPDIR.add("bb-{$*PID}");
LEAVE { run 'rm', '-rf', $root.Str }

mkdir $root.add('a/b/c');
mkdir $root.add('a/b1/c');
$root.add('a/b1/c/d').spurt('one');
$root.add('foo.txt').spurt('top');

sub rel($p) { $p.Str.subst($root.Str, '<ROOT>') }

say 'bbDown($root), sorted:';
say '  ', $_ for bbDown($root).map(&rel).sort;
say '';
say 'bbDown of an empty directory : ', bbDown($root.add('a/b/c')).map(&rel).List.raku;
say 'listParents of a leaf, first three : ',
    listParents($root.add('a/b1/c/d')).head(3).map(&rel).List.raku;

# Output:
#     bbDown($root), sorted:
#       /private<ROOT>
#       /private<ROOT>/a
#       /private<ROOT>/a/b
#       /private<ROOT>/a/b/c
#       /private<ROOT>/a/b1
#       /private<ROOT>/a/b1/c
#       /private<ROOT>/a/b1/c/d
#       /private<ROOT>/foo.txt
#     
#     bbDown of an empty directory : ("/private<ROOT>/a/b/c",)
#     listParents of a leaf, first three : ("/private<ROOT>/a/b1/c", "/private<ROOT>/a/b1", "/private<ROOT>/a")
