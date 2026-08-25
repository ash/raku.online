#!/usr/bin/env rakupp
# File::Temp — Who removes what, and when
# https://raku.online/modules/file-temp/#who-removes-what-and-when
#
# Install what it needs, then run it:
#     rakupp install File::Temp
#     rakupp 04-cleanup.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Temp;

my $kept = do {
    my ($p, $fh) = tempfile;
    $fh.close;
    $p;
};
say $kept.IO.e;

my ($keep, $fh2) = tempfile(:!unlink);
$fh2.close;
say $keep.IO.e;
$keep.IO.unlink;
say $keep.IO.e;

# Output:
#     True
#     True
#     False
