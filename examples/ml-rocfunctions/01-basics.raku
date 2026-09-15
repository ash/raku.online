#!/usr/bin/env rakupp
# ML::ROCFunctions — From labels to rates
# https://raku.online/modules/ml-rocfunctions/#from-labels-to-rates
#
# Install what it needs, then run it:
#     rakupp install ML::ROCFunctions
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use ML::ROCFunctions;

my @actual    = <T T T T T T F F F F F F F F>;
my @predicted = <T T T T F F T T F F F F F F>;
my %roc = to-roc-hash('T', 'F', @actual, @predicted);
say 'confusion : ', %roc.keys.sort.map({ "$_={%roc{$_}}" }).join('  ');
say '';
for <TPR SPC PPV NPV FPR FDR FNR ACC FOR F1 MCC> -> $f {
    say sprintf('  %-4s %s', $f, ::("&$f")(%roc).round(0.0001));
}

# Output:
#     confusion : FalseNegative=2  FalsePositive=2  TrueNegative=6  TruePositive=4
#     
#       TPR  0.6667
#       SPC  0.75
#       PPV  0.6667
#       NPV  0.75
#       FPR  0.25
#       FDR  0.3333
#       FNR  0.3333
#       ACC  0.7143
#       FOR  0.25
#       F1   0.6667
#       MCC  0.4181
