#!/usr/bin/env rakupp
# Data::TypeSystem — Naming a shape
# https://raku.online/modules/data-typesystem/#naming-a-shape
#
# Install what it needs, then run it:
#     rakupp install Data::TypeSystem
#     rakupp 01-deduce.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::TypeSystem;

say deduce-type([1, 2, 3]);
say deduce-type([1, 'a', 2]);
say deduce-type({ name => 'Ada', born => 1815 });
say deduce-type([{ x => 1, y => 2 }, { x => 3, y => 4 }]);
say deduce-type([[1, 2], [3, 4], [5, 6]]);
say deduce-type([[1, 2], [3]]);
say deduce-type({ a => [1, 2], b => [3, 4] });
say deduce-type([1, 'a', 2, 'b'], :tally);
say is-reshapable([[1, 2], [3]]);

# Output:
#     Vector(Atom((Int)), 3)
#     Tuple([Atom((Int)), Atom((Str)), Atom((Int))])
#     Struct([born, name], [Int, Str])
#     Vector(Assoc(Atom((Str)), Atom((Int)), 2), 2)
#     Vector(Vector(Atom((Int)), 2), 3)
#     Tuple([Vector(Atom((Int)), 2), Vector(Atom((Int)), 1)])
#     Assoc(Atom((Str)), Vector(Atom((Int)), 2), 2)
#     Tuple([Atom((Int)) => 2, Atom((Str)) => 2], 4)
#     False
