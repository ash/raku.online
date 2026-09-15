#!/usr/bin/env rakupp
# File::Stat — The fields
# https://raku.online/modules/file-stat/#the-fields
#
# Install what it needs, then run it:
#     rakupp install File::Stat
#     rakupp 02-symlinks.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Stat;

my $dir = $*TMPDIR.add("statl-{$*PID}");
$dir.mkdir;
my $target = $dir.add('target.txt');
$target.spurt('0123456789abcdef');
my $link = $dir.add('thelink');
$target.symlink($link);

my $follow = File::Stat.new(path => $link.Str);
my $itself = File::Stat.new(path => $link.Str, l => True);
say 'follows the link: size ', $follow.size, ' mode ', $follow.mode.base(8);
say 'the link itself : mode ', $itself.mode.base(8);
say 'same inode      : ', $follow.ino == $itself.ino;

.unlink for $dir.dir;
$dir.rmdir;

# Output:
#     follows the link: size 16 mode 100644
#     the link itself : mode 120755
#     same inode      : False
