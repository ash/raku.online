#!/usr/bin/env rakupp
# Math::BijectiveBase — Two more alphabet surprises
# https://raku.online/modules/math-bijectivebase/#two-more-alphabet-surprises
#
# Install what it needs, then run it:
#     rakupp install Math::BijectiveBase
#     rakupp 03-alphabets.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::BijectiveBase;

say 'base 62 is A..Z, a..z, 0..9 — NOT the usual base62 order:';
for 1, 27, 53, 62, 63 -> $n {
    say sprintf('  %3d -> %s', $n, to-bijective62($n));
}
say '';
say 'and a non-distinct alphabet silently breaks the round trip, because';
say 'the decoder resolves a symbol to its LAST index:';
say '  to-bijectivebase(5, <a b a>)              = ', to-bijectivebase(5, <a b a>);
say '  from-bijectivebase(that, <a b a>)         = ',
    from-bijectivebase(to-bijectivebase(5, <a b a>), <a b a>);
say '  from-bijectivebase("a", <a b a>)          = ',
    from-bijectivebase('a', <a b a>);
say '';
say 'decode also has a value encode cannot produce:';
say '  from-bijective26("") = ', from-bijective26('');
my $z = try to-bijective26(0);
say '  to-bijective26(0)    = ', $! ?? 'refused (where * > 0)' !! $z;

# Output:
#     base 62 is A..Z, a..z, 0..9 — NOT the usual base62 order:
#         1 -> A
#        27 -> a
#        53 -> 0
#        62 -> 9
#        63 -> AA
#     
#     and a non-distinct alphabet silently breaks the round trip, because
#     the decoder resolves a symbol to its LAST index:
#       to-bijectivebase(5, <a b a>)              = ab
#       from-bijectivebase(that, <a b a>)         = 11
#       from-bijectivebase("a", <a b a>)          = 3
#     
#     decode also has a value encode cannot produce:
#       from-bijective26("") = 0
#       to-bijective26(0)    = refused (where * > 0)
