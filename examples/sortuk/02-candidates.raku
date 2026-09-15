#!/usr/bin/env rakupp
# sortuk — Sorting
# https://raku.online/modules/sortuk/#sorting
#
# Install what it needs, then run it:
#     rakupp install sortuk
#     rakupp 02-candidates.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use SortUk;

say 'the proto has three candidates:';
say '  sortuk()           = ', sortuk().raku;
say '  sortuk("яблуко")   = ', sortuk('яблуко').raku;
say '  sortuk(@list)      returns a List';
say '';
say 'only the @data candidate carries `is export`, but exporting one';
say 'candidate exports the whole proto, so all three are reachable.';
say '';
my @orig = <в б а>;
my @out  = sortuk(@orig);
say 'input after the call  : ', @orig.join(',');
say 'output                : ', @out.join(',');

# Output:
#     the proto has three candidates:
#       sortuk()           = ()
#       sortuk("яблуко")   = ("яблуко",)
#       sortuk(@list)      returns a List
#     
#     only the @data candidate carries `is export`, but exporting one
#     candidate exports the whole proto, so all three are reachable.
#     
#     input after the call  : в,б,а
#     output                : а,б,в
