#!/usr/bin/env rakupp
# JSON::Native — Which path answers, on which engine
# https://raku.online/modules/json-native/#which-path-answers-on-which-engine
#
# Install what it needs, then run it:
#     rakupp install JSON::Native
#     rakupp 02-backend.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Native;

say json-backend;

# One run printed:
#     engine
