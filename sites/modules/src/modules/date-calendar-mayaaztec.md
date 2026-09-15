---
name: Date::Calendar::MayaAztec
version: 0.1.0
auth: zef:jforget
kind: Distribution · calendars
summary: Maya long count, Haab and Tzolkin plus the Aztec xiuhpohualli and
  tonalpohualli, under three published correlations, in three locales each.
status: full
suite: 4 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: Date::Calendar::Strftime
raku-land: https://raku.land/zef:jforget/Date::Calendar::MayaAztec
source: https://github.com/jforget/raku-Date-Calendar-MayaAztec.git
---

## What it is for

Mesoamerican dates are not one calendar but several running at once. The Maya
long count is an absolute day tally; the Haab is a 365-day civil year; the
Tzolkin is a 260-day ritual cycle. A Maya date names the day under all three.
The Aztec xiuhpohualli and tonalpohualli are the same idea under different
names.

This distribution converts core `Date` to and from all of them, under three
published Maya correlations and two Aztec variants, and answers in the locale
you ask for.

`use Date::Calendar::MayaAztec` gives you the shared role and nothing you
can construct — each calendar is its own unit, so `use` the one you want.

## A day under every cycle

```raku name="cycles"
use Date::Calendar::Maya;
use Date::Calendar::Aztec;

my $d = Date.new(2020, 6, 20);
my $m = Date::Calendar::Maya.new-from-date($d);

say 'gregorian   : ', $d;
say 'long count  : ', $m.long-count;
say '  haab      : ', $m.haab,    '   (month ', $m.month, ', day ', $m.day, ')';
say '  tzolkin   : ', $m.tzolkin;
say '  doy       : ', $m.day-of-year;
say '  epoch JDN : ', $m.epoch;
say '  strftime  : ', $m.strftime('%Y %A %B');
say '';
my $a = Date::Calendar::Aztec.new-from-date($d);
say 'aztec       : ', $a.gist;
say '  xiuh      : ', $a.xiuhpohualli;
say '  tonal     : ', $a.tonalpohualli;
say '  bearer    : ', $a.year-bearer;
say '';
say 'round trips : ', ($m.to-date == $d) && ($a.to-date == $d);
```

```output
gregorian   : 2020-06-20
long count  : 13.0.7.10.18
  haab      : 1 Tzec   (month 5, day 1)
  tzolkin   : 12 Etznab
  doy       : 81
  epoch JDN : 584283
  strftime  : 9 Caban Etznab Tzec

aztec       : 20-13 12-18
  xiuh      : 20 Teotleco
  tonal     : 12 Tecpatl
  bearer    : 8 Tecpatl

round trips : True
```

The three correlations differ by their epoch, given as a Julian Day Number:
584283 for Goodman-Martinez-Thompson, 489384 for Spinden, 584285 for the
Astronomical one. Those are the published values.

```raku name="variants"
use Date::Calendar::Maya;
use Date::Calendar::Maya::Spinden;
use Date::Calendar::Maya::Astronomical;
use Date::Calendar::Aztec;
use Date::Calendar::Aztec::Cortes;

my $d = Date.new(2020, 6, 20);
for Date::Calendar::Maya, Date::Calendar::Maya::Spinden,
    Date::Calendar::Maya::Astronomical -> $cls {
    my $m = $cls.new-from-date($d);
    say sprintf('%-40s epoch %6d  %s', $cls.^name, $m.epoch, $m.long-count);
}
say '';
for Date::Calendar::Aztec, Date::Calendar::Aztec::Cortes -> $cls {
    my $a = $cls.new-from-date($d);
    say sprintf('%-40s %s', $cls.^name, $a.gist);
}
```

```output
Date::Calendar::Maya                     epoch 584283  13.0.7.10.18
Date::Calendar::Maya::Spinden            epoch 489384  13.13.11.3.17
Date::Calendar::Maya::Astronomical       epoch 584285  13.0.7.10.16

Date::Calendar::Aztec                    20-13 12-18
Date::Calendar::Aztec::Cortes            3-14 2-1
```

## Locales

