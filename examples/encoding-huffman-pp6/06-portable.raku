#!/usr/bin/env rakupp
# Encoding::Huffman::PP6 — Where the two engines differ
# https://raku.online/modules/encoding-huffman-pp6/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Encoding::Huffman::PP6
#     rakupp 06-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Encoding::Huffman::PP6;

say 'the portable rule: only round-trip characters the decoder cannot';
say 'numify. Check before you rely on it:';
sub safe(Str $s) {
    huffman-decode(huffman-encode($s)) eq $s
}
for 'abcdef', 'a1b', 'no space', 'nospace' -> $s {
    say sprintf('  %-14s round-trips ? %s', $s.raku, safe($s));
}
say '';
say 'and always pass a real Buf[uint8] to the decoder:';
my Buf[uint8] $b = huffman-encode('abc');
say '  typed buffer decodes : ', huffman-decode($b).raku;
say '';
say 'one performance note: the reverse lookup table is rebuilt from';
say '%codes on EVERY huffman-decode call.';

# Output:
#     the portable rule: only round-trip characters the decoder cannot
#     numify. Check before you rely on it:
#       "abcdef"       round-trips ? True
#       "a1b"          round-trips ? False
#       "no space"     round-trips ? False
#       "nospace"      round-trips ? True
#     
#     and always pass a real Buf[uint8] to the decoder:
#       typed buffer decodes : "abc"
#     
#     one performance note: the reverse lookup table is rebuilt from
#     %codes on EVERY huffman-decode call.
