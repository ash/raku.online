#!/usr/bin/env rakupp
# YAMLish — The Norway problem
# https://raku.online/modules/yamlish/#the-norway-problem
#
# Install what it needs, then run it:
#     rakupp install YAMLish
#     rakupp 05-norway.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use YAMLish;

my %d = load-yaml("yes: true\nno: false\nname: raku\n");
say %d.keys.sort.map(*.raku).join(' ');
say %d{True}.raku;

# Output:
#     "False" "True" "name"
#     Bool::True
