#!/usr/bin/env rakupp
# allow-no — It leaks, process-wide
# https://raku.online/modules/allow-no/#it-leaks-process-wide
#
# Install what it needs, then run it:
#     rakupp install allow-no
#     rakupp 03-leak.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use allow-no;

say 'this is not a lexical pragma. It is an INIT block that mutates one';
say 'process-global array, once.';
say '';
say 'so any DEPENDENCY anywhere in your tree that does `use allow-no`';
say 'changes how YOUR command line parses, and there is no opt-out —';
say 'unlike the core feature, which is opt-in per program.';
say '';
say 'if you want it, say so yourself rather than inheriting it:';
say '  my %*SUB-MAIN-OPTS = :allow-no;   # Rakudo';
say '  use allow-no;                     # both engines';

# Output:
#     this is not a lexical pragma. It is an INIT block that mutates one
#     process-global array, once.
#     
#     so any DEPENDENCY anywhere in your tree that does `use allow-no`
#     changes how YOUR command line parses, and there is no opt-out —
#     unlike the core feature, which is opt-in per program.
#     
#     if you want it, say so yourself rather than inheriting it:
#       my %*SUB-MAIN-OPTS = :allow-no;   # Rakudo
#       use allow-no;                     # both engines
