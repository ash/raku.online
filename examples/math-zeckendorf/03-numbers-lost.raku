#!/usr/bin/env rakupp
# Math::Zeckendorf — The one thing to know
# https://raku.online/modules/math-zeckendorf/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Math::Zeckendorf
#     rakupp 03-numbers-lost.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::Zeckendorf;

say 'a bare Int honours the flag:';
say '  zeckendorf-representation(12, :numbers)   = ',
    zeckendorf-representation(12, :numbers).raku;
say '';
say 'a ONE-ELEMENT list does not:';
say '  zeckendorf-representation((12,), :numbers) = ',
    zeckendorf-representation((12,), :numbers).raku;
say '';
say 'nor does a longer one:';
say '  zeckendorf-representation((4, 12), :numbers) = ',
    zeckendorf-representation((4, 12), :numbers).raku;
say '';
say 'the list candidate is  @nums>>.&zeckendorf-representation.List  —';
say 'it never forwards the named argument. The call succeeds, returns a';
say 'plausible nested structure, and gives you DIGITS where you asked for';
say 'Fibonacci numbers. Since both are arrays of small integers, a';
say 'downstream .sum produces a number rather than an error.';
say '';
say 'map it yourself:';
say '  ', (4, 12).map({ zeckendorf-representation($_, :numbers) }).raku;

# Output:
#     a bare Int honours the flag:
#       zeckendorf-representation(12, :numbers)   = [8, 3, 1]
#     
#     a ONE-ELEMENT list does not:
#       zeckendorf-representation((12,), :numbers) = ([1, 0, 1, 0, 1],)
#     
#     nor does a longer one:
#       zeckendorf-representation((4, 12), :numbers) = ([1, 0, 1], [1, 0, 1, 0, 1])
#     
#     the list candidate is  @nums>>.&zeckendorf-representation.List  —
#     it never forwards the named argument. The call succeeds, returns a
#     plausible nested structure, and gives you DIGITS where you asked for
#     Fibonacci numbers. Since both are arrays of small integers, a
#     downstream .sum produces a number rather than an error.
#     
#     map it yourself:
#       ([3, 1], [8, 3, 1]).Seq
