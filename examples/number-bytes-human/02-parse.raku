#!/usr/bin/env rakupp
# Number::Bytes::Human — Parsing
# https://raku.online/modules/number-bytes-human/#parsing
#
# Install what it needs, then run it:
#     rakupp install Number::Bytes::Human
#     rakupp 02-parse.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Number::Bytes::Human :functions;

for '1K', '1KB', '1M', '1T', '1P' -> $s {
    say sprintf('%-6s => %d', $s.raku, parse-bytes($s));
}
say '';
say 'malformed input is refused:';
for '1', '1024', 'banana', '' -> $s {
    my $r = try parse-bytes($s);
    say sprintf('  %-10s => %s', $s.raku, $! ?? 'refused' !! $r.Str);
}

# Output:
#     "1K"   => 1024
#     "1KB"  => 1024
#     "1M"   => 1048576
#     "1T"   => 1099511627776
#     "1P"   => 1125899906842624
#     
#     malformed input is refused:
#       "1"        => refused
#       "1024"     => refused
#       "banana"   => refused
#       ""         => refused
