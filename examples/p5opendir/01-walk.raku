#!/usr/bin/env rakupp
# P5opendir — Walking a directory
# https://raku.online/modules/p5opendir/#walking-a-directory
#
# Install what it needs, then run it:
#     rakupp install P5opendir
#     rakupp 01-walk.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5opendir;

my $fixture = $*TMPDIR.add("p5od-{$*PID}");
$fixture.mkdir;
LEAVE { .unlink for $fixture.dir; $fixture.rmdir }
$fixture.add($_).spurt('x') for <alpha beta gamma>;

my $dh;
say 'opendir returned : ', opendir($dh, $fixture.Str);
say 'handle type      : ', $dh.^name;
say 'it stringifies to the path : ', $dh.Str eq $fixture.Str;
say '';
say 'telldir at the start : ', telldir($dh);
say 'first entry  : ', readdir(Scalar, $dh);
say 'second entry : ', readdir(Scalar, $dh);
say 'telldir now  : ', telldir($dh);
rewinddir($dh);
say 'after rewinddir : ', telldir($dh);
say '';
say 'closedir : ', closedir($dh);

# Output:
#     opendir returned : True
#     handle type      : DIRHANDLE
#     it stringifies to the path : True
#     
#     telldir at the start : 0
#     first entry  : .
#     second entry : ..
#     telldir now  : 2
#     after rewinddir : 0
#     
#     closedir : True
