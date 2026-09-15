#!/usr/bin/env rakupp
# sublist — The comparison is textual
# https://raku.online/modules/sublist/#the-comparison-is-textual
#
# Install what it needs, then run it:
#     rakupp install sublist
#     rakupp 03-stringify.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use sublist;

my @needle = 'a', 'b c', 'd';
my @hay    = 'a', 'b', 'c d';

say 'needle : ', @needle.raku;
say 'hay    : ', @hay.raku;
say 'index  : ', sublist::index(@needle, @hay).raku, '   <- a false positive';
say '';
say 'element-wise, they do not match:';
say '  ', (@needle Zeq @hay[0..2]).raku;
say '';
say 'the comparison is `@a eq @b[$_ ..^ $_+@a]` — both slices are';
say 'stringified and joined with spaces, so element boundaries vanish.';
say '';
say 'the same mechanism makes it type-blind:';
say '  sublist::index((1, 2), ("0", "1", "2")) = ',
    sublist::index((1, 2), ('0', '1', '2')).raku;
say '';
say 'compare element-wise yourself if that matters:';
sub find(@needle, @hay) {
    (0 .. @hay.elems - @needle.elems).first({
        @needle eqv @hay[$_ ..^ $_ + @needle]
    })
}
say '  find(@needle, @hay) = ', find(@needle, @hay).raku;

# Output:
#     needle : ["a", "b c", "d"]
#     hay    : ["a", "b", "c d"]
#     index  : 0   <- a false positive
#     
#     element-wise, they do not match:
#       (Bool::True, Bool::False, Bool::False).Seq
#     
#     the comparison is `@a eq @b[$_ ..^ $_+@a]` — both slices are
#     stringified and joined with spaces, so element boundaries vanish.
#     
#     the same mechanism makes it type-blind:
#       sublist::index((1, 2), ("0", "1", "2")) = 1
#     
#     compare element-wise yourself if that matters:
#       find(@needle, @hay) = Nil
