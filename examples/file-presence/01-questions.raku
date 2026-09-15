#!/usr/bin/env rakupp
# File::Presence — The four questions
# https://raku.online/modules/file-presence/#the-four-questions
#
# Install what it needs, then run it:
#     rakupp install File::Presence
#     rakupp 01-questions.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Presence;

my $dir = $*TMPDIR.add("pres-{$*PID}");
$dir.mkdir;
$dir.add('sub').mkdir;
my $file = $dir.add('readable.txt');
$file.spurt("hi\n");
$file.chmod(0o444);

my $P = File::Presence;
say 'file, readable       ', $P.exists-readable-file($file.Str);
say 'file, read-write     ', $P.exists-readwriteable-file($file.Str);
say 'dir, readable        ', $P.exists-readable-dir($dir.add('sub').Str);
say 'dir, read-write      ', $P.exists-readwriteable-dir($dir.add('sub').Str);
say 'missing              ', $P.exists-readable-file($dir.add('nope').Str);
say 'a dir asked as file  ', $P.exists-readable-file($dir.add('sub').Str);
say 'a file asked as dir  ', $P.exists-readable-dir($file.Str);

say $P.show($file.Str).sort.map({ .key ~ '=' ~ .value }).join(' ');

$file.chmod(0o644);
$file.unlink;
$dir.add('sub').rmdir;
$dir.rmdir;

# Output:
#     file, readable       True
#     file, read-write     False
#     dir, readable        True
#     dir, read-write      True
#     missing              False
#     a dir asked as file  False
#     a file asked as dir  False
#     d=False e=True f=True r=True w=False x=False
