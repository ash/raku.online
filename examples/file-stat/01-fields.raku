#!/usr/bin/env rakupp
# File::Stat — The fields
# https://raku.online/modules/file-stat/#the-fields
#
# Install what it needs, then run it:
#     rakupp install File::Stat
#     rakupp 01-fields.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Stat;

my $file = $*TMPDIR.add("stat-{$*PID}.bin");
$file.spurt('0123456789');
$file.chmod(0o640);

my $s = File::Stat.new(path => $file.Str);
say 'size    ', $s.size;
say 'mode    ', $s.mode.base(8);
say 'nlink   ', $s.nlink;
say 'blksize ', $s.blksize;
say 'inode   ', $s.ino > 0;
say 'device  ', $s.dev > 0;
say 'rdev    ', $s.rdev;
say 'owned   ', $s.uid == +$*USER;
say 'mtime   ', $s.mtime.^name;

$file.unlink;

# Output:
#     size    10
#     mode    100640
#     nlink   1
#     blksize 4096
#     inode   True
#     device  True
#     rdev    0
#     owned   True
#     mtime   Int
