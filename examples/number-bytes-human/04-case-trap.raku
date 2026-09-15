#!/usr/bin/env rakupp
# Number::Bytes::Human — The one thing to know
# https://raku.online/modules/number-bytes-human/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Number::Bytes::Human
#     rakupp 04-case-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Number::Bytes::Human :functions;

for '1K', '1k', '1M', '1m', '1G', '1g' -> $s {
    my $r = try parse-bytes($s);
    say sprintf('%-6s => %s', $s.raku, $! ?? 'refused' !! $r.Str);
}
say '';
say 'every other malformed input throws, so the guard clearly exists —';
say 'lowercase slips past it and produces a plausible-looking number.';

# Output:
#     "1K"   => 1024
#     "1k"   => 0
#     "1M"   => 1048576
#     "1m"   => 0
#     "1G"   => 1073741824
#     "1g"   => 0
#     
#     every other malformed input throws, so the guard clearly exists —
#     lowercase slips past it and produces a plausible-looking number.
