#!/usr/bin/env rakupp
# Math::SpecialFunctions — The one thing to know
# https://raku.online/modules/math-specialfunctions/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Math::SpecialFunctions
#     rakupp 02-bernoulli.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::SpecialFunctions;

for 2..9 -> $n {
    say $n, ' -> ', bernoulli-b($n).nude.join('/'),
        ($n %% 2 ?? '' !! '   (should be 0)');
}
say bernoulli-b(3) == bernoulli-b(2);
say bernoulli-b(7) == bernoulli-b(6);

# Output:
#     2 -> 1/6
#     3 -> 1/6   (should be 0)
#     4 -> -1/30
#     5 -> -1/30   (should be 0)
#     6 -> 1/42
#     7 -> 1/42   (should be 0)
#     8 -> -1/30
#     9 -> -1/30   (should be 0)
#     True
#     True
