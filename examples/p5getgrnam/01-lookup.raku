#!/usr/bin/env rakupp
# P5getgrnam — Looking a group up
# https://raku.online/modules/p5getgrnam/#looking-a-group-up
#
# Install what it needs, then run it:
#     rakupp install P5getgrnam
#     rakupp 01-lookup.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getgrnam;

# gid 0 is the superuser group on every POSIX machine; its NAME is not
# portable (wheel on BSD, root on Linux), so this checks shape.
my @g = getgrgid(0);
say 'fields             : ', @g.elems;
say 'name is a non-empty Str : ', @g[0].defined && @g[0].chars > 0;
say 'gid                : ', @g[2];
say 'members field is a : ', @g[3].^name;
say '';
say 'scalar by gid gives the name : ', getgrgid(Scalar, 0) eqv @g[0];
say 'scalar by name gives the gid : ', getgrnam(Scalar, @g[0]);

# Output:
#     fields             : 4
#     name is a non-empty Str : True
#     gid                : 0
#     members field is a : Str
#     
#     scalar by gid gives the name : True
#     scalar by name gives the gid : 0
