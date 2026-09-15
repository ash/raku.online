#!/usr/bin/env rakupp
# Math::SelfDescriptiveNumbers — Where the two engines differ
# https://raku.online/modules/math-selfdescriptivenumbers/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Math::SelfDescriptiveNumbers
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::SelfDescriptiveNumbers;

for 0, -1, 37, 36 -> $b {
    my $r = try self-descriptive-numbers-of($b);
    say sprintf('  base %3d -> %s', $b,
                $! ?? 'X::OutOfRange from .base' !! ($r.elems ?? $r.raku !! '(none)'));
}
say '';
say 'note base 1 returns () happily while is-self-descriptive(10, 1) dies,';
say 'so the two halves of the API disagree about what base 1 means.';
say '';
say 'the two table subs give you everything at once:';
say '  self-descriptive-numbers().elems     = ', self-descriptive-numbers().elems;
my @dec = self-descriptive-numbers-dec();
say '  …-dec() parses them back, e.g. base 10 -> ',
    @dec.first({ .[0] == 10 })[1].list.raku;

# Output:
#       base   0 -> X::OutOfRange from .base
#       base  -1 -> X::OutOfRange from .base
#       base  37 -> X::OutOfRange from .base
#       base  36 -> "W21000000000000000000000000000001000"
#     
#     note base 1 returns () happily while is-self-descriptive(10, 1) dies,
#     so the two halves of the API disagree about what base 1 means.
#     
#     the two table subs give you everything at once:
#       self-descriptive-numbers().elems     = 36
#       …-dec() parses them back, e.g. base 10 -> (6210001000,)
