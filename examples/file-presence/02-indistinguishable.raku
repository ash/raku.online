#!/usr/bin/env rakupp
# File::Presence — The one thing to know
# https://raku.online/modules/file-presence/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install File::Presence
#     rakupp 02-indistinguishable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Presence;

my $dir = $*TMPDIR.add("presl-{$*PID}");
$dir.mkdir;
$dir.add('locked').mkdir;
$dir.add('locked/inside.txt').spurt("I exist\n");

my $P = File::Presence;
my $real    = $dir.add('locked/inside.txt').Str;
my $missing = $dir.add('locked/never-made.txt').Str;

say 'before: real    ', $P.exists-readable-file($real);
say 'before: missing ', $P.exists-readable-file($missing);

$dir.add('locked').chmod(0o000);
say 'after:  real    ', $P.exists-readable-file($real);
say 'after:  missing ', $P.exists-readable-file($missing);
say 'identical snapshots: ',
    $P.show($real).sort.gist eq $P.show($missing).sort.gist;

$dir.add('locked').chmod(0o755);
$dir.add('locked/inside.txt').unlink;
$dir.add('locked').rmdir;
$dir.rmdir;

# Output:
#     before: real    True
#     before: missing False
#     after:  real    False
#     after:  missing False
#     identical snapshots: True
