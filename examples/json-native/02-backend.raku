#!/usr/bin/env rakupp
# JSON::Native — Three backends, and who is answering
# https://raku.online/modules/json-native/#three-backends-and-who-is-answering
#
# Install what it needs, then run it:
#     rakupp install JSON::Native
#     rakupp 02-backend.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Native;

say json-backend;

# One run printed:
#     engine
