#!/usr/bin/env rakupp
# YAMLish — Writing it back
# https://raku.online/modules/yamlish/#writing-it-back
#
# Install what it needs, then run it:
#     rakupp install YAMLish
#     rakupp 02-save.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use YAMLish;

print save-yaml({ name => 'raku', tags => <fast fun>, depth => 3 });

# Output:
#     ---
#     "depth": 3
#     "name": "raku"
#     "tags": 
#       - "fast"
#       - "fun"
#     ...
