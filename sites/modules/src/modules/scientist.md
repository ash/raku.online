---
name: Scientist
version: 0.0.4
auth: zef:lancew
kind: Distribution · testing
summary: Run new code beside old code and record whether they disagreed — with
  an `eqv` comparison that calls 42 and 42.0 a mismatch.
status: full
suite: 3 files, green
tested: 2026-09-15
license: MIT
depends: none beyond the core
raku-land: https://raku.land/zef:lancew/Scientist
source: git://github.com/lancew/ScientistP6.git
---

## What it is for

Refactoring something you cannot afford to break: run the old implementation
and the new one on every real call, return the old one's answer, and record
whether the two agreed. GitHub's `scientist` made the pattern well known and
this is the Raku version of it.

## Running an experiment

```raku name="basics"
use Scientist;

my $s = Scientist.new(
    experiment => 'sum',
    use        => sub { (1..10).sum },
    try        => sub { 10 * 11 div 2 },
    context    => %( owner => 'spike' ),
);
say 'run returned : ', $s.run;
say '';
my %r = $s.result;
say 'result keys  : ', %r.keys.sort.join(', ');
say '  experiment : ', %r<experiment>.raku;
say '  mismatched : ', %r<mismatched>;
say '  context    : ', %r<context>.map({ .key ~ '=' ~ .value }).sort.join(', ');
say '  durations are Durations : ',
    so (%r<control><duration>, %r<candidate><duration>).all ~~ Duration;
say '';
say 'the value your program gets is always the CONTROL`s.';
```

```output
run returned : 55

result keys  : candidate, context, control, experiment, mismatched
  experiment : "sum"
  mismatched : False
  context    : owner=spike
  durations are Durations : True

the value your program gets is always the CONTROL`s.
```

## When they disagree

```raku name="mismatch"
use Scientist;

my $s = Scientist.new(
    experiment => 'disagree',
    use        => sub { 'old' },
    try        => sub { 'new' },
);
say 'run returned : ', $s.run.raku, '   <- the control`s value';
say 'mismatched   : ', $s.result<mismatched>;
say '';
say 'and note what is NOT recorded — neither value:';
say '  result keys : ', $s.result.keys.sort.join(', ');
say '';
my $t = Scientist.new(
    experiment => 'candidate throws',
    use        => sub { 'old' },
    try        => sub { die 'boom' },
);
say 'a candidate that THROWS:';
say '  run survived : ', ($t.run.defined ?? 'yes' !! 'no');
say '  returned     : ', $t.run.raku;
say '  mismatched   : ', $t.result<mismatched>;
say '';
say 'the exception is swallowed by an inner try, $candidate stays';
say 'undefined, mismatched becomes True, and nothing anywhere records';
say 'that an exception happened. A candidate that always throws is';
say 'indistinguishable from one that always returns the wrong answer.';
say '';
say 'the CONTROL`s exceptions propagate to your caller, which is right.';
```

```output
run returned : "old"   <- the control`s value
mismatched   : True

and note what is NOT recorded — neither value:
  result keys : candidate, context, control, experiment, mismatched

a candidate that THROWS:
  run survived : yes
  returned     : "old"
  mismatched   : True

the exception is swallowed by an inner try, $candidate stays
undefined, mismatched becomes True, and nothing anywhere records
that an exception happened. A candidate that always throws is
indistinguishable from one that always returns the wrong answer.

the CONTROL`s exceptions propagate to your caller, which is right.
```

## The one thing to know

The comparison is `!eqv`, and `eqv` is type-strict — so a refactor that
changes only the numeric type or the container is reported as a mismatch.

```raku name="eqv"
use Scientist;

sub compare($label, &a, &b) {
    my $s = Scientist.new(experiment => $label, use => &a, try => &b);
    $s.run;
    sprintf('  %-28s mismatched = %s', $label, $s.result<mismatched>)
}
say compare('Int 42 vs Rat 42.0',  { 42 },        { 42.0 });
say compare('Int 42 vs Num 42e0',  { 42 },        { 42e0 });
say compare('Int 42 vs Str "42"',  { 42 },        { '42' });
say compare('List vs Array',       { (1, 2, 3) }, { [1, 2, 3] });
say compare('List vs Seq',         { (1, 2, 3) }, { (1, 2, 3).Seq });
say compare('Hash vs Map',         { %( a => 1 ) }, { Map.new(('a', 1)) });
say compare('identical Ints',      { 42 },        { 42 });
say compare('both return Nil',     { Nil },       { Nil });
say '';
say '42 versus 42.0 is a mismatch; (1,2,3) versus [1,2,3] is a mismatch.';
say 'In a real refactor those are the COMMON cases, and there is no hook';
say 'to supply your own comparator.';
say '';
say 'normalise inside the two callables:';
my $s = Scientist.new(experiment => 'normalised',
                      use => sub { (1, 2, 3).List },
                      try => sub { [1, 2, 3].List });
