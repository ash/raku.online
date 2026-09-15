#!/usr/bin/env rakupp
# P5getnetbyname — Misses
# https://raku.online/modules/p5getnetbyname/#misses
#
# Install what it needs, then run it:
#     rakupp install P5getnetbyname
#     rakupp 02-miss.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getnetbyname;

say 'unknown name   -> ', getnetbyname('nosuchnet-xyzzy').elems, ' fields';
say 'unknown scalar -> ', getnetbyname(Scalar, 'nosuchnet-xyzzy').defined;
say 'bad address    -> ', getnetbyaddr(4294967295, 2).elems, ' fields';
say 'bad addrtype   -> ', getnetbyaddr(127, 99).elems, ' fields';

# Output:
#     unknown name   -> 0 fields
#     unknown scalar -> False
#     bad address    -> 0 fields
#     bad addrtype   -> 0 fields
