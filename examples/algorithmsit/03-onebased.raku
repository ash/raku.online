#!/usr/bin/env rakupp
# AlgorithmsIT — `ArrayOneBased`
# https://raku.online/modules/algorithmsit/#arrayonebased
#
# Install what it needs, then run it:
#     rakupp install AlgorithmsIT
#     rakupp 03-onebased.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use AlgorithmsIT::Classes;

my $a = ArrayOneBased.new('abc');
say 'new("abc")      : ', $a.gist;
say '  .elems        : ', $a.elems, '   .length : ', $a.length;
say '  [1]           : ', $a[1].raku, '   <- ONE-based';
say '  [0]           : ', $a[0].raku, '   <- the sentinel';
say '  [4]           : ', $a[4].raku, '   <- past the end, does not grow';
say '  .arr          : ', $a.arr.raku;
say '';
say 'three constructors:';
say '  new(5)        : ', ArrayOneBased.new(5).gist;
say '  new(3, 7)     : ', ArrayOneBased.new(3, 7).gist;
say '  new((10,20))  : ', ArrayOneBased.new((10, 20)).gist;
say '';
my $r = try ArrayOneBased.new(1);
say '  new(1)        : ', $! ?? 'refused — end must exceed start' !! $r.gist;
say '  use new((1,)) for a one-element array.';
say '';
say 'A1B is the same type : ', (A1B === ArrayOneBased);

# Output:
#     new("abc")      : [ a, b, c ]
#       .elems        : 3   .length : 3
#       [1]           : "a"   <- ONE-based
#       [0]           : -1   <- the sentinel
#       [4]           : Any   <- past the end, does not grow
#       .arr          : [-1, "a", "b", "c"]
#     
#     three constructors:
#       new(5)        : [ 1, 2, 3, 4, 5 ]
#       new(3, 7)     : [ 3, 4, 5, 6, 7 ]
#       new((10,20))  : [ 10, 20 ]
#     
#       new(1)        : refused — end must exceed start
#       use new((1,)) for a one-element array.
#     
#     A1B is the same type : True
