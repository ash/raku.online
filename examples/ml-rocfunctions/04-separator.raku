#!/usr/bin/env rakupp
# ML::ROCFunctions — The separator matters
# https://raku.online/modules/ml-rocfunctions/#the-separator-matters
#
# Install what it needs, then run it:
#     rakupp install ML::ROCFunctions
#     rakupp 04-separator.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use ML::ROCFunctions;

say 'to-roc-hash joins the label pair with :sep (default "-") and buckets';
say 'by the joined string, so labels that collide under the separator';
say 'silently double-count:';
my @a = <a a a-a a-a>;
my @p = <a a-a a a-a>;
say '  default :sep("-") : ',
    to-roc-hash('a', 'a-a', @a, @p).keys.sort.map({ "$_={to-roc-hash('a','a-a',@a,@p){$_}}" }).join(' ');
say '  with    :sep("|") : ',
    to-roc-hash('a', 'a-a', @a, @p, sep => '|').keys.sort
        .map({ "$_={to-roc-hash('a','a-a',@a,@p,sep=>'|'){$_}}" }).join(' ');
say '';
say 'and a label that never appears in the data silently drops rows:';
my %z = to-roc-hash('zzz', 'F', <T T F F>, <T F T F>);
say '  to-roc-hash("zzz", "F", …) : ', %z.values.sum, ' of 4 rows counted';

# Output:
#     to-roc-hash joins the label pair with :sep (default "-") and buckets
#     by the joined string, so labels that collide under the separator
#     silently double-count:
#       default :sep("-") : FalseNegative=2 FalsePositive=2 TrueNegative=1 TruePositive=1
#       with    :sep("|") : FalseNegative=1 FalsePositive=1 TrueNegative=1 TruePositive=1
#     
#     and a label that never appears in the data silently drops rows:
#       to-roc-hash("zzz", "F", …) : 1 of 4 rows counted
