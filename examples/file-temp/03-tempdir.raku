#!/usr/bin/env rakupp
# File::Temp — Directories
# https://raku.online/modules/file-temp/#directories
#
# Install what it needs, then run it:
#     rakupp install File::Temp
#     rakupp 03-tempdir.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Temp;

my $dir = tempdir;
say $dir.IO.d;
$dir.IO.add('a.txt').spurt('x');
say $dir.IO.dir.elems;

# Output:
#     True
#     1
