#!/usr/bin/env rakupp
# sublist — The one thing to know
# https://raku.online/modules/sublist/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install sublist
#     rakupp 02-shadow.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use sublist;

my @needle = 'b', 'c';
my @hay    = 'a', 'b', 'c', 'd';

say 'sublist::index(@needle, @hay) = ', sublist::index(@needle, @hay).raku,
    '   <- correct';
say 'bare index(@needle, @hay)     = ', index(@needle, @hay).raku,
    '   <- the CORE index, on the stringified lists';
say '';
say 'core index stringifies both arguments and finds "b c" at offset 0 of';
say '"a b c d"… which is a perfectly ordinary answer from this API, so';
say 'nothing downstream looks wrong.';
say '';
say 'Rakudo at least warns ("Calling .index on a Array, did you mean';
say '.first( …, :k )?"). Raku++ gives no diagnostic at all.';
say '';
say 'always write sublist::index and sublist::indices.';

# Output:
#     sublist::index(@needle, @hay) = 1   <- correct
#     bare index(@needle, @hay)     = 0   <- the CORE index, on the stringified lists
#     
#     core index stringifies both arguments and finds "b c" at offset 0 of
#     "a b c d"… which is a perfectly ordinary answer from this API, so
#     nothing downstream looks wrong.
#     
#     Rakudo at least warns ("Calling .index on a Array, did you mean
#     .first( …, :k )?"). Raku++ gives no diagnostic at all.
#     
#     always write sublist::index and sublist::indices.
