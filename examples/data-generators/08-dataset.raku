#!/usr/bin/env rakupp
# Data::Generators — Whole tabular datasets
# https://raku.online/modules/data-generators/#whole-tabular-datasets
#
# Install what it needs, then run it:
#     rakupp install Data::Generators
#     rakupp 08-dataset.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Generators;

my @tbl = random-tabular-dataset(4, <name age score>);
say @tbl.elems;
say @tbl.head.keys.sort.join(',');
say so @tbl.all ~~ Map;

# Output:
#     4
#     age,name,score
#     True
