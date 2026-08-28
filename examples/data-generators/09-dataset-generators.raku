#!/usr/bin/env rakupp
# Data::Generators — Whole tabular datasets
# https://raku.online/modules/data-generators/#whole-tabular-datasets
#
# Install what it needs, then run it:
#     rakupp install Data::Generators
#     rakupp 09-dataset-generators.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Generators;

my @readings = random-tabular-dataset(5, <city temp>, generators => {
    city => { random-word($_) },
    temp => { random-real((-5, 35), $_) },
});
say @readings.elems;
say so @readings.map(*.<temp>).all ~~ Num;
say so ([&&] @readings.map({ -5 <= .<temp> <= 35 }));

# Output:
#     5
#     True
#     True
