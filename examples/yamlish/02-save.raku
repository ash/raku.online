#!/usr/bin/env rakupp
# YAMLish — Writing it back
# https://raku.online/ecosystem/yamlish/#writing-it-back
#
# Install what it needs, then run it:
#     rakupp install YAMLish
#     rakupp 02-save.raku
#
# Run under Raku++ 3.6.0 (dev build) and Rakudo 2026.07 every time the site is
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
