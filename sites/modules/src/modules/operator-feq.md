---
name: Operator::feq
version: 0.1.2
auth: zef:tony-o
kind: Distribution · operators
summary: An infix `feq` for fuzzy equality — on edit distance over the
  stringified operands, which is not what "fuzzy equals" suggests.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: none stated
depends: Text::Levenshtein::Damerau
raku-land: https://raku.land/zef:tony-o/Operator::feq
source: git://github.com/tony-o/perl6-operator-feq.git
---

## What it is for

"Close enough" comparison, spelled as an operator so it reads like `==`. The
rule is a **relative edit distance**: two operands are `feq` when their
Damerau-Levenshtein distance, divided by the longer one's length, is at or
under a threshold that defaults to 0.1.

## The rule

```raku name="basics"
use Operator::feq;

for <abcdefghij abcdefghij>, <abcdefghij abcdefghik>,
    <abcdefghi abcdefghz>, <cat cat>, <cat cot>,
    <abcdefghij abcdefghji> -> ($a, $b) {
    say sprintf('  %-12s feq %-12s = %s', $a.raku, $b.raku, ($a feq $b));
}
say '';
say 'one typo in ten is 0.1, which is at the threshold, so it passes.';
say 'one typo in nine is over it, so it fails. A transposition scores 2,';
say 'not 1.';
say '';
say 'the consequence: for any string shorter than ten characters,';
say 'feq is exactly eq.';
```

```output
  "abcdefghij" feq "abcdefghij" = True
  "abcdefghij" feq "abcdefghik" = True
  "abcdefghi"  feq "abcdefghz"  = False
  "cat"        feq "cat"        = True
  "cat"        feq "cot"        = False
  "abcdefghij" feq "abcdefghji" = False

one typo in ten is 0.1, which is at the threshold, so it passes.
one typo in nine is over it, so it fails. A transposition scores 2,
not 1.

the consequence: for any string shorter than ten characters,
feq is exactly eq.
```

## The threshold

```raku name="threshold"
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
```

```output
  threshold 0    : "cat" feq "cot" = False    "cat" feq "cat" = False
  threshold 0.1  : "cat" feq "cot" = False    "cat" feq "cat" = True
  threshold 0.5  : "cat" feq "cot" = True     "cat" feq "cat" = True
  threshold 1    : "cat" feq "cot" = True     "cat" feq "cat" = True

threshold 0 makes EVERYTHING unequal, including a string and itself —
the guard clause returns False before comparing. The intuitive
"exact match only" setting does the opposite of what it looks like.
```

## The one thing to know

Despite the name, this is not a numeric tolerance. It is monotone in
*spelling*, not in magnitude — so the canonical float-comparison case fails
and two integers a full unit apart pass.

```raku name="numbers"
use Operator::feq;

my $eps = 0.1e0 + 0.2e0;
say '0.1e0 + 0.2e0     = ', $eps;
say 'differs from 0.3e0 by ', ($eps - 0.3e0);
say '  $eps feq 0.3e0  = ', ($eps feq 0.3e0), '   <- 5.5e-17 apart, and False';
say '  $eps == 0.3e0   = ', ($eps == 0.3e0);
say '';
say '1000000000 feq 1000000001 = ', (1000000000 feq 1000000001),
    '   <- a full unit apart, and True';
say '1.0e0 feq 2.0e0           = ', (1.0e0 feq 2.0e0);
say '3.14159e0 feq 3.14158e0   = ', (3.14159e0 feq 3.14158e0);
say '';
say '"0.30000000000000004" and "0.3" are sixteen edits apart out of';
say 'nineteen characters; "1000000000" and "1000000001" are one out of';
say 'ten. For numbers, use `=~=` or an explicit epsilon.';
```

