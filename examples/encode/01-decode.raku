#!/usr/bin/env rakupp
# Encode — Decoding a code page
# https://raku.online/modules/encode/#decoding-a-code-page
#
# Install what it needs, then run it:
#     rakupp install Encode
#     rakupp 01-decode.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Encode;

my $cyrillic = Buf[uint8].new(0xCF, 0xF0, 0xE8, 0xE2, 0xE5, 0xF2);
say Encode::decode('cp1251', $cyrillic);

my $polish = Buf[uint8].new(0xA3, 0xF3, 0x64, 0xBC);
say Encode::decode('latin2', $polish);

my $one = Buf[uint8].new(0xA3);
say Encode::decode('latin1', $one), ' ', Encode::decode('latin1', $one).ords;
say Encode::decode('latin2', $one), ' ', Encode::decode('latin2', $one).ords;

say Encode::decode('utf8', Buf[uint8].new(0x63, 0x61, 0x66, 0xC3, 0xA9));
say (try Encode::decode('utf-16', Buf[uint8].new(0x61))) // $!.message;

# Output:
#     Привет
#     Łódź
#     £ (163)
#     Ł (321)
#     café
#     Unknown encoding utf-16.
