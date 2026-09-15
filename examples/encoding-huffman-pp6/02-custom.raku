#!/usr/bin/env rakupp
# Encoding::Huffman::PP6 — Encoding
# https://raku.online/modules/encoding-huffman-pp6/#encoding
#
# Install what it needs, then run it:
#     rakupp install Encoding::Huffman::PP6
#     rakupp 02-custom.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Encoding::Huffman::PP6;

my %codes = a => '0', b => '10', c => '110', _eos => '1110';
my $b = huffman-encode('abcabc', %codes);
say 'with a three-symbol table:';
say '  encoded : ', $b.list.map({ .fmt('%08b') }).join(' ');
say '  decoded : ', huffman-decode($b, %codes).raku;
say '';
say 'the table maps a single-character string to a string of binary';
say 'digits, and needs an _eos entry.';

# Output:
#     with a three-symbol table:
#       encoded : 01011001 01101110 00000000
#       decoded : "abcabc"
#     
#     the table maps a single-character string to a string of binary
#     digits, and needs an _eos entry.
