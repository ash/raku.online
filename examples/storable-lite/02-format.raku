#!/usr/bin/env rakupp
# Storable::Lite — What the file holds
# https://raku.online/modules/storable-lite/#what-the-file-holds
#
# Install what it needs, then run it:
#     rakupp install Storable::Lite
#     rakupp 02-format.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Storable::Lite;

my $dir = $*TMPDIR.add("store2-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }
my $f = $dir.add('conf.raku').absolute;

to-file($f, [ 'example.invalid', 8080, 3 ]);
say 'the file is Raku source:';
say '  ', $f.IO.slurp.trim;
say '';
say 'which is why it reads back with its types intact:';
say '  ', from-file($f).map(*.^name).join(' ');

# Output:
#     the file is Raku source:
#       $["example.invalid", 8080, 3]
#     
#     which is why it reads back with its types intact:
#       Str Int Int
