---
name: Date::Names
version: 2.3.2
auth: zef:tbrowder
kind: Distribution · time
summary: The names of the months and weekdays in fourteen languages — full,
  abbreviated, in the case and truncation you ask for — and the reverse
  lookup from a name to its number.
status: full
suite: 19 files, green
tested: 2026-09-14
license: Artistic-2.0
depends: Abbreviations
raku-land: https://raku.land/zef:tbrowder/Date::Names
source: https://github.com/tbrowder/Date-Names
---

## What it is for

A `Date` knows that it is month 9 and weekday 1, and nothing more; the word
*September* is not in the core, in any language. This distribution is the
table — English, German, French, Spanish, Dutch, Italian, Norwegian (both
written forms), Polish, Romanian, Russian, Ukrainian, Indonesian — with one
object per language answering `mon(9)` and `dow(1)`, in full or cut to a
length, and going the other way from a name to its number. It is the data
under `Date::Calendar::Strftime`'s `%A` and `%B`, and four distributions
depend on it.

## Names in and out

```raku name="names"
use Date::Names;

my $en = Date::Names.new;
say $en.mon(9), ' ', $en.mon(9, 3), ' ', $en.dow(1), ' ', $en.dow(7, 2);
say $en.mon2num('September'), ' ', $en.dow2num('Sat');
for <de fr es nl uk> -> $lang {
    my $d = Date::Names.new(:$lang);
    say "$lang: ", $d.mon(9), ' / ', $d.dow(1), ' / ', $d.mon(9, 3);
}
say Date::Names.new(lang => 'de').mfull.join(', ');
say (try { $en.mon(13) }) // $!.^name;
say (try { Date::Names.new(lang => 'xx') }) // $!.^name;
```

```output
September Sep Monday Su
9 6
de: September / Montag / Sep
fr: septembre / lundi / sep
es: septiembre / lunes / sep
nl: september / maandag / sep
uk: вересень / понеділок / вер
Januar, Februar, März, April, Mai, Juni, Juli, August, September, Oktober, November, Dezember
X::TypeCheck::Binding::Parameter
X::NoSuchSymbol
```

Months are 1 to 12 and weekdays 1 to 7 with Monday first, as `Date` counts
them, so `$en.dow($date.day-of-week)` needs no arithmetic. The second
argument truncates to that many characters; `mfull` and `dfull` hand over
the whole list for a language. A month number outside the range is refused
by the signature — the `where` clause on it — rather than answered with
something.

## The one thing to know

Each language is its own unit, found by name at run time. `Date::Names.new`
builds `Date::Names::de` out of the string `de`, and a language that is not
shipped is a symbol that does not exist — the last line above, and
`X::NoSuchSymbol` is the right answer to it. Under the Raku++ 3.28.0
release that lookup came back as an undefined value instead of a failure,
and the object was built around nothing: every `mon` and `dow` on it was
`Any`, with no error until something tried to print one. The engine now
answers a missing package symbol the way Rakudo does, so the mistake is
loud again.

The names are the module's data, and its data has the conventions of each
language: French and Spanish months are lowercase, German and English are
capitalised, and `:case` on the constructor changes that only if you ask.
