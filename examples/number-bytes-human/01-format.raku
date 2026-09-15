#!/usr/bin/env rakupp
# Number::Bytes::Human — Formatting
# https://raku.online/modules/number-bytes-human/#formatting
#
# Install what it needs, then run it:
#     rakupp install Number::Bytes::Human
#     rakupp 01-format.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Number::Bytes::Human :functions;

for 0, 1, 999, 1023, 1024, 1025, 1536, 1000000, 1048576, 1073741824 -> $n {
    say sprintf('%-12d => %s', $n, format-bytes($n));
}

# Output:
#     0            => 0B
#     1            => 1B
#     999          => 999B
#     1023         => 1023B
#     1024         => 1K
#     1025         => 1K
#     1536         => 2K
#     1000000      => 977K
#     1048576      => 1M
#     1073741824   => 1G
