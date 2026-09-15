#!/usr/bin/env rakupp
# Lingua::Pangram — Checking
# https://raku.online/modules/lingua-pangram/#checking
#
# Install what it needs, then run it:
#     rakupp install Lingua::Pangram
#     rakupp 02-russian.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Pangram;

my $ru = "\c[CYRILLIC SMALL LETTER A]".."\c[CYRILLIC SMALL LETTER YA]";
say 'the contiguous Cyrillic block "а".."я" holds ', $ru.elems, ' letters';
say '  plus ё separately makes the full 33.';
say '';
my $text = 'Съешь же ещё этих мягких французских булок, да выпей чаю';
say 'pangram-ru(a known Russian pangram) : ', pangram-ru($text);
say 'pangram-ru(the same, ё removed)     : ', pangram-ru($text.subst('ё', 'е', :g));

# Output:
#     the contiguous Cyrillic block "а".."я" holds 32 letters
#       plus ё separately makes the full 33.
#     
#     pangram-ru(a known Russian pangram) : True
#     pangram-ru(the same, ё removed)     : False
