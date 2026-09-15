#!/usr/bin/env rakupp
# LEB128 — Malformed input
# https://raku.online/modules/leb128/#malformed-input
#
# Install what it needs, then run it:
#     rakupp install LEB128
#     rakupp 03-malformed.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use LEB128;

for 'empty', Buf.new,
    'a continuation with nothing after it', Buf.new(0x80),
    'all continuations', Buf.new(0xFF, 0xFF, 0xFF) -> $label, $b {
    my $r = try decode-leb128-unsigned($b);
    say sprintf('%-38s -> %s', $label, $! ?? $!.^name !! $r.Str);
}
say '';
say 'trailing bytes after a complete value are IGNORED:';
say '  decode(01 DE AD) = ', decode-leb128-unsigned(Buf.new(0x01, 0xDE, 0xAD));
say 'and a non-canonical padded zero is accepted:';
say '  decode(80 80 80 00) = ', decode-leb128-unsigned(Buf.new(0x80, 0x80, 0x80, 0x00));

# Output:
#     empty                                  -> X::LEB128::Incomplete
#     a continuation with nothing after it   -> X::LEB128::Incomplete
#     all continuations                      -> X::LEB128::Incomplete
#     
#     trailing bytes after a complete value are IGNORED:
#       decode(01 DE AD) = 1
#     and a non-canonical padded zero is accepted:
#       decode(80 80 80 00) = 0
