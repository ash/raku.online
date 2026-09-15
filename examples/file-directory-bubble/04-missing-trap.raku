#!/usr/bin/env rakupp
# File::Directory::Bubble — The one thing to know
# https://raku.online/modules/file-directory-bubble/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install File::Directory::Bubble
#     rakupp 04-missing-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Directory::Bubble;

my $root = $*TMPDIR.add("bb4-{$*PID}");
$root.mkdir;
LEAVE { run 'rm', '-rf', $root.Str }

my $missing = $root.add('no-such-thing');
say 'the path exists            : ', $missing.e;
my $d = bbDown($missing);
say 'bbDown returned a list     : ', $d ~~ Positional;
say 'it is defined              : ', $d.so ~~ Bool;
my @loop;
for $d { @loop.push('one iteration') }
say 'for bbDown($missing) {...} runs : ', @loop.elems, ' time(s)';
say '';
say 'so the guard has to be your own:';
say '  ', $missing.e ?? 'walk it' !! 'skip it';

# Output:
#     the path exists            : False
#     bbDown returned a list     : False
#     it is defined              : True
#     for bbDown($missing) {...} runs : 1 time(s)
#     
#     so the guard has to be your own:
#       skip it
