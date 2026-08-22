#!/usr/bin/env rakupp
# File::Temp — Naming it something recognisable
# https://raku.online/ecosystem/file-temp/#naming-it-something-recognisable
#
# Install what it needs, then run it:
#     rakupp install File::Temp
#     rakupp 02-named.raku
#
# Run under Raku++ 3.6.0 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use File::Temp;

my ($path, $fh) = tempfile(:prefix<report->, :suffix<.txt>);
$fh.spurt("id,name\n1,raku\n", :close);
say $path.IO.basename.starts-with('report-');
say $path.IO.extension;
say $path.IO.slurp.lines.elems;

# Output:
#     True
#     txt
#     2
