---
name: Algorithm::Elo
version: 0.1.1
auth: zef:raku-community-modules
kind: Distribution · algorithms
summary: One Elo update — two integer ratings and who won, in; two new integer
  ratings, out — on the standard logistic curve with a fixed K of 32.
status: full
suite: 1 file, green
tested: 2026-09-15
license: MIT
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Algorithm::Elo
source: https://github.com/raku-community-modules/Algorithm-Elo.git
---

## What it is for

Elo is the rating system chess uses and that most competitive ladders have
copied. The rule is simple: each player's expected score follows from the
rating gap on a logistic curve, and the rating moves by K times the difference
between what happened and what was expected.

This distribution is that one update, done once, with no state and no storage.

## Rating a game

```raku name="elo"
use Algorithm::Elo;

say 'equal ratings, left wins  : ', calculate-elo(1600, 1600, :left).List.raku;
say 'equal ratings, right wins : ', calculate-elo(1600, 1600, :right).List.raku;
say 'equal ratings, a draw     : ', calculate-elo(1600, 1600, :draw).List.raku;
say '';
say 'an 800-point underdog winning : ', calculate-elo(1200, 2000, :left).List.raku;
say 'the same favourite winning    : ', calculate-elo(2000, 1200, :left).List.raku;
say '';
my ($a, $b) = calculate-elo(1600, 1600, :left);
say 'return types  : ', $a.^name, ' ', $b.^name;
say 'total rating  : ', 1600 + 1600, ' before, ', $a + $b, ' after';
```

```output
equal ratings, left wins  : (1616, 1584)
equal ratings, right wins : (1584, 1616)
equal ratings, a draw     : (1600, 1600)

an 800-point underdog winning : (1232, 1968)
the same favourite winning    : (2000, 1200)

return types  : Int Int
total rating  : 3200 before, 3200 after
```

Two things fall out. Total rating is **conserved** — what one player gains the
other loses, which is what makes an Elo pool zero-sum. And the 800-point
favourite winning gains **nothing**: K is 32, the expected score is about 0.99,
and 32 × 0.01 rounds to zero.

## The flags

```raku name="flags"
use Algorithm::Elo;

sub attempt($label, &c) {
    my $r = try c();
    say sprintf('%-30s %s', $label, $! ?? $!.message !! $r.List.raku);
}

attempt 'no flag at all',          { calculate-elo(1600, 1600) };
attempt ':left and :right',        { calculate-elo(1600, 1600, :left, :right) };
attempt 'all three',               { calculate-elo(1600, 1600, :left, :right, :draw) };
attempt ':!left (an explicit No)', { calculate-elo(1600, 1600, :!left) };
attempt 'just :draw',              { calculate-elo(1600, 1600, :draw) };
```

```output
no flag at all                 :left, :right, and :draw are mutually exclusive
:left and :right               :left, :right, and :draw are mutually exclusive
all three                      :left, :right, and :draw are mutually exclusive
:!left (an explicit No)        :left, :right, and :draw are mutually exclusive
just :draw                     (1600, 1600)
```

`:!left` is not "left did not win" — it is a `False` flag, which counts as
zero flags set, and is refused.

## The one thing to know

Calling with **no** result flag dies complaining that the flags are mutually
exclusive, which is the opposite of the actual problem.

The module has two guards and two messages. The first is
`unless $left-wins ^ $right-wins ^ $draw { die … }`, where infix `^` builds a
`one()` junction — false when *zero* flags are true just as much as when two
are. So the "you forgot to say who won" case is caught by the exclusivity
guard and misreported, and the second guard, the one whose message would have
been right, is unreachable.

```raku name="unreachable"
use Algorithm::Elo;

my @messages;
for (True, False, Bool) -> $l {
    for (True, False, Bool) -> $r {
        for (True, False, Bool) -> $d {
            my %args;
            %args<left>  = $l unless $l === Bool;
            %args<right> = $r unless $r === Bool;
            %args<draw>  = $d unless $d === Bool;
            my $out = try calculate-elo(1600, 1600, |%args);
            @messages.push: $! ?? $!.message !! 'OK ' ~ $out.List.raku;
        }
    }
}
say 'all 27 flag combinations:';
for @messages.Bag.sort(*.key) -> $p { say '  ', $p.value, ' x  ', $p.key }
say '';
say 'the second guard\'s message was seen : ',
    ?@messages.first(*.contains('least one'));
```

```output
all 27 flag combinations:
  15 x  :left, :right, and :draw are mutually exclusive
  4 x  OK (1584, 1616)
  4 x  OK (1600, 1600)
  4 x  OK (1616, 1584)

the second guard's message was seen : False
```

Twenty-seven combinations, and the "at least one" message never appears. The
practical cost is a misleading diagnostic for the single most likely mistake.

## Where the two engines differ

Nowhere. All 27 flag combinations, every rating case, and every rejection
produced identical output on Raku++ and Rakudo.

Three things about the algorithm as implemented, none of them engine-related.
K is a hard-wired **32** with no parameter, so there is no provisional-player
period and no rating floor. Ratings must be `Int` — `1600.0` is a binding
failure, so anything that has been through a division needs an explicit
coercion, though the return values are `Int` so chaining calls is fine. And
ratings can go negative: `calculate-elo(-50, 1600, :left)` is accepted and
returns `(-18, 1568)`.
