#!/usr/bin/env rakupp
# Data::RandomKeep — The one thing to know
# https://raku.online/modules/data-randomkeep/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Data::RandomKeep
#     rakupp 03-sorted.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::RandomKeep;

my $k = Data::RandomKeep.new(4);
$k.offer(40, 30, 20, 10);
say 'offered : 40, 30, 20, 10';
say 'kept    : ', $k.kept.join(', '), '   <- ascending, not offer order';
say '';
say 'offered words : delta alpha charlie bravo';
say 'kept          : it throws — the sort numifies each word, and';
say '                "delta" is not a number';
say '';
say 'the method is';
say '  return @!kept.map({ $_[1] }).sort({ $^a[0] <=> $^b[0] });';
say 'and the .map has ALREADY replaced each [nb-seen, item] pair with the';
say 'bare item — so the comparator`s $^a[0] indexes the ITEM, which for a';
say 'scalar is the item itself, numified by <=>.';
say '';
say 'so the module`s headline application — keeping N random LINES of a';
say 'file — cannot work directly. Offer INDICES and keep the lines';
say 'yourself; offer is a flattening slurpy, so a tuple would not survive';
say 'anyway:';
my @lines = <first second third fourth fifth>;
my $idx = Data::RandomKeep.new(2);
$idx.offer(^@lines);
my @chosen = $idx.kept.map({ @lines[$_] });
say '  sampled 2 of ', @lines.elems, ' lines : ', @chosen.elems, ' back';
say '  all of them real lines           : ', so @chosen.all (elem) @lines;

# Output:
#     offered : 40, 30, 20, 10
#     kept    : 10, 20, 30, 40   <- ascending, not offer order
#     
#     offered words : delta alpha charlie bravo
#     kept          : it throws — the sort numifies each word, and
#                     "delta" is not a number
#     
#     the method is
#       return @!kept.map({ $_[1] }).sort({ $^a[0] <=> $^b[0] });
#     and the .map has ALREADY replaced each [nb-seen, item] pair with the
#     bare item — so the comparator`s $^a[0] indexes the ITEM, which for a
#     scalar is the item itself, numified by <=>.
#     
#     so the module`s headline application — keeping N random LINES of a
#     file — cannot work directly. Offer INDICES and keep the lines
#     yourself; offer is a flattening slurpy, so a tuple would not survive
#     anyway:
#       sampled 2 of 5 lines : 2 back
#       all of them real lines           : True
