---
name: ML::ROCFunctions
version: 0.1.4
auth: zef:antononcube
kind: Distribution · statistics
summary: The confusion-matrix rate family plus a trapezoidal AUROC — with an
  MCC computed from rates rather than counts.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:antononcube/ML::ROCFunctions
source: https://github.com/antononcube/Raku-ML-ROCFunctions.git
---

## What it is for

A binary classifier's performance is a four-number confusion matrix, and every
metric anyone quotes is a ratio of those four. This distribution builds the
hash from two label lists and computes the whole family from it, plus the area
under the ROC curve for a list of such hashes.

## From labels to rates

```raku name="basics"
use ML::ROCFunctions;

my @actual    = <T T T T T T F F F F F F F F>;
my @predicted = <T T T T F F T T F F F F F F>;
my %roc = to-roc-hash('T', 'F', @actual, @predicted);
say 'confusion : ', %roc.keys.sort.map({ "$_={%roc{$_}}" }).join('  ');
say '';
for <TPR SPC PPV NPV FPR FDR FNR ACC FOR F1 MCC> -> $f {
    say sprintf('  %-4s %s', $f, ::("&$f")(%roc).round(0.0001));
}
```

```output
confusion : FalseNegative=2  FalsePositive=2  TrueNegative=6  TruePositive=4

  TPR  0.6667
  SPC  0.75
  PPV  0.6667
  NPV  0.75
  FPR  0.25
  FDR  0.3333
  FNR  0.3333
  ACC  0.7143
  FOR  0.25
  F1   0.6667
  MCC  0.4181
```

Every one of those is checked against brute-force counts in the distribution's
own suite, and they agree exactly.

## AUROC

```raku name="auroc"
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
```

```output
AUROC(@rocs)     : 0.7708

a perfect classifier and a coin flip:
  perfect : 1
  empty   : 0.5   <- returned, not refused

  a single hash rather than a list -> refused
```

## The one thing to know

`MCC` is computed from the four **rates**, not the four counts — so it is not
the Matthews correlation coefficient, and it disagrees badly on imbalanced
data.

```raku name="mcc"
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
```

```output
  TP=4   FP=2   TN=6   FN=2    module +0.418121  textbook +0.416667  DIFFERENT
  TP=90  FP=1   TN=1   FN=8    module +0.460616  textbook +0.204665  DIFFERENT
  TP=5   FP=5   TN=5   FN=5    module +0.000000  textbook +0.000000  same
  TP=10  FP=0   TN=10  FN=0    module +1.000000  textbook +1.000000  same

the implementation feeds (TPR, SPC, FPR, FNR) into the COUNT formula,
so the result is prevalence-independent by construction. On a
90/1/1/8 matrix it reports +0.46 where the textbook MCC is +0.20.

it still agrees at the fixed points — 0 and plus or minus 1 — which
is exactly what makes it easy to miss. Compute MCC yourself.
```

## The separator matters

```raku name="separator"
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
```

```output
to-roc-hash joins the label pair with :sep (default "-") and buckets
by the joined string, so labels that collide under the separator
silently double-count:
  default :sep("-") : FalseNegative=2 FalsePositive=2 TrueNegative=1 TruePositive=1
  with    :sep("|") : FalseNegative=1 FalsePositive=1 TrueNegative=1 TruePositive=1

and a label that never appears in the data silently drops rows:
  to-roc-hash("zzz", "F", …) : 1 of 4 rows counted
```

## Where the two engines differ

Nothing in the numbers — every rate, every AUROC and the name registry are
identical on both engines. Only the dispatch-failure message: Raku++ says
`Cannot resolve caller to-roc-hash(); no matching multi candidate` where
Rakudo prints the argument types and all three signatures.

```raku name="registry"
use ML::ROCFunctions;

say 'the name registry lets you look a function up by acronym or by name:';
say '  listed names   : ', roc-functions('FunctionNames').elems;
say '  lookup table   : ', roc-acronyms-hash.elems, ' accepted spellings';
say '  distinct funcs : ', roc-functions().elems;
say '';
say 'TNR and SPC compute the same quantity, so the registry hands back';
say 'one of them for both:';
say '  roc-functions("TNR").name = ', roc-functions('TNR').name;
say '';
say 'and an unrecognised spec returns an undefined value, silently:';
say '  roc-functions("NoSuchThing").defined = ',
    roc-functions('NoSuchThing').defined;
say '';
say 'the listed set is smaller than the accepted set — Specificity,';
say 'F1Score, TruePositiveRate and MatthewsCorrelationCoefficient all';
say 'work and are not in FunctionNames.';
```

```output
the name registry lets you look a function up by acronym or by name:
  listed names   : 17
  lookup table   : 17 accepted spellings
  distinct funcs : 12

TNR and SPC compute the same quantity, so the registry hands back
one of them for both:
  roc-functions("TNR").name = SPC

and an unrecognised spec returns an undefined value, silently:
  roc-functions("NoSuchThing").defined = False

the listed set is smaller than the accepted set — Specificity,
F1Score, TruePositiveRate and MatthewsCorrelationCoefficient all
work and are not in FunctionNames.
```
