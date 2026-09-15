#!/usr/bin/env rakupp
# Operator::feq — The threshold
# https://raku.online/modules/operator-feq/#the-threshold
#
# Install what it needs, then run it:
#     rakupp install Operator::feq
#     rakupp 02-threshold.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Operator::feq;

for 0, 0.1, 0.5, 1 -> $t {
    my $*FEQTHRESHOLD = $t;
    say sprintf('  threshold %-4s : "cat" feq "cot" = %-6s   "cat" feq "cat" = %s',
                $t, ('cat' feq 'cot'), ('cat' feq 'cat'));
}
say '';
say 'threshold 0 makes EVERYTHING unequal, including a string and itself —';
say 'the guard clause returns False before comparing. The intuitive';
say '"exact match only" setting does the opposite of what it looks like.';

# Output:
#       threshold 0    : "cat" feq "cot" = False    "cat" feq "cat" = False
#       threshold 0.1  : "cat" feq "cot" = False    "cat" feq "cat" = True
#       threshold 0.5  : "cat" feq "cot" = True     "cat" feq "cat" = True
#       threshold 1    : "cat" feq "cot" = True     "cat" feq "cat" = True
#     
#     threshold 0 makes EVERYTHING unequal, including a string and itself —
#     the guard clause returns False before comparing. The intuitive
#     "exact match only" setting does the opposite of what it looks like.
