---
name: Locale::Dates
version: 0.0.7
auth: zef:lizmat
kind: Distribution · localisation
summary: Weekday and month names, am/pm markers and strftime templates for
  seven locales — falling back to English, silently, and case-sensitively.
status: divergent
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/Locale::Dates
source: https://codeberg.org/lizmat/Locale-Dates.git
---

## What it is for

Formatting a date in someone else's language needs the names: *Montag* not
*Monday*, *января* not *January*, and the format string that puts them in the
right order. This distribution carries seven such tables and hands you the one
you ask for.

## Asking for a locale

```raku name="basics"
use Locale::Dates;

say 'known locales : ', Locale::Dates.known-locales.sort.join(' ');
say '';
my $en = Locale::Dates.new('EN');
say 'code          : ', $en.code;
say 'weekdays      : ', $en.weekdays.elems, ' entries -> ', $en.weekdays.join(' ');
say 'months        : ', $en.months.elems, ' entries -> ', $en.months.join(' ');
say 'abbr-weekdays : ', $en.abbreviated-weekdays.join(' ');
say 'am / pm       : ', $en.am, ' / ', $en.pm;
say 'AM / PM       : ', $en.AM, ' / ', $en.PM;
say '';
say 'date format   : ', $en.date-representation;
say 'time format   : ', $en.time-representation;
```

```output
known locales : BG DE EN FR NL PT RU

code          : EN
weekdays      : 8 entries -> Sunday Monday Tuesday Wednesday Thursday Friday Saturday Sunday
months        : 13 entries -> ? January February March April May June July August September October November December
abbr-weekdays : Sun Mon Tue Wed Thu Fri Sat Sun
am / pm       : am / pm
AM / PM       : AM / PM

date format   : %a %b %e %Y
time format   : %T
```

`.weekdays` has **eight** entries — Sunday at both index 0 and index 7, so
0-based and ISO 1-based indexing both work — and `.months` has thirteen, with
a literal `"?"` at index 0.

```raku name="indexing"
use Locale::Dates;

my $d  = Date.new(2026, 3, 15);
my $de = Locale::Dates.new('DE');
say 'date            : ', $d, ' (Date.day-of-week = ', $d.day-of-week, ')';
say 'German weekday  : ', $de.weekdays[$d.day-of-week];
say 'German month    : ', $de.months[$d.month];
say '';
say 'that is why the tables are padded: month 3 really is index 3.';
```

```output
date            : 2026-03-15 (Date.day-of-week = 7)
German weekday  : Sontag
German month    : März

that is why the tables are padded: month 3 really is index 3.
```

## The one thing to know

An unrecognised locale code is not an error and is not `Nil` — you silently
get English. And the lookup is case-sensitive, so the natural lowercase code
gets you English too.

```raku name="fallback"
use Locale::Dates;

for 'RU', 'ru', 'XX', 'Klingon', '' -> $code {
    say sprintf('  new(%-10s).code = %s', $code.raku, Locale::Dates.new($code).code);
}
say '';
say 'a program that does Locale::Dates.new($user-locale) will happily';
say 'print English month names for every locale it does not recognise,';
say 'with no signal of any kind. Check the code you got back:';
say '';
sub dates-for($code) {
    my $l = Locale::Dates.new($code);
    $l.code eq $code.uc ?? $l !! die "no table for '$code'"
}
say '  dates-for("RU").code : ', dates-for('RU').code;
my $r = try dates-for('ru');
say '  dates-for("ru")      : ', $! ?? $!.message !! 'accepted';
```

```output
  new("RU"      ).code = RU
  new("ru"      ).code = EN
  new("XX"      ).code = EN
  new("Klingon" ).code = EN
  new(""        ).code = EN

a program that does Locale::Dates.new($user-locale) will happily
print English month names for every locale it does not recognise,
with no signal of any kind. Check the code you got back:

  dates-for("RU").code : RU
  dates-for("ru")      : no table for 'ru'
```

`new` is also not a constructor for the known codes — it returns a shared
singleton, so `Locale::Dates.new('EN') === Locale::Dates.new('EN')` is `True`.

## What the tables actually contain

```raku name="quirks"
use Locale::Dates;

my $fr = Locale::Dates.new('FR');
say 'French abbreviated months : ', $fr.abbreviated-months[1..12].join(' ');
say '  distinct ?              : ',
    $fr.abbreviated-months[1..12].unique.elems, ' of 12';
say '  juin and juillet both abbreviate to the same three letters.';
say '';
for <RU BG> -> $c {
    my $l = Locale::Dates.new($c);
    say sprintf('%s am/pm : %s / %s   (both empty — a 12-hour formatter gets nothing)',
                $c, $l.am.raku, $l.pm.raku);
}
say '';
my $ru = Locale::Dates.new('RU');
say 'Russian months are in the GENITIVE — the form used inside a date,';
say 'not the name of the month:';
say '  ', $ru.months[1..3].join(' ');
```

```output
French abbreviated months : jan fév mar avr mai jui jui aoû sep oct nov déc
  distinct ?              : 11 of 12
  juin and juillet both abbreviate to the same three letters.

RU am/pm : "" / ""   (both empty — a 12-hour formatter gets nothing)
BG am/pm : "" / ""   (both empty — a 12-hour formatter gets nothing)

Russian months are in the GENITIVE — the form used inside a date,
not the name of the month:
  января февраля марта
```

Abbreviations are `substr(0, 3)` of the full name for every locale except
Dutch, which supplies its own, and Russian weekdays. The German table has two
data errors — weekday 7 is `Sontag` and month 12 is `December`.

## Where the two engines differ

`known-locales` comes back as an `Array` under Raku++ and a `List` under
Rakudo, because `my constant @a = <…>` binds a mutable container on one engine
and an immutable one on the other. Read it, do not write to it.

```raku name="containers"
use Locale::Dates;

my @codes = Locale::Dates.known-locales.sort;
say 'sorted into your own array : ', @codes.join(' ');
say '';
say 'the name tables themselves are immutable Lists on BOTH engines, so';
say 'the shared singletons cannot be corrupted through them:';
my $en = Locale::Dates.new('EN');
my $ok = try { $en.weekdays[1] = 'Mandag'; True };
say '  writing to .weekdays -> ', $ok ?? 'succeeded' !! 'refused';
say '  .weekdays[1] is still ', $en.weekdays[1];
```

```output
sorted into your own array : BG DE EN FR NL PT RU

the name tables themselves are immutable Lists on BOTH engines, so
the shared singletons cannot be corrupted through them:
  writing to .weekdays -> refused
  .weekdays[1] is still Monday
```

One further divergence, on the constructor's named form: `Locale::Dates.new(:code<XX>)`
with no other arguments builds an object with an empty code under Raku++ and
raises `X::Attribute::Required` under Rakudo. Use the positional form, which
is the documented one and behaves the same on both.
