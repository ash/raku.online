#!/usr/bin/env rakupp
# File::Directory::Bubble — The removal order
# https://raku.online/modules/file-directory-bubble/#the-removal-order
#
# Install what it needs, then run it:
#     rakupp install File::Directory::Bubble
#     rakupp 02-order.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Directory::Bubble;

my $root = $*TMPDIR.add("bb2-{$*PID}");
LEAVE { run 'rm', '-rf', $root.Str }

mkdir $root.add('a/b1/c');
mkdir $root.add('a/b2');
$root.add('a/b1/c/d').spurt('one');
$root.add('a/b2/e').spurt('two');
$root.add('a/f').spurt('three');

sub rel($p) { $p.Str.subst($root.Str, '<ROOT>') }

say 'bbDown(a) in the order it hands them back:';
say '  ', $_ for bbDown($root.add('a')).map(&rel);
say '';
smartRm($_) for bbDown($root.add('a'));
say 'feeding that order straight to smartRm:';
say '  a still exists    : ', $root.add('a').e;
say '  root still exists : ', $root.e;

# Output:
#     bbDown(a) in the order it hands them back:
#       /private<ROOT>/a/b2/e
#       /private<ROOT>/a/b2
#       /private<ROOT>/a/f
#       /private<ROOT>/a/b1/c/d
#       /private<ROOT>/a/b1/c
#       /private<ROOT>/a/b1
#       /private<ROOT>/a
#     
#     feeding that order straight to smartRm:
#       a still exists    : False
#       root still exists : True
