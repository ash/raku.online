#!/usr/bin/env rakupp
# Lingua::Palindrome — The one thing to know
# https://raku.online/modules/lingua-palindrome/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Lingua::Palindrome
#     rakupp 03-symbols.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Palindrome;

for 'Madam, I\'m Adam',
    "A man, a plan, a canal \c[EM DASH] Panama!",
    'Level +',
    '+Level+',
    "Step on no pets \c[COPYRIGHT SIGN]",
    '2 + 2 = 2 + 2',
    'a_ba' -> $s {
    say sprintf('  %-5s %s', char-palindrome($s), $s);
}
say '';
say '"+" is Sm and "©" is So — neither is <alpha>, <digit>, <punct> or \s,';
say 'so no filter can remove them and an otherwise perfect palindrome comes';
say 'back False. The em dash IS Pd and does get stripped, and "_" is Pc,';
say 'so it is stripped as punctuation — which is the mirror-image surprise.';

# Output:
#       True  Madam, I'm Adam
#       True  A man, a plan, a canal — Panama!
#       False Level +
#       True  +Level+
#       False Step on no pets ©
#       True  2 + 2 = 2 + 2
#       True  a_ba
#     
#     "+" is Sm and "©" is So — neither is <alpha>, <digit>, <punct> or \s,
#     so no filter can remove them and an otherwise perfect palindrome comes
#     back False. The em dash IS Pd and does get stripped, and "_" is Pc,
#     so it is stripped as punctuation — which is the mirror-image surprise.
