#!/usr/bin/env rakupp
# File::Directory::Bubble — Walking upwards
# https://raku.online/modules/file-directory-bubble/#walking-upwards
#
# Install what it needs, then run it:
#     rakupp install File::Directory::Bubble
#     rakupp 03-up.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Directory::Bubble;

my $root = $*TMPDIR.add("bb3-{$*PID}");
LEAVE { run 'rm', '-rf', $root.Str }

mkdir $root.add('a/b/c');
$root.add('a/keep.txt').spurt('x');

sub rel($p) { $p.Str.subst($root.Str, '<ROOT>') }

say 'noChildrenExcept(a/b/c, [])  : ', noChildrenExcept($root.add('a/b/c'), []);
say 'noChildrenExcept(a, [])      : ', noChildrenExcept($root.add('a'), []);
say '';
say 'bbUpEmpty(a/b/c, []) — how far removing it would cascade:';
say '  ', bbUpEmpty($root.add('a/b/c'), []).map(&rel).List.raku;
say '';
say 'it stops at a, because a still holds keep.txt';

# Output:
#     noChildrenExcept(a/b/c, [])  : True
#     noChildrenExcept(a, [])      : False
#     
#     bbUpEmpty(a/b/c, []) — how far removing it would cascade:
#       ("/private<ROOT>/a/b/c", "/private<ROOT>/a/b")
#     
#     it stops at a, because a still holds keep.txt
