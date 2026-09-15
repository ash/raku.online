#!/usr/bin/env rakupp
# Lingua::Palindrome — The flags
# https://raku.online/modules/lingua-palindrome/#the-flags
#
# Install what it needs, then run it:
#     rakupp install Lingua::Palindrome
#     rakupp 02-flags.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Palindrome;

my $s = 'A man, a plan, a canal: Panama';
say 'default (fold case, drop punct+space) : ', char-palindrome($s);
say ':case (case-SENSITIVE)                : ', char-palindrome($s, :case);
say ':punct (keep punctuation)             : ', char-palindrome($s, :punct);
say ':space (keep whitespace)              : ', char-palindrome($s, :space);
say '';
say 'digits are kept by default:';
say '  char-palindrome("1a2a1")            : ', char-palindrome('1a2a1');
say '  char-palindrome("1a2a1", :!digit)   : ', char-palindrome('1a2a1', :!digit);
say '';
say 'a filter that empties the string is vacuously true:';
say '  char-palindrome("hello 42", :!alpha, :!digit) : ',
    char-palindrome('hello 42', :!alpha, :!digit);

# Output:
#     default (fold case, drop punct+space) : True
#     :case (case-SENSITIVE)                : False
#     :punct (keep punctuation)             : False
#     :space (keep whitespace)              : False
#     
#     digits are kept by default:
#       char-palindrome("1a2a1")            : True
#       char-palindrome("1a2a1", :!digit)   : True
#     
#     a filter that empties the string is vacuously true:
#       char-palindrome("hello 42", :!alpha, :!digit) : True
