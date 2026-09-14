#!/usr/bin/env rakupp
# Data::TypeSystem — The one thing to know
# https://raku.online/modules/data-typesystem/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Data::TypeSystem
#     rakupp 02-blind-spots.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::TypeSystem;

say deduce-type([{ x => 1, y => 2 }, { x => 3, z => 4 }]);
say is-reshapable([{ x => 1, y => 2 }, { x => 3, z => 4 }]);
say deduce-type([True, False]);
say deduce-type([2.5e0, 1e0]);

# Output:
#     Vector(Assoc(Atom((Str)), Atom((Int)), 2), 2)
#     True
#     Vector(Atom((Int)), 2)
#     Vector(Atom((Numeric)), 2)
