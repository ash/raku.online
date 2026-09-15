#!/usr/bin/env rakupp
# Text::Spintax — Where the two engines differ
# https://raku.online/modules/text-spintax/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Text::Spintax
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Spintax;

# the guard above makes the two engines agree
sub spin(Str $src) {
    my $tree = try Text::Spintax.parse($src);
    return Nil unless $tree.defined;
    $tree
}
for 'a {b|c} d', 'a}b', '' -> $src {
    my $t = spin($src);
    say sprintf('  %-12s -> %s', $src.raku, $t.defined ?? 'parsed' !! 'rejected');
}
say '';
say 'two dead ends inside the grammar, for the curious: `rule chunk` is';
say 'never reached from TOP, and it references <opt>, which is not';
say 'declared anywhere. Rakudo would raise a method-not-found if anything';
say 'reached it; Raku++ fails the match silently, which is why nobody';
say 'noticed. Grammar introspection differs too — $g.^methods(:local)';
say 'lists all eleven rules on Rakudo and nothing on Raku++.';

# Output:
#       "a \{b|c} d" -> parsed
#       "a}b"        -> rejected
#       ""           -> parsed
#     
#     two dead ends inside the grammar, for the curious: `rule chunk` is
#     never reached from TOP, and it references <opt>, which is not
#     declared anywhere. Rakudo would raise a method-not-found if anything
#     reached it; Raku++ fails the match silently, which is why nobody
#     noticed. Grammar introspection differs too — $g.^methods(:local)
#     lists all eleven rules on Rakudo and nothing on Raku++.
