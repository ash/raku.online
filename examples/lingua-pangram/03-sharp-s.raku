#!/usr/bin/env rakupp
# Lingua::Pangram — The one thing to know
# https://raku.online/modules/lingua-pangram/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Lingua::Pangram
#     rakupp 03-sharp-s.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Pangram;

my $de = 'Victor jagt zwölf Boxkämpfer quer über den großen Sylter Deich';
say 'with a real ß  : ', pangram-de($de);
say 'ß spelled ss   : ', pangram-de($de.subst("\c[LATIN SMALL LETTER SHARP S]", 'ss'));
say 'no ß and no ss : ', pangram-de($de.subst("gro\c[LATIN SMALL LETTER SHARP S]en", 'groben'));
say '';
say 'a German text in Swiss orthography — which never uses ß — passes as';
say 'a German pangram, and there is no way to demand the actual character.';

# Output:
#     with a real ß  : True
#     ß spelled ss   : True
#     no ß and no ss : False
#     
#     a German text in Swiss orthography — which never uses ß — passes as
#     a German pangram, and there is no way to demand the actual character.
