#!/usr/bin/env rakupp
# Config::INI — Writing one
# https://raku.online/modules/config-ini/#writing-one
#
# Install what it needs, then run it:
#     rakupp install Config::INI
#     rakupp 02-write.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Config::INI;
use Config::INI::Writer;

say Config::INI::Writer::dump({ server => { host => 'example.test' } });
say '---';
say Config::INI::Writer::dump({ a => 1 }).raku;

# Output:
#     
#     [server]
#     host=example.test
#     
#     ---
#     "a=1\n"