```raku name="locale"
use Date::Calendar::Maya;
use Date::Calendar::Aztec;

my $m = Date::Calendar::Maya.new-from-date(Date.new(2020, 6, 20));
for <yua en fr> -> $loc {
    $m.locale = $loc;
    say sprintf('maya  %-3s  haab %-12s tzolkin %s', $loc, $m.haab.raku, $m.tzolkin.raku);
}
say '';
my $a = Date::Calendar::Aztec.new-from-date(Date.new(2020, 6, 20));
for <nah en fr> -> $loc {
    $a.locale = $loc;
    say sprintf('aztec %-3s  xiuh %-16s tonal %s', $loc, $a.xiuhpohualli.raku, $a.tonalpohualli.raku);
}
```

```output
maya  yua  haab "1 Tzec"     tzolkin "12 Etznab"
maya  en   haab "1 Skull"    tzolkin "12 Flint"
maya  fr   haab "1 Tzec"     tzolkin "12 Couteau de silex"

aztec nah  xiuh "20 Teotleco"    tonal "12 Tecpatl"
aztec en   xiuh "20 God arrives" tonal "12 Flint"
aztec fr   xiuh "20 Retour des dieux" tonal "12 Silex"
```

## The one thing to know

A calendar round — one Haab paired with one Tzolkin — repeats every 18 980
days, about 52 years. So the constructor that takes a round is ambiguous, and
it resolves the ambiguity **against `Date.today` if you do not give it a
reference date**.

```raku name="ambiguous"
use Date::Calendar::Maya;

my %args = month => 5, day => 1, clerical-index => 18, clerical-number => 12;
for <before on-or-before after> -> $which {
    my $m = Date::Calendar::Maya.new(|%args, |($which => Date.new(2020, 6, 20)));
    say sprintf('  :%-14s 2020-06-20 -> %s  %s', $which, $m.to-date, $m.long-count);
}
say '';
my $floating = Date::Calendar::Maya.new(|%args, nearest => Date.new(2020, 6, 20));
say 'pinned with :nearest      -> ', $floating.to-date;
say '';
say 'with NO reference date the module reaches for Date.today, so the';
say 'same program answers a different date 27 years from now — silently.';
say 'always pass :before / :on-or-before / :after / :nearest.';
```

```output
  :before         2020-06-20 -> 1968-07-03  12.17.14.15.18
  :on-or-before   2020-06-20 -> 2020-06-20  13.0.7.10.18
  :after          2020-06-20 -> 2072-06-07  13.3.0.5.18

pinned with :nearest      -> 2020-06-20

with NO reference date the module reaches for Date.today, so the
same program answers a different date 27 years from now — silently.
always pass :before / :on-or-before / :after / :nearest.
```

The 18 980-day period is `365 lcm 20 lcm 13`. Three answers, all correct, all
one round apart.

## Where the two engines differ

The module cannot represent a day before the long-count zero, and the two
engines refuse it differently — so catch the exception, never match its class.

```raku name="floor"
use Date::Calendar::Maya;

my $zero = Date::Calendar::Maya.new(long-count => '0.0.0.0.0');
say 'long count zero : ', $zero.to-date, '  (MJD ', $zero.daycount, ')';
say 'one day later   : ',
    Date::Calendar::Maya.new-from-daycount($zero.daycount + 1).long-count;
my $r = try Date::Calendar::Maya.new-from-daycount($zero.daycount - 1);
say 'one day EARLIER : ', $! ?? 'refused' !! $r.long-count;
say '';
say 'Raku++ raises a where-constraint failure on $!kin; Rakudo fails to bind';
say '$baktun at all. The cause is Int.polymod on a negative invocant, which';
say 'Raku++ answers with negative components and Rakudo refuses outright.';
```

```output
long count zero : -3113-08-11  (MJD -1815718)
one day later   : 0.0.0.0.1
one day EARLIER : refused

Raku++ raises a where-constraint failure on $!kin; Rakudo fails to bind
$baktun at all. The cause is Int.polymod on a negative invocant, which
Raku++ answers with negative components and Rakudo refuses outright.
```

Two smaller notes. `X::Invalid::Value.message` is empty under Raku++, so an
invalid `:locale` throws the right class with nothing to read. And Raku++
auto-initialises a role's public attribute from a matching named argument even
when the class defines its own `BUILD`, so an out-of-range `:day` trips the
role's `where` constraint there and reaches the class's own range check under
Rakudo — same refusal, different exception.

One naming trap, identical on both engines: `:haab-index` is the **month** and
`:haab-number` is the **day**. The name that sounds like a day number is the
month index, and there is no `haab-index` method to read it back — use
`.month`. Maya days run 0..19; Aztec days run 1..20.