```output
0.1e0 + 0.2e0     = 0.30000000000000004
differs from 0.3e0 by 5.551115123125783e-17
  $eps feq 0.3e0  = False   <- 5.5e-17 apart, and False
  $eps == 0.3e0   = False

1000000000 feq 1000000001 = True   <- a full unit apart, and True
1.0e0 feq 2.0e0           = False
3.14159e0 feq 3.14158e0   = False

"0.30000000000000004" and "0.3" are sixteen edits apart out of
nineteen characters; "1000000000" and "1000000001" are one out of
ten. For numbers, use `=~=` or an explicit epsilon.
```

## Precedence and chaining

```raku name="precedence"
use Operator::feq;

say 'the operator carries no precedence trait, so it takes the DEFAULT for';
say 'a new infix — additive, the same as `+`:';
say '  "abcdefghi" ~ "j" feq "abcdefghik"';
say '  parses as   "abcdefghi" ~ ("j" feq "abcdefghik")';
say '  and yields  ', ('abcdefghi' ~ ('j' feq 'abcdefghik')).raku;
say '';
say 'so parenthesise when you mix it with anything:';
say '  ("abcdefghi" ~ "j") feq "abcdefghik" = ',
    (('abcdefghi' ~ 'j') feq 'abcdefghik');
say '';
say 'and despite `is assoc<none>`, chaining is not rejected — it compiles';
say 'and silently compares a Bool against a string. Compare two things.';
```

```output
the operator carries no precedence trait, so it takes the DEFAULT for
a new infix — additive, the same as `+`:
  "abcdefghi" ~ "j" feq "abcdefghik"
  parses as   "abcdefghi" ~ ("j" feq "abcdefghik")
  and yields  "abcdefghiFalse"

so parenthesise when you mix it with anything:
  ("abcdefghi" ~ "j") feq "abcdefghik" = True

and despite `is assoc<none>`, chaining is not rejected — it compiles
and silently compares a Bool against a string. Compare two things.
```

## Where the two engines differ

Two, and both are about corners you should stay out of. `$*FEQLIB` lets you
swap the backend, and Rakudo requires the replacement class to be nested under
a package the module has already made visible while Raku++ accepts a
top-level name. And `is assoc<none>` chains left under Raku++ and right under
Rakudo — neither engine diagnoses the chain the spec says is an error.

```raku name="edges"
use Operator::feq;

say 'the empty string is a hard failure on both engines:';
my $r = try ('' feq '');
say '  "" feq "" -> ', $! ?? 'threw' !! $r.raku;
say '  the message says "Cannot coerce \'\' to Str", which is misleading —';
say '  the coercion succeeded, the code just tests the result for truth.';
say '';
say 'an undefined operand likewise:';
my $u = try (Str feq 'abc');
say '  Str feq "abc" -> ', $! ?? 'threw' !! $u.raku;
say '';
say 'guard both ends:';
sub fuzzy(Str:D $a, Str:D $b, :$threshold = 0.1) {
    return $a eq $b unless $a.chars && $b.chars;
    my $*FEQTHRESHOLD = $threshold;
    $a feq $b
}
for ('', ''), ('cat', 'cot'), ('abcdefghij', 'abcdefghik') -> ($a, $b) {
    say sprintf('  fuzzy(%-12s, %-12s) = %s', $a.raku, $b.raku, fuzzy($a, $b));
}
```

```output
the empty string is a hard failure on both engines:
  "" feq "" -> threw
  the message says "Cannot coerce '' to Str", which is misleading —
  the coercion succeeded, the code just tests the result for truth.

an undefined operand likewise:
  Str feq "abc" -> threw

guard both ends:
  fuzzy(""          , ""          ) = True
  fuzzy("cat"       , "cot"       ) = False
  fuzzy("abcdefghij", "abcdefghik") = True
```

One more note for the future: the distribution declares `role Operator::feq`
inside a module of the same name, which Rakudo warns about — that pattern
silently replaces the module in the outer stash in 6.d and installs a nested
package in 6.e. Raku++ prints nothing.
