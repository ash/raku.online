---
name: Algorithm::DawkinsWeasel
version: 0.1.1
auth: github:jaldhar
kind: Distribution · algorithms
summary: Dawkins's cumulative-selection demonstration — where every step of
  the sequence is the same mutable object, not a snapshot.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/github:jaldhar/Algorithm::DawkinsWeasel
source: https://github.com/jaldhar/Algorithm-DawkinsWeasel.git
---

## What it is for

Richard Dawkins's weasel program makes one point: random mutation *plus
cumulative selection* converges on a target absurdly faster than random search
alone. Starting from noise, make N mutated copies of the current phrase, keep
one only if it matches more target characters, repeat.

This distribution is that demonstration, with the target, the mutation rate
and the copy count all configurable.

## Running it

```raku name="basics"
use Algorithm::DawkinsWeasel;

my $w = Algorithm::DawkinsWeasel.new(
    target-phrase      => 'WEASEL',
    mutation-threshold => 1/20,
    copies             => 30,
);
say 'target             : ', $w.target-phrase;
say 'mutation-threshold : ', $w.mutation-threshold;
say 'copies             : ', $w.copies;
say '';
say 'before evolving:';
say '  count            : ', $w.count;
say '  hi-score         : ', $w.hi-score;
say '  current-phrase   : ', $w.current-phrase.chars, ' characters';
my $charset = set(flat 'A'..'Z', ' ');
say '  drawn from A..Z and space : ',
    so $w.current-phrase.comb.all (elem) $charset;
say '';
# walk until it converges, bounded so the page cannot hang
my $steps = 0;
for $w.evolution { last if ++$steps > 5000 }
say 'after walking the sequence:';
say '  solved           : ', $w.current-phrase eq 'WEASEL';
say '  generations run  : ', $w.count > 0;
say '  final score      : ', $w.hi-score == 'WEASEL'.chars;
```

```output
target             : WEASEL
mutation-threshold : 0.05
copies             : 30

before evolving:
  count            : 0
  hi-score         : 0
  current-phrase   : 6 characters
  drawn from A..Z and space : True

after walking the sequence:
  solved           : True
  generations run  : True
  final score      : True
```

The search is random, so every assertion above is a property rather than a
value.

## The one thing to know

`evolution` is `gather { repeat { take self } until self!evolve; take self }`.
Every element is the **same mutable object**, never a snapshot.

```raku name="same-object"
use Algorithm::DawkinsWeasel;

my $w = Algorithm::DawkinsWeasel.new(target-phrase => 'WEASEL', copies => 30);
my @steps = $w.evolution.list;
say 'steps yielded            : ', @steps.elems > 0;
say 'every step is the SAME object : ', so @steps.all === $w;
say 'distinct phrases observed     : engine-dependent, and that is the point';
say '';
say 'so what the caller sees depends entirely on WHEN the producer ran.';
say 'On Rakudo the gather is lazy and you watch the search happen; on';
say 'Raku++ it runs eagerly in blocks of 64 takes before the first pull,';
say 'so you see the finished answer repeated N times.';
say '';
say 'the module`s whole purpose — watching cumulative selection converge —';
say 'therefore produces nothing to watch on one of the two engines.';
say '';
say 'snapshot it yourself if you want the history:';
my $v = Algorithm::DawkinsWeasel.new(target-phrase => 'WEASEL', copies => 30);
my @history;
for $v.evolution -> $step { @history.push($step.current-phrase) }
say '  the copied history is non-empty        : ', @history.elems > 0;
say '  every entry is a 6-character phrase    : ',
    so @history.all.map(*.chars == 6);
say '  the object itself ends solved          : ',
    $v.current-phrase eq 'WEASEL';
```

```output
steps yielded            : True
every step is the SAME object : True
distinct phrases observed     : engine-dependent, and that is the point

so what the caller sees depends entirely on WHEN the producer ran.
On Rakudo the gather is lazy and you watch the search happen; on
Raku++ it runs eagerly in blocks of 64 takes before the first pull,
so you see the finished answer repeated N times.

the module`s whole purpose — watching cumulative selection converge —
therefore produces nothing to watch on one of the two engines.

snapshot it yourself if you want the history:
  the copied history is non-empty        : True
  every entry is a 6-character phrase    : True
  the object itself ends solved          : True
```

## Things that will not terminate

```raku name="termination"
use Algorithm::DawkinsWeasel;

say 'the charset is A..Z plus space. A target containing ANYTHING else —';
say 'a lowercase letter, a digit, punctuation — can never be reached, and';
say '.evolution never ends.';
say '';
say 'and copies => 0 produces no trial at all, so hi-score can never';
say 'rise and the sequence is infinite:';
say '  (Raku++ silently caps an infinite gather at 2**20 elements;';
say '   Rakudo runs until you kill it.)';
say '';
say 'check the target before you start:';
sub weasel(Str $target, *%opts) {
    die "target must be A..Z and spaces only: {$target.raku}"
        unless $target ~~ /^ <[A..Z ]>* $/;
    Algorithm::DawkinsWeasel.new(target-phrase => $target, |%opts)
}
for 'ME THINKS', 'methinks' -> $t {
    my $r = try weasel($t, copies => 10);
    say sprintf('  %-12s -> %s', $t.raku, $! ?? 'refused' !! 'ok');
}
say '';
say 'an empty target terminates immediately:';
my $e = Algorithm::DawkinsWeasel.new(target-phrase => '');
say '  evolution elems : ', $e.evolution.elems;
```

```output
the charset is A..Z plus space. A target containing ANYTHING else —
a lowercase letter, a digit, punctuation — can never be reached, and
.evolution never ends.

and copies => 0 produces no trial at all, so hi-score can never
rise and the sequence is infinite:
  (Raku++ silently caps an infinite gather at 2**20 elements;
   Rakudo runs until you kill it.)

check the target before you start:
  "ME THINKS"  -> refused
  "methinks"   -> refused

an empty target terminates immediately:
  evolution elems : 2
```

## Two API shapes

```raku name="shapes"
use Algorithm::DawkinsWeasel;

say 'has Str @.target-phrase is a public ARRAY attribute, but an explicit';
say '`method target-phrase` shadows the generated accessor — so it returns';
say 'a Str and the array form is unreachable:';
my $w = Algorithm::DawkinsWeasel.new(target-phrase => 'WEASEL');
say '  .target-phrase.WHAT : ', $w.target-phrase.WHAT.^name;
say '';
say 'mutation-threshold is typed Rat, so a Num or an Int is refused:';
for 1/20, 0.05e0, 0 -> $m {
    my $r = try Algorithm::DawkinsWeasel.new(target-phrase => 'AB',
                                             mutation-threshold => $m);
    say sprintf('  %-10s (%s) -> %s', $m.raku, $m.WHAT.^name,
                $! ?? 'refused' !! 'accepted');
}
say '';
say '.evolution MUTATES the receiver and can be called again — a second';
say 'walk of an already-solved object adds exactly one more generation.';
```

```output
has Str @.target-phrase is a public ARRAY attribute, but an explicit
`method target-phrase` shadows the generated accessor — so it returns
a Str and the array form is unreachable:
  .target-phrase.WHAT : Str

mutation-threshold is typed Rat, so a Num or an Int is refused:
  0.05       (Rat) -> accepted
  0.05e0     (Num) -> refused
  0          (Int) -> refused

.evolution MUTATES the receiver and can be called again — a second
walk of an already-solved object adds exactly one more generation.
```

## Where the two engines differ

The laziness of `gather`, as above, which changes what the caller observes
without changing the final answer. Copy what you need out of each step and the
two engines agree.
