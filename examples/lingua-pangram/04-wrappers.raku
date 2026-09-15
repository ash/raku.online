#!/usr/bin/env rakupp
# Lingua::Pangram — The alphabets the wrappers pin
# https://raku.online/modules/lingua-pangram/#the-alphabets-the-wrappers-pin
#
# Install what it needs, then run it:
#     rakupp install Lingua::Pangram
#     rakupp 04-wrappers.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Pangram;

my $es = 'Benjamín pidió una bebida de kiwi y fresa; noté que佐 exhausto '
       ~ 'chef vomitó justo sobre el zueco lleno de whisky';
say 'pangram-es(a standard Spanish pangram)             : ', pangram-es($es);
say 'pangram-es(the same, :digraphs)                    : ', pangram-es($es, True);
say '';
say ':digraphs demands ch, ll AND rr. The RAE struck ch and ll from the';
say 'Spanish alphabet in 1994, and rr has never been a letter of it — so';
say 'the flag rejects the very texts it exists to accept.';
say '';
my $fr = 'Portez ce vieux whisky au juge blond qui fume';
say 'pangram-fr(a standard French pangram)              : ', pangram-fr($fr);
say 'pangram-fr(the same, :ligatures)                   : ', pangram-fr($fr, True);
say '';
say ':ligatures demands both æ and œ, which no common French pangram has.';

# Output:
#     pangram-es(a standard Spanish pangram)             : False
#     pangram-es(the same, :digraphs)                    : False
#     
#     :digraphs demands ch, ll AND rr. The RAE struck ch and ll from the
#     Spanish alphabet in 1994, and rr has never been a letter of it — so
#     the flag rejects the very texts it exists to accept.
#     
#     pangram-fr(a standard French pangram)              : True
#     pangram-fr(the same, :ligatures)                   : False
#     
#     :ligatures demands both æ and œ, which no common French pangram has.
