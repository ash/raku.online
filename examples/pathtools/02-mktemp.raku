#!/usr/bin/env rakupp
# PathTools — Temporary paths
# https://raku.online/modules/pathtools/#temporary-paths
#
# Install what it needs, then run it:
#     rakupp install PathTools
#     rakupp 02-mktemp.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use PathTools;

my $path = tmppath();
say 'tmppath mints a path without creating anything:';
say '  looks like a path : ', $path.IO.parent.d;
say '  it exists         : ', $path.IO.e;

my $dir  = mktemp();
my $file = mktemp(:f);
say '';
say 'mktemp creates:';
say '  directory exists : ', $dir.IO.d;
say '  file exists      : ', $file.IO.f;

# Output:
#     tmppath mints a path without creating anything:
#       looks like a path : True
#       it exists         : False
#     
#     mktemp creates:
#       directory exists : True
#       file exists      : True
