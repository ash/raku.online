#!/usr/bin/env rakupp
# Lingua::Palindrome — The one thing to know
# https://raku.online/modules/lingua-palindrome/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Lingua::Palindrome
#     rakupp 04-foldcase.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Palindrome;

say q{'ß'.fc is }, "\c[LATIN SMALL LETTER SHARP S]".fc.raku, ', so:';
for "\c[LATIN SMALL LETTER SHARP S]",
    "s\c[LATIN SMALL LETTER SHARP S]",
    "\c[LATIN SMALL LETTER SHARP S]s",
    "Stra\c[LATIN SMALL LETTER SHARP S]e" -> $s {
    say sprintf('  default %-5s  :case %-5s  %s',
                char-palindrome($s), char-palindrome($s, :case), $s);
}
say '';
say 'sß and ßs are reported as palindromes under the default';
say 'case-insensitive filter. Pass :case to stop it.';

# Output:
#     'ß'.fc is "ss", so:
#       default True   :case True   ß
#       default True   :case False  sß
#       default True   :case False  ßs
#       default False  :case False  Straße
#     
#     sß and ßs are reported as palindromes under the default
#     case-insensitive filter. Pass :case to stop it.
