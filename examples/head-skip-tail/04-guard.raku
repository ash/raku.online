#!/usr/bin/env rakupp
# head-skip-tail — Where the two engines differ
# https://raku.online/modules/head-skip-tail/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install head-skip-tail
#     rakupp 04-guard.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use head-skip-tail;

say 'on Rakudo the guard fires and `use head-skip-tail` is a complete';
say 'no-op; the subs you call are the core ones.';
say '';
say 'on Raku++ the guard misfires and the module installs its own, which';
say 'is the reason the collision above matters there and not on Rakudo.';
say '';
say 'either way the ANSWERS are identical — the example output on this';
say 'page is byte-for-byte the same on both engines. Only which routine';
say 'you are calling differs:';
my @a = ^10;
say '  head(3, @a) = ', head(3, @a);
say '  skip(7, @a) = ', skip(7, @a);
say '  tail(3, @a) = ', tail(3, @a);
say '';
say 'so: keep the `use`. It costs nothing where the core has the subs and';
say 'it is the only thing standing between you and Test::skip where it';
say 'does not.';

# Output:
#     on Rakudo the guard fires and `use head-skip-tail` is a complete
#     no-op; the subs you call are the core ones.
#     
#     on Raku++ the guard misfires and the module installs its own, which
#     is the reason the collision above matters there and not on Rakudo.
#     
#     either way the ANSWERS are identical — the example output on this
#     page is byte-for-byte the same on both engines. Only which routine
#     you are calling differs:
#       head(3, @a) = (0 1 2)
#       skip(7, @a) = (7 8 9)
#       tail(3, @a) = (7 8 9)
#     
#     so: keep the `use`. It costs nothing where the core has the subs and
#     it is the only thing standing between you and Test::skip where it
#     does not.
