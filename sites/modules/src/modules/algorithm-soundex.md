---
name: Algorithm::Soundex
version: 0.2
auth: zef:raku-community-modules
kind: Distribution · algorithms
summary: The American Soundex code for a name — an initial letter followed by
  digits for the consonant groups that follow it.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Algorithm::Soundex
source: https://github.com/raku-community-modules/Algorithm-Soundex.git
---

## What it is for

Soundex is the oldest phonetic-matching scheme still in daily use: the US
Census has indexed surnames with it since 1880, and genealogy databases,
electoral rolls and hospital record systems still do. Two names that sound
alike get the same four-character code, so a search for `Smith` finds `Smyth`.

This distribution is the American Soundex, implemented as a single regex over
the lower-cased name.

## Coding a name

```raku name="soundex"
use Algorithm::Soundex;

my $sx = Algorithm::Soundex.new;

my %published =
    Robert   => 'R163', Rupert    => 'R163', Rubin    => 'R150',
    Ashcraft => 'A261', Ashcroft  => 'A261', Tymczak  => 'T522',
    Pfister  => 'P236', Honeyman  => 'H555', Euler    => 'E460',
    Gauss    => 'G200', Hilbert   => 'H416', Knuth    => 'K530',
    Lloyd    => 'L300', Washington => 'W252', Lee     => 'L000';

for %published.keys.sort -> $name {
    my $got = $sx.soundex($name);
    say sprintf('%-12s got=%-5s published=%-5s %s',
        $name, $got, %published{$name}, $got eq %published{$name} ?? 'match' !! 'DIFFERS');
}
```

```output
Ashcraft     got=A261  published=A261  match
Ashcroft     got=A261  published=A261  match
Euler        got=E460  published=E460  match
Gauss        got=G200  published=G200  match
Hilbert      got=H416  published=H416  match
Honeyman     got=H555  published=H555  match
Knuth        got=K530  published=K530  match
Lee          got=L000  published=L000  match
Lloyd        got=L300  published=L300  match
Pfister      got=P236  published=P236  match
Robert       got=R163  published=R163  match
Rubin        got=R150  published=R150  match
Rupert       got=R163  published=R163  match
Tymczak      got=T522  published=T522  match
Washington   got=W252  published=W252  match
```

Every published code matches, including the two hard ones: `Ashcraft → A261`,
where the `h` between `s` and `c` makes them merge, and `Tymczak → T522`,
where the `cz` pair collapses.

There is no exported sub — it is a method on a class with no attributes, so
`Algorithm::Soundex.soundex($name)` works on the type object as well as on an
instance.

## What it does with the input

```raku name="input"
use Algorithm::Soundex;

my $sx = Algorithm::Soundex.new;

for 'smith', 'SMITH', 'SmItH', "O'Brien", 'Smith-Jones', 'aeiou', '' -> $in {
    say sprintf('%-14s -> %s', $in.raku, $sx.soundex($in).raku);
}
say '';
say 'the argument is untyped and Cool-coerced:';
say '  soundex(42) -> ', $sx.soundex(42).raku;
```

```output
"smith"        -> "S530"
"SMITH"        -> "S530"
"SmItH"        -> "S530"
"O'Brien"      -> "O165"
"Smith-Jones"  -> "S532"
"aeiou"        -> "A000"
""             -> ""

the argument is untyped and Cool-coerced:
  soundex(42) -> "400"
```

Case is folded, so all three spellings of Smith agree. An apostrophe and a
hyphen are treated as separators rather than letters. `soundex('')` returns
the empty string, not a code and not a failure.

## The one thing to know

A Soundex code is meant to be a letter plus exactly three digits. This one
returns a **three**-character code whenever the name has no codeable consonant
after the first character.

```raku name="short-trap"
use Algorithm::Soundex;

my $sx = Algorithm::Soundex.new;

for <Lee Yee Yu Yao Aiu Iyer Smith> -> $n {
    my $c = $sx.soundex($n);
    say sprintf('%-8s => %-6s chars=%d  four characters? %s',
        $n, "'$c'", $c.chars, $c.chars == 4 ?? 'yes' !! 'NO');
}
```

```output
Lee      => 'L000' chars=4  four characters? yes
Yee      => 'Y00'  chars=3  four characters? NO
Yu       => 'Y00'  chars=3  four characters? NO
Yao      => 'Y00'  chars=3  four characters? NO
Aiu      => 'A000' chars=4  four characters? yes
Iyer     => 'I600' chars=4  four characters? yes
Smith    => 'S530' chars=4  four characters? yes
```

The final step indexes `[0, 2, 3, 4]` out of the intermediate list, discarding
index 1 as the initial letter's own code. When the name has no consonant group
at all, the `0, 0, 0` padding lands at indices 1 to 3 and index 4 is `Nil`,
which joins as the empty string.

`Lee` and `Aiu` come out fine — `L` is codeable and `A` triggers the module's
vowel-handling path. The failure needs a first letter that is neither a vowel
nor `W`/`H` nor itself codeable, which is exactly `Y`, and any non-letter.
`Yee` and `Yu` are real surnames.

Pad the result to four characters yourself if anything downstream assumes a
fixed width.

## Where the two engines differ

On stderr only, and the difference is a warning you would want. Rakudo emits
`Use of uninitialized value in string context` once for every short code
produced; Raku++ emits nothing. So on Raku++ you get a three-character string
with no signal at all that anything went wrong.

Three things that are not engine differences. The first character is copied
through **verbatim**, uncased and unvalidated, so `' Smith'` gives `' 530'`
and `'12345'` gives `'100'`. Leading whitespace also shifts which consonant is
treated as the initial, so a stray space changes more than the first
character. And only ASCII `a`–`z` are codeable, so `Ångström` yields `Å236`
with the `n` treated as if it were the initial.

Despite the distribution's name there is one algorithm here: no Refined
Soundex, no Daitch-Mokotoff, nothing but `soundex`.
