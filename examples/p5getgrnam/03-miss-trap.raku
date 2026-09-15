#!/usr/bin/env rakupp
# P5getgrnam — The one thing to know
# https://raku.online/modules/p5getgrnam/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install P5getgrnam
#     rakupp 03-miss-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getgrnam;

my @miss = getgrnam('nosuchgroup-xyzzy');
say 'the list form has ', @miss.elems, ' elements';
say 'the scalar form is defined : ', getgrnam(Scalar, 'nosuchgroup-xyzzy').defined;
say 'and nothing was thrown';
say '';
say 'so the natural Perl transcription leaves every variable undefined:';
my ($name, $passwd, $gid, $members) = getgrnam('nosuchgroup-xyzzy');
say '  gid after a failed lookup : ', $gid.defined ?? $gid !! 'undefined';
say '';
say 'the test has to be on the LIST:';
say '  found : ', ?getgrnam('nosuchgroup-xyzzy').elems;

# Output:
#     the list form has 0 elements
#     the scalar form is defined : False
#     and nothing was thrown
#     
#     so the natural Perl transcription leaves every variable undefined:
#       gid after a failed lookup : undefined
#     
#     the test has to be on the LIST:
#       found : False
