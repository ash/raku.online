#!/usr/bin/env rakupp
# Fortune — Your own database
# https://raku.online/modules/fortune/#your-own-database
#
# Install what it needs, then run it:
#     rakupp install Fortune
#     rakupp 02-own.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Fortune;

my $dir = $*TMPDIR.add("fortune-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }

my $db = $dir.add('sayings');
$db.spurt("alpha\n\%\nbeta\n\%\ngamma\n\%\n");

my $f = Fortune.new($db.absolute);
say 'records  : ', $f.fortune.map(*.raku).join(' ');
say 'delimiter: ', $f.delimit.raku;
say 'order    : ', $f.order;
say 'rot13    : ', $f.rot13;
say '';
strfile($db.absolute);
say 'strfile wrote the index : ', $dir.add('sayings.dat').e;
say '  size                  : ', $dir.add('sayings.dat').s, ' bytes';
say '';
my $g = Fortune.new($db.absolute);
say 'reading again picks the index up: version=', $g.version,
    ' delimit=', $g.delimit.raku;

# Output:
#     records  : "alpha" "beta" "gamma" ""
#     delimiter: "\%"
#     order    : FORTUNE_UNORDER
#     rot13    : False
#     
#     strfile wrote the index : True
#       size                  : 64 bytes
#     
#     reading again picks the index up: version=1 delimit="\%"
