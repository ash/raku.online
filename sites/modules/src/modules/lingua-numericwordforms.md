---
name: Lingua::NumericWordForms
version: 0.6.2
auth: zef:antononcube
kind: Distribution · language
summary: Numbers spelled out as words and read back again, across nineteen
  languages — with automatic detection of which language a spelled-out
  number is in.
status: full
suite: 25 files, green
tested: 2026-09-15
license: Artistic-2.0
raku-land: https://raku.land/zef:antononcube/Lingua::NumericWordForms
source: https://github.com/antononcube/Raku-Lingua-NumericWordForms
---

## What it is for

Turning 2026 into "two thousand twenty six" is a cheque printer, an
accessibility layer, a text-to-speech front end. Turning "две тысячи
двадцать шесть" back into 2026 is the harder and rarer direction, and it is
what a natural-language interface needs when a person types a quantity as
words. This distribution does both, and across a genuinely wide set of
languages — nineteen grammars, from Armenian and Azerbaijani through
Japanese and Korean to Ukrainian, plus Koremutake, a syllable encoding of
integers that is not a language at all.

It can also tell you which language a spelled-out number is in, by trying
the grammars.

## Reading and writing

```raku name="both-ways"
use Lingua::NumericWordForms;

for 0, 42, 1234, 2026, 1_000_000 -> $n {
    my $words = to-numeric-word-form($n);
    say $n, ' -> ', $words, ' -> ', from-numeric-word-form($words);
}

say to-numeric-word-form([1, 2, 3], 'English');
say from-numeric-word-form(['one', 'two', 'three']);
```

```output
0 -> zero -> 0
42 -> forty two -> 42
1234 -> one thousand, two hundred thirty four -> 1234
2026 -> two thousand, twenty six -> 2026
1000000 -> one million -> 1000000
(one two three)
(1 2 3)
```

## Nineteen grammars, and guessing between them

```raku name="languages"
use Lingua::NumericWordForms;

my %samples =
    English  => 'two thousand twenty six',
    Russian  => 'две тысячи двадцать шесть',
    Spanish  => 'dos mil veintiséis',
    German   => 'zweitausendsechsundzwanzig',
    French   => 'deux mille vingt-six',
    Japanese => '二千二十六';

for %samples.keys.sort -> $lang {
    say $lang, ': told=', from-numeric-word-form(%samples{$lang}, $lang),
        '  guessed=', from-numeric-word-form(%samples{$lang}, :p);
}

say translate-numeric-word-form('две тысячи двадцать шесть', :from<Russian>, :to<English>);
say translate-numeric-word-form('two thousand twenty six', :from<English>, :to<Japanese>);
```

```output
English: told=2026  guessed=english => 2026
French: told=2026  guessed=french => 2026
German: told=2026  guessed=german => 2026
Japanese: told=2026  guessed=japanese => 2026
Russian: told=2026  guessed=russian => 2026
Spanish: told=2026  guessed=spanish => 2026
two thousand, twenty six
二千二十六
```

Passing `:p` returns a pair of the detected language and the number, which
is the shape to use when the input could be in any of them. `translate`
is the two directions composed: read in one language, write in another.

## The one thing to know

It parses nineteen languages and can only **write** five of them. Ask for
any of the other fourteen and you get English back, with a note on standard
error and a perfectly ordinary string as the return value:

```raku name="only-five"
use Lingua::NumericWordForms;

my @langs = <Bulgarian English Japanese Russian Koremutake
             Spanish German French Polish Korean>;
my $english = to-numeric-word-form(42, 'English');
for @langs -> $lang {
    my $out = to-numeric-word-form(42, $lang);
    say sprintf('%-11s %-18s %s', $lang, $out,
                ($out eq $english && $lang ne 'English') ?? 'silently English' !! '');
}
say to-numeric-word-form(42, 'Klingon');
say to-numeric-word-form(42, 'Klingon').defined;
```

```output
Bulgarian   четиридесет и две  
English     forty two          
Japanese    四十二                
Russian     сорок два          
Koremutake  la                 
Spanish     forty two          silently English
German      forty two          silently English
French      forty two          silently English
Polish      forty two          silently English
Korean      forty two          silently English
forty two
True
```

Bulgarian, English, Japanese, Russian and Koremutake have generator
classes; the rest have only grammars, and the generator falls back rather
than refusing. An invented language behaves the same way, so there is no
way to tell a supported language from an unsupported one except by
comparing the output against English and guessing. The same fallback
quietly defeats `translate-numeric-word-form` with a `:to` in the other
fourteen.

Watch the warning channel, too: the fallback notice goes to standard error,
so a program capturing only standard output never sees it. And negative
numbers throw in every language except Russian.
