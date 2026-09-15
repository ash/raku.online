#!/usr/bin/env rakupp
# Lingua::Palindrome — The three granularities
# https://raku.online/modules/lingua-palindrome/#the-three-granularities
#
# Install what it needs, then run it:
#     rakupp install Lingua::Palindrome
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Palindrome;

say 'char-palindrome("racecar")                  = ', char-palindrome('racecar');
say 'char-palindrome("A man, a plan, a canal: Panama") = ',
    char-palindrome('A man, a plan, a canal: Panama');
say '';
say 'word-palindrome("you can cage a swallow can you") = ',
    word-palindrome('you can cage a swallow can you');
say 'word-palindrome("this is not one")               = ',
    word-palindrome('this is not one');
say '';
my $lines = "alpha\nbeta\nalpha";
say 'line-palindrome(three lines, outer two equal)    = ', line-palindrome($lines);
say 'line-palindrome("a\nb\nc")                       = ', line-palindrome("a\nb\nc");

# Output:
#     char-palindrome("racecar")                  = True
#     char-palindrome("A man, a plan, a canal: Panama") = True
#     
#     word-palindrome("you can cage a swallow can you") = False
#     word-palindrome("this is not one")               = False
#     
#     line-palindrome(three lines, outer two equal)    = True
#     line-palindrome("a\nb\nc")                       = False
