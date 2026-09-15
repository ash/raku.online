#!/usr/bin/env rakupp
# File::Stat — The one thing to know
# https://raku.online/modules/file-stat/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install File::Stat
#     rakupp 03-not-a-snapshot.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Stat;

my $file = $*TMPDIR.add("statg-{$*PID}.txt");
$file.spurt('aaaa');

my $s = File::Stat.new(path => $file.Str);
say $s.size;
$file.spurt('aaaabbbbcccc');
say $s.size;

$file.unlink;
say (try $s.size) // 'the file is gone, and so is every field';

# Output:
#     4
#     12
#     the file is gone, and so is every field
