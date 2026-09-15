#!/usr/bin/env rakupp
# P5getpwnam — Looking a user up
# https://raku.online/modules/p5getpwnam/#looking-a-user-up
#
# Install what it needs, then run it:
#     rakupp install P5getpwnam
#     rakupp 01-lookup.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getpwnam;

# uid 0 exists on every POSIX machine. Nothing here prints a name,
# a home directory or a shell.
my @p = getpwuid(0);
say 'fields            : ', @p.elems;
say 'name is defined   : ', @p[0].defined;
say 'uid               : ', @p[2];
say 'gid is an Int     : ', @p[3] ~~ Int;
say 'home looks absolute : ', @p[7].starts-with('/');
say 'shell is defined  : ', @p[8].defined;
say '';
say 'scalar by uid gives the name : ', getpwuid(Scalar, 0) eqv @p[0];
say 'scalar by name gives the uid : ', getpwnam(Scalar, @p[0]);

# Output:
#     fields            : 10
#     name is defined   : True
#     uid               : 0
#     gid is an Int     : True
#     home looks absolute : True
#     shell is defined  : True
#     
#     scalar by uid gives the name : True
#     scalar by name gives the uid : 0
