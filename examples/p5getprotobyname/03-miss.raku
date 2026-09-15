#!/usr/bin/env rakupp
# P5getprotobyname — Misses
# https://raku.online/modules/p5getprotobyname/#misses
#
# Install what it needs, then run it:
#     rakupp install P5getprotobyname
#     rakupp 03-miss.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getprotobyname;

say 'unknown name   -> ', getprotobyname('nosuchproto-xyzzy').elems, ' fields';
say 'unknown number -> ', getprotobynumber(255).elems, ' fields';
say 'negative       -> ', getprotobynumber(-1).elems, ' fields';
say '';
say 'the scalar forms return an undefined value, not an exception:';
say '  ', getprotobyname(Scalar, 'nosuchproto-xyzzy').defined;

# Output:
#     unknown name   -> 0 fields
#     unknown number -> 0 fields
#     negative       -> 0 fields
#     
#     the scalar forms return an undefined value, not an exception:
#       False
