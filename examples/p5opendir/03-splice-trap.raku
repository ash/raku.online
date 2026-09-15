#!/usr/bin/env rakupp
# P5opendir — The one thing to know
# https://raku.online/modules/p5opendir/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install P5opendir
#     rakupp 03-splice-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5opendir;

my $fixture = $*TMPDIR.add("p5od3-{$*PID}");
$fixture.mkdir;
LEAVE { .unlink for $fixture.dir; $fixture.rmdir }
$fixture.add($_).spurt('x') for <alpha beta>;

my $dh;
opendir($dh, $fixture.Str);
say 'elems before reading : ', $dh.elems;
say '';
say 'the Scalar form is non-destructive:';
say '  one   : ', readdir(Scalar, $dh);
rewinddir($dh);
say '  again : ', readdir(Scalar, $dh);
say '  elems : ', $dh.elems;
say '';
say 'the list form splices the names OUT:';
my @all = readdir($dh);
say '  got   : ', @all.sort.join(' ');
say '  elems : ', $dh.elems;
rewinddir($dh);
say '  after rewinddir, readdir gives : ', readdir($dh).elems, ' entries';
say '  and readdir(Scalar, ...) gives : ', readdir(Scalar, $dh).raku;

# Output:
#     elems before reading : 4
#     
#     the Scalar form is non-destructive:
#       one   : .
#       again : .
#       elems : 4
#     
#     the list form splices the names OUT:
#       got   : .. alpha beta
#       elems : 1
#       after rewinddir, readdir gives : 1 entries
#       and readdir(Scalar, ...) gives : Nil
