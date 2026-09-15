#!/usr/bin/env rakupp
# ML::ROCFunctions — The one thing to know
# https://raku.online/modules/ml-rocfunctions/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install ML::ROCFunctions
#     rakupp 03-mcc.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use ML::ROCFunctions;

sub textbook(%r) {
    my ($tp, $fp, $tn, $fn) =
        %r<TruePositive FalsePositive TrueNegative FalseNegative>;
    my $d = sqrt(($tp + $fp) * ($tp + $fn) * ($tn + $fp) * ($tn + $fn));
    $d == 0 ?? 0 !! ($tp * $tn - $fp * $fn) / $d
}

for (4, 2, 6, 2), (90, 1, 1, 8), (5, 5, 5, 5), (10, 0, 10, 0) -> ($tp, $fp, $tn, $fn) {
    my %r = TruePositive => $tp, FalsePositive => $fp,
            TrueNegative => $tn, FalseNegative => $fn;
    say sprintf('  TP=%-3d FP=%-3d TN=%-3d FN=%-3d  module %+.6f  textbook %+.6f  %s',
                $tp, $fp, $tn, $fn, MCC(%r), textbook(%r),
                (MCC(%r) - textbook(%r)).abs < 1e-9 ?? 'same' !! 'DIFFERENT');
}
say '';
say 'the implementation feeds (TPR, SPC, FPR, FNR) into the COUNT formula,';
say 'so the result is prevalence-independent by construction. On a';
say '90/1/1/8 matrix it reports +0.46 where the textbook MCC is +0.20.';
say '';
say 'it still agrees at the fixed points — 0 and plus or minus 1 — which';
say 'is exactly what makes it easy to miss. Compute MCC yourself.';

# Output:
#       TP=4   FP=2   TN=6   FN=2    module +0.418121  textbook +0.416667  DIFFERENT
#       TP=90  FP=1   TN=1   FN=8    module +0.460616  textbook +0.204665  DIFFERENT
#       TP=5   FP=5   TN=5   FN=5    module +0.000000  textbook +0.000000  same
#       TP=10  FP=0   TN=10  FN=0    module +1.000000  textbook +1.000000  same
#     
#     the implementation feeds (TPR, SPC, FPR, FNR) into the COUNT formula,
#     so the result is prevalence-independent by construction. On a
#     90/1/1/8 matrix it reports +0.46 where the textbook MCC is +0.20.
#     
#     it still agrees at the fixed points — 0 and plus or minus 1 — which
#     is exactly what makes it easy to miss. Compute MCC yourself.
