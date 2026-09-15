#!/usr/bin/env rakupp
# Math::SelfDescriptiveNumbers — The one thing to know
# https://raku.online/modules/math-selfdescriptivenumbers/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Math::SelfDescriptiveNumbers
#     rakupp 03-int-vs-str.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::SelfDescriptiveNumbers;

say 'the Str form compares the digit string you gave:';
say '  is-self-descriptive("1210", 4) = ', is-self-descriptive('1210', 4);
say '';
say 'the Int form calls $number.base($base) FIRST:';
say '  is-self-descriptive(1210, 4)   = ', is-self-descriptive(1210, 4);
say '  1210.base(4)                   = ', 1210.base(4);
say '';
say 'so the Int form wants the numeric VALUE:';
say '  "1210" in base 4 is ', '1210'.parse-base(4), ' in decimal';
say '  is-self-descriptive(100, 4)    = ', is-self-descriptive(100, 4);
say '';
say 'both calls are legal, neither warns, and the one that LOOKS right is';
say 'the one that returns the wrong answer. Use the Str form.';

# Output:
#     the Str form compares the digit string you gave:
#       is-self-descriptive("1210", 4) = True
#     
#     the Int form calls $number.base($base) FIRST:
#       is-self-descriptive(1210, 4)   = False
#       1210.base(4)                   = 102322
#     
#     so the Int form wants the numeric VALUE:
#       "1210" in base 4 is 100 in decimal
#       is-self-descriptive(100, 4)    = True
#     
#     both calls are legal, neither warns, and the one that LOOKS right is
#     the one that returns the wrong answer. Use the Str form.
