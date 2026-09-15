#!/usr/bin/env rakupp
# Parameterizable — The generated name loses value parameters
# https://raku.online/modules/parameterizable/#the-generated-name-loses-value-parameters
#
# Install what it needs, then run it:
#     rakupp install Parameterizable
#     rakupp 03-names.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Parameterizable;

role Cap[$n] { method limit { $n } }
class Capped is Parameterizable { method MIXIN($n) { Cap[$n] } }

say 'Capped[5].^name  : ', Capped[5].^name;
say 'Capped[7].^name  : ', Capped[7].^name;
say 'same name ?      : ', Capped[5].^name eq Capped[7].^name;
say 'same type ?      : ', (Capped[5] === Capped[7]);
say '';
say 'the name is built from @pos.map(*.^name), so every VALUE parameter';
say 'collapses to its type`s name. Two genuinely different types both';
say 'print as Capped[Int] — debug output, .gist and error messages cannot';
say 'tell them apart.';
say '';
say 'they are still distinct types, and their methods still answer:';
say '  Capped[5].limit : ', Capped[5].limit;
say '  Capped[7].limit : ', Capped[7].limit;

# Output:
#     Capped[5].^name  : Capped[Int]
#     Capped[7].^name  : Capped[Int]
#     same name ?      : True
#     same type ?      : False
#     
#     the name is built from @pos.map(*.^name), so every VALUE parameter
#     collapses to its type`s name. Two genuinely different types both
#     print as Capped[Int] — debug output, .gist and error messages cannot
#     tell them apart.
#     
#     they are still distinct types, and their methods still answer:
#       Capped[5].limit : 5
#       Capped[7].limit : 7
