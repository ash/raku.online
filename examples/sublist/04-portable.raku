#!/usr/bin/env rakupp
# sublist — Where the two engines differ
# https://raku.online/modules/sublist/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install sublist
#     rakupp 04-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use sublist;

# normalise the result and both engines agree
sub indices-of(@needle, @hay) { (sublist::indices(@needle, @hay) // ()).List }

for (<a b>, <x a b c a b>), (<z z>, <x a b>) -> (@n, @h) {
    say sprintf('  %-10s in %-16s -> %s',
                @n.raku, @h.raku, indices-of(@n, @h).raku);
}
say '';
say 'an EMPTY needle is the other divergence — do not pass one:';
say 'indexing past the end of a List bound to an @-parameter gives Any on';
say 'Raku++ and Nil on Rakudo, and the grep that follows then matches';
say 'EVERYTHING on one engine and nothing on the other. Guard against an';
say 'empty needle at the call site.';

# Output:
#       ("a", "b") in ("x", "a", "b", "c", "a", "b") -> (1, 4)
#       ("z", "z") in ("x", "a", "b")  -> ()
#     
#     an EMPTY needle is the other divergence — do not pass one:
#     indexing past the end of a List bound to an @-parameter gives Any on
#     Raku++ and Nil on Rakudo, and the grep that follows then matches
#     EVERYTHING on one engine and nothing on the other. Guard against an
#     empty needle at the call site.
