#!/usr/bin/env rakupp
# Today — The one thing to know
# https://raku.online/modules/today/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Today
#     rakupp 03-term.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Today;

say 'the term evaluates to a Date : ', today.WHAT.^name;
say '';
say 'these two spellings are NOT part of the API:';
say '  &today      — a code object under that name';
say '  today()     — a call with empty parentheses';
say '';
say 'Raku++ accepts both; Rakudo refuses both at COMPILE time with';
say '"Undeclared routine: today". Code written and tested on Raku++ that';
say 'stores &today in a variable, passes it to map, or writes today() out';
say 'of habit does not compile on Rakudo at all.';

# Output:
#     the term evaluates to a Date : Date
#     
#     these two spellings are NOT part of the API:
#       &today      — a code object under that name
#       today()     — a call with empty parentheses
#     
#     Raku++ accepts both; Rakudo refuses both at COMPILE time with
#     "Undeclared routine: today". Code written and tested on Raku++ that
#     stores &today in a variable, passes it to map, or writes today() out
#     of habit does not compile on Rakudo at all.
