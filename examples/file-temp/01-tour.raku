#!/usr/bin/env rakupp
# File::Temp — What it is for
# https://raku.online/modules/file-temp/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install File::Temp
#     rakupp 01-tour.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Temp;

my ($path, $fh) = tempfile;
$fh.spurt("two\nlines\n", :close);
say $path.IO.e;
say $path.IO.slurp.lines.elems;
say $path.IO.basename.chars > 0;

# Output:
#     True
#     2
#     True
