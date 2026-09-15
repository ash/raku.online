---
name: Zodiac::Chinese
version: 0.0.1
auth: cpan:tmtvl
kind: Distribution · calendars
summary: The sexagenary year — direction, element and animal — from a
  DateTime, with the year rolling over at midnight on 1 February.
status: divergent
suite: 5 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/cpan:tmtvl/Zodiac::Chinese
source: https://github.com/tmtvl/Zodiac-Chinese.git
---

## What it is for

The Chinese sexagenary cycle names a year with three things at once: a yin or
yang direction, one of the five elements, and one of the twelve animal signs.
Together they repeat every sixty years — 2024 is yang wood dragon, and the
last yang wood dragon was 1964.

This distribution takes a `DateTime` and returns those three components.

## Using it

```raku name="basics"
use Zodiac::Chinese;

for 2018 .. 2025 -> $y {
    my $z = ChineseZodiac.new(DateTime.new(year => $y, month => 6, day => 15));
    say sprintf('%d  %-4s %-6s %s', $y, $z.direction, $z.element, $z.sign);
}
```

```output
2018  yang earth  dog
2019  yin  earth  pig
2020  yang metal  rat
2021  yin  metal  ox
2022  yang water  tiger
2023  yin  water  rabbit
2024  yang wood   dragon
2025  yin  wood   snake
```

Those eight lines match the published sexagenary years.

## The cycle is genuinely sixty long

```raku name="cycle"
use Zodiac::Chinese;

sub triple($y) {
    my $z = ChineseZodiac.new(DateTime.new(year => $y, month => 6, day => 15));
    "{$z.direction}-{$z.element}-{$z.sign}"
}

my @sixty = (1984 .. 2043).map(&triple);
say 'distinct triples in 60 consecutive years : ', @sixty.unique.elems;
say 'repeats at +60 ?                         : ', triple(1984) eq triple(2044);
say 'repeats at +30 ?                         : ', triple(1984) eq triple(2014);
say '';
say '1984 is ', triple(1984), '  — jiǎ-zǐ, the head of a cycle.';
```

```output
distinct triples in 60 consecutive years : 60
repeats at +60 ?                         : True
repeats at +30 ?                         : False

1984 is yang-wood-rat  — jiǎ-zǐ, the head of a cycle.
```

## It takes a DateTime and only a DateTime

```raku name="types"
use Zodiac::Chinese;

for DateTime.new(year => 2024, month => 6, day => 15),
    Date.new(2024, 6, 15), 2024, '2024' -> $arg {
    my $r = try ChineseZodiac.new($arg);
    say sprintf('%-10s -> %s', $arg.WHAT.^name, $! ?? 'refused' !! $r.sign);
}
say '';
say 'there is no Date candidate and no Int one. Coerce yourself:';
say '  Date -> ', ChineseZodiac.new(Date.new(2024, 6, 15).DateTime).sign;
```

```output
DateTime   -> dragon
Date       -> refused
Int        -> refused
Str        -> refused

there is no Date candidate and no Int one. Coerce yourself:
  Date -> dragon
```

## The one thing to know

The year rolls over at midnight on **1 February**, every year. The real
Chinese New Year moves anywhere between 21 January and 20 February, so for up
to twenty days a year the answer is a whole sign wrong — and wrong on both
sides of the boundary, depending on the year.

```raku name="boundary"
use Zodiac::Chinese;

sub sign($y, $m, $d) {
    ChineseZodiac.new(DateTime.new(year => $y, month => $m, day => $d)).sign
}

say 'the module`s own boundary:';
say '  2020-01-31 -> ', sign(2020, 1, 31), '      2020-02-01 -> ', sign(2020, 2, 1);
say '';
say 'against the published new-year dates:';
say '  CNY 2020-01-25 begins the Metal Rat';
say '    the day itself 2020-01-25 -> ', sign(2020, 1, 25), '   WRONG';
say '  CNY 2023-01-22 begins the Water Rabbit';
say '    the day itself 2023-01-22 -> ', sign(2023, 1, 22), '  WRONG';
say '  CNY 2024-02-10 begins the Wood Dragon';
say '    the day before 2024-02-09 -> ', sign(2024, 2, 9), ' WRONG';
say '';
say 'do not use this for a date in the second half of January or the';
say 'first three weeks of February.';
```

```output
the module`s own boundary:
  2020-01-31 -> pig      2020-02-01 -> rat

against the published new-year dates:
  CNY 2020-01-25 begins the Metal Rat
    the day itself 2020-01-25 -> pig   WRONG
  CNY 2023-01-22 begins the Water Rabbit
    the day itself 2023-01-22 -> tiger  WRONG
  CNY 2024-02-10 begins the Wood Dragon
    the day before 2024-02-09 -> dragon WRONG

do not use this for a date in the second half of January or the
first three weeks of February.
```

## Where the two engines differ

One case, and it is a serious one: a call that supplies a stray named argument
instead of the required positional.

```raku name="named"
use Zodiac::Chinese;

my $r = try ChineseZodiac.new(year => 2020);
say 'ChineseZodiac.new(year => 2020) -> ', $! ?? 'refused' !! 'built an object';
say '';
say 'Rakudo refuses it — "Too few positionals passed". Raku++ silently binds';
say 'the missing required positional to its type object when any named';
say 'argument is present, so the method runs against an undefined DateTime';
say 'instead of raising. Pass the positional.';
```

```output
ChineseZodiac.new(year => 2020) -> refused

Rakudo refuses it — "Too few positionals passed". Raku++ silently binds
the missing required positional to its type object when any named
argument is present, so the method runs against an undefined DateTime
instead of raising. Pass the positional.
```

Reduced to a one-liner with no module involved: `class K { method f(Int $n) {…} }`
called as `K.f(:x(1))` throws `Too few positionals` under Rakudo and binds
`$n` to the `Int` type object under Raku++.

Two introspection-only differences to keep out of examples: the constructor's
`.signature.gist` omits the invocant and `*%_` under Raku++, and `^methods(:local)`
picks up Rakudo's internal `POPULATE`. Assigning to a read-only accessor says
`Cannot modify an immutable 'sign'` on one engine and `Cannot assign to a
readonly variable or a value` on the other; the refusal is the same.
