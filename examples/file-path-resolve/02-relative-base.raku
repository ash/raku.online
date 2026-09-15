#!/usr/bin/env rakupp
# File::Path::Resolve — The one thing to know
# https://raku.online/modules/file-path-resolve/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install File::Path::Resolve
#     rakupp 02-relative-base.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Path::Resolve;

my $R = File::Path::Resolve;
my $root = $*TMPDIR.add("fpr-{$*PID}");
$root.mkdir;
$root.add('project').mkdir;
$root.add('project/sub').mkdir;
$root.add('project/conf.ini').spurt("k=v\n");
$root.add('project/sub/other.ini').spurt("k=v\n");

my $dir  = $root.add('project').Str;
my $file = $root.add('project/conf.ini').Str;

say 'base is the directory: ', $R.relative('sub/other.ini', $dir).e;
say 'base is a file in it : ', $R.relative('sub/other.ini', $file).e;

$root.add('project/sub/other.ini').unlink;
$root.add('project/conf.ini').unlink;
$root.add('project/sub').rmdir;
$root.add('project').rmdir;
$root.rmdir;

# Output:
#     base is the directory: False
#     base is a file in it : True
