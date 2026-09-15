#!/usr/bin/env rakupp
# Time::Duration::Parser — Parsing a duration
# https://raku.online/modules/time-duration-parser/#parsing-a-duration
#
# Install what it needs, then run it:
#     rakupp install Time::Duration::Parser
#     rakupp 01-parse.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Time::Duration::Parser;

for '30 seconds', '2 minutes', '1 hour', '3 days', '1 week',
    '1 week 2 days', '1 h 30 m' -> $s {
    say sprintf('%-14s -> %s seconds', "'$s'", duration-to-seconds($s));
}

# Output:
#     '30 seconds'   -> 30 seconds
#     '2 minutes'    -> 120 seconds
#     '1 hour'       -> 3600 seconds
#     '3 days'       -> 259200 seconds
#     '1 week'       -> 604800 seconds
#     '1 week 2 days' -> 777600 seconds
#     '1 h 30 m'     -> 5400 seconds
