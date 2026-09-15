#!/usr/bin/env rakupp
# Lingua::NumericWordForms — Nineteen grammars, and guessing between them
# https://raku.online/modules/lingua-numericwordforms/#nineteen-grammars-and-guessing-between-them
#
# Install what it needs, then run it:
#     rakupp install Lingua::NumericWordForms
#     rakupp 02-languages.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     English: told=2026  guessed=english => 2026
#     French: told=2026  guessed=french => 2026
#     German: told=2026  guessed=german => 2026
#     Japanese: told=2026  guessed=japanese => 2026
#     Russian: told=2026  guessed=russian => 2026
#     Spanish: told=2026  guessed=spanish => 2026
#     two thousand, twenty six
#     二千二十六
