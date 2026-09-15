#!/usr/bin/env rakupp
# Parameterizable — Using it
# https://raku.online/modules/parameterizable/#using-it
#
# Install what it needs, then run it:
#     rakupp install Parameterizable
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Parameterizable;

role Typed[::T] {
    method of { T }
    method tag { 'TYPED' }
}
class Box is Parameterizable {
    has $.value;
    method MIXIN(::T) { Typed[T] }
}

say 'Box[Int].^name        : ', Box[Int].^name;
say 'Box[Int] ~~ Box       : ', (Box[Int] ~~ Box);
say 'Box[Int] === Box[Int] : ', (Box[Int] === Box[Int]);
say 'Box[Int] is Box ?     : ', (Box[Int] === Box);
say '';
say 'a value parameter works too:';
role Tag[$t] { method tag { "TAGGED-$t" } }
class C is Parameterizable {
    method MIXIN($t) { Tag[$t] }
}
say '  C[5].tag   : ', C[5].tag;
say '  C["s"].tag : ', C['s'].tag;

# Output:
#     Box[Int].^name        : Box[Int]
#     Box[Int] ~~ Box       : True
#     Box[Int] === Box[Int] : True
#     Box[Int] is Box ?     : False
#     
#     a value parameter works too:
#       C[5].tag   : TAGGED-5
#       C["s"].tag : TAGGED-s
