#!/usr/bin/env rakupp
# ML::ROCFunctions — AUROC
# https://raku.online/modules/ml-rocfunctions/#auroc
#
# Install what it needs, then run it:
#     rakupp install ML::ROCFunctions
#     rakupp 02-auroc.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use ML::ROCFunctions;

# one confusion hash per threshold, ordered from strict to permissive
my @rocs =
    %( TruePositive => 0, FalsePositive => 0, TrueNegative => 8, FalseNegative => 6 ),
    %( TruePositive => 3, FalsePositive => 1, TrueNegative => 7, FalseNegative => 3 ),
    %( TruePositive => 5, FalsePositive => 3, TrueNegative => 5, FalseNegative => 1 ),
    %( TruePositive => 6, FalsePositive => 8, TrueNegative => 0, FalseNegative => 0 );

say 'AUROC(@rocs)     : ', AUROC(@rocs).round(0.0001);
say '';
say 'a perfect classifier and a coin flip:';
say '  perfect : ', AUROC([
    %( TruePositive => 0, FalsePositive => 0, TrueNegative => 8, FalseNegative => 6 ),
    %( TruePositive => 6, FalsePositive => 0, TrueNegative => 8, FalseNegative => 0 ),
    %( TruePositive => 6, FalsePositive => 8, TrueNegative => 0, FalseNegative => 0 )]);
say '  empty   : ', AUROC([]), '   <- returned, not refused';
say '';
my $r = try AUROC(@rocs[0]);
say '  a single hash rather than a list -> ', $! ?? 'refused' !! 'accepted';

# Output:
#     AUROC(@rocs)     : 0.7708
#     
#     a perfect classifier and a coin flip:
#       perfect : 1
#       empty   : 0.5   <- returned, not refused
#     
#       a single hash rather than a list -> refused
