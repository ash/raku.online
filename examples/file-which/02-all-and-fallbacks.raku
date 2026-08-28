#!/usr/bin/env rakupp
# File::Which — Every hit, and fallback chains
# https://raku.online/modules/file-which/#every-hit-and-fallback-chains
#
# Install what it needs, then run it:
#     rakupp install File::Which
#     rakupp 02-all-and-fallbacks.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Which;

my @sh = which('sh', :all);
say so @sh.elems >= 1;
say @sh[0];

my $pager = <a-fancy-pager-you-lack cat>.map({ which($_) }).first(*.defined);
say $pager;

# Output:
#     True
#     /bin/sh
#     /bin/cat
