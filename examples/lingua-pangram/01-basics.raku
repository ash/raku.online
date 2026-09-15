#!/usr/bin/env rakupp
# Lingua::Pangram — Checking
# https://raku.online/modules/lingua-pangram/#checking
#
# Install what it needs, then run it:
#     rakupp install Lingua::Pangram
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Pangram;

my $fox = 'The quick brown fox jumps over the lazy dog';
say 'pangram-en(the fox)        : ', pangram-en($fox);
say 'pangram-en(missing the q)  : ', pangram-en($fox.subst('quick', 'swift'));
say 'case is folded             : ', pangram-en($fox.uc);
say 'pangram-en("")             : ', pangram-en('');
say '';
say 'the generic form takes a string of characters, a Range, or a list:';
say '  pangram($fox, "abc")         = ', pangram($fox, 'abc');
say '  pangram($fox, "a".."z")      = ', pangram($fox, 'a'..'z');
say '  pangram($fox, <q u i c k>)   = ', pangram($fox, <q u i c k>);

# Output:
#     pangram-en(the fox)        : True
#     pangram-en(missing the q)  : False
#     case is folded             : True
#     pangram-en("")             : False
#     
#     the generic form takes a string of characters, a Range, or a list:
#       pangram($fox, "abc")         = True
#       pangram($fox, "a".."z")      = True
#       pangram($fox, <q u i c k>)   = True
