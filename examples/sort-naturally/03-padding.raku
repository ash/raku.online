#!/usr/bin/env rakupp
# Sort::Naturally — The one thing to know
# https://raku.online/modules/sort-naturally/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Sort::Naturally
#     rakupp 03-padding.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Sort::Naturally;

my @nums = <007 7 08 8 0100 999>;
say 'plain .sort : ', @nums.sort.join(' ');
say 'naturally   : ', @nums.sort({ .&naturally }).join(' ');
say '';
say 'the key encodes a run as "0" ~ chr(length) ~ digits, and chr(4) is';
say 'greater than chr(3) — so a 4-character run always outranks a';
say '3-character one. 0100 is one hundred and it sorts AFTER 999.';
say '';
say 'zero-padded IDs, %03d filenames and embedded ISO dates are exactly';
say 'the data people reach for a natural sort with.';
say '';
say 'decimals are read as integers too:';
say '  ', <1.5 1.10 1.9 1.25>.sort({ .&naturally }).join(' ');
say 'and the minus sign is not part of the number:';
say '  ', <-5 -10 3 -3>.sort({ .&naturally }).join(' ');

# Output:
#     plain .sort : 007 7 08 8 0100 999
#     naturally   : 7 8 08 007 999 0100
#     
#     the key encodes a run as "0" ~ chr(length) ~ digits, and chr(4) is
#     greater than chr(3) — so a 4-character run always outranks a
#     3-character one. 0100 is one hundred and it sorts AFTER 999.
#     
#     zero-padded IDs, %03d filenames and embedded ISO dates are exactly
#     the data people reach for a natural sort with.
#     
#     decimals are read as integers too:
#       1.5 1.9 1.10 1.25
#     and the minus sign is not part of the number:
#       -3 -5 -10 3
