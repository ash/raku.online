#!/usr/bin/env rakupp
# Algorithm::Manacher — The edges
# https://raku.online/modules/algorithm-manacher/#the-edges
#
# Install what it needs, then run it:
#     rakupp install Algorithm::Manacher
#     rakupp 02-edges.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::Manacher;

say 'empty text ""  : is-palindrome=', Algorithm::Manacher.new(text => '').is-palindrome;
say 'one char  "x"  : is-palindrome=', Algorithm::Manacher.new(text => 'x').is-palindrome;
say 'two same  "xx" : is-palindrome=', Algorithm::Manacher.new(text => 'xx').is-palindrome;
say '';
my $jp = Algorithm::Manacher.new(text => "たけやぶやけた");
say 'non-ASCII      : is-palindrome=', $jp.is-palindrome;
my $comb = Algorithm::Manacher.new(text => "e\x[301]e\x[301]");
say 'combining mark : chars=', "e\x[301]e\x[301]".chars, ' is-palindrome=', $comb.is-palindrome;

# Output:
#     empty text ""  : is-palindrome=False
#     one char  "x"  : is-palindrome=True
#     two same  "xx" : is-palindrome=True
#     
#     non-ASCII      : is-palindrome=True
#     combining mark : chars=2 is-palindrome=True