$s.run;
say '  both .List-ed -> mismatched = ', $s.result<mismatched>;
```

```output
  Int 42 vs Rat 42.0           mismatched = True
  Int 42 vs Num 42e0           mismatched = True
  Int 42 vs Str "42"           mismatched = True
  List vs Array                mismatched = True
  List vs Seq                  mismatched = True
  Hash vs Map                  mismatched = True
  identical Ints               mismatched = False
  both return Nil              mismatched = False

42 versus 42.0 is a mismatch; (1,2,3) versus [1,2,3] is a mismatch.
In a real refactor those are the COMMON cases, and there is no hook
to supply your own comparator.

normalise inside the two callables:
  both .List-ed -> mismatched = False
```

## Two shapes to plan around

```raku name="shapes"
use Scientist;

my $s = Scientist.new(experiment => 'first', use => sub { 1 }, try => sub { 2 });
$s.run;
say 'after a run, result<experiment> : ', $s.result<experiment>.raku;
$s.enabled = False;
say 'run with enabled = False        : ', $s.run;
say 'result<experiment> is STILL     : ', $s.result<experiment>.raku;
say 'result<mismatched> is STILL     : ', $s.result<mismatched>;
say '';
say 'enabled = False short-circuits before %!result is touched, so result';
say 'keeps reporting the PREVIOUS run`s verdict, name and all.';
say '';
say 'and the order of the two calls is RANDOMISED per run — Bool.pick —';
say 'so a candidate with side effects, shared state or a warm cache will';
say 'produce unstable timings and results.';
say '';
say 'publish() is an empty method; the "publish your results" story needs';
say 'a subclass:';
class Loud is Scientist {
    method publish { note "  {$.experiment}: mismatched={$.result<mismatched>}" }
}
Loud.new(experiment => 'loud', use => sub { 1 }, try => sub { 2 }).run;
say '  (publish writes to stderr above; it is called on agreement too)';
```

```output
after a run, result<experiment> : "first"
run with enabled = False        : 1
result<experiment> is STILL     : "first"
result<mismatched> is STILL     : True

enabled = False short-circuits before %!result is touched, so result
keeps reporting the PREVIOUS run`s verdict, name and all.

and the order of the two calls is RANDOMISED per run — Bool.pick —
so a candidate with side effects, shared state or a warm cache will
produce unstable timings and results.

publish() is an empty method; the "publish your results" story needs
a subclass:
  (publish writes to stderr above; it is called on agreement too)
```

## Where the two engines differ

Nothing behavioural. One thing to be careful of on both, and sharper on
Raku++: `result<context>` **is** the scientist's own `%.context` hash, so
writing into it mutates the object — and under Raku++ it also mutates the hash
you passed to `.new`.

```raku name="portable"
use Scientist;

my %ctx = owner => 'spike';
my $s = Scientist.new(experiment => 'ctx', use => sub { 1 }, try => sub { 1 },
                      context => %ctx);
$s.run;
say 'copy the context before you touch it:';
my %mine = $s.result<context>;
%mine<owner> = 'someone else';
say '  my copy      : ', %mine<owner>;
say '  the object   : ', $s.result<context><owner>;
say '';
say 'the result Map is shallow, so its nested values are shared. Treat';
say 'everything that comes out of .result as read-only.';
say '';
say 'and `use` is required while `try` is not — leaving try unset is not';
say 'an error, it is a permanent mismatched => True.';
```

```output
copy the context before you touch it:
  my copy      : someone else
  the object   : spike

the result Map is shallow, so its nested values are shared. Treat
everything that comes out of .result as read-only.

and `use` is required while `try` is not — leaving try unset is not
an error, it is a permanent mismatched => True.
```
