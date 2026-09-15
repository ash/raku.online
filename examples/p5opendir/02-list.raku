#!/usr/bin/env rakupp
# P5opendir — The list form
# https://raku.online/modules/p5opendir/#the-list-form
#
# Install what it needs, then run it:
#     rakupp install P5opendir
#     rakupp 02-list.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5opendir;

my $fixture = $*TMPDIR.add("p5od2-{$*PID}");
$fixture.mkdir;
LEAVE { .unlink for $fixture.dir; $fixture.rmdir }
$fixture.add($_).spurt('x') for <alpha beta>;

my $dh;
opendir($dh, $fixture.Str);
say 'everything still to come : ', readdir($dh).sort.join(' ');
say 'and again                : ', readdir($dh).elems, ' entries';

# Output:
#     everything still to come : . .. alpha beta
#     and again                : 0 entries
