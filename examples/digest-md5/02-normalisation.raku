#!/usr/bin/env rakupp
# Digest::MD5 — The one thing to know
# https://raku.online/modules/digest-md5/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Digest::MD5
#     rakupp 02-normalisation.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Digest::MD5;

sub hex(Blob $b) { $b.list.map({ .fmt('%02x') }).join }

my $composed   = "caf\x[00E9]";       # c a f  é
my $decomposed = "cafe\x[0301]";      # c a f  e  combining acute

say $composed.chars, ' ', $decomposed.chars, ' ', $composed eq $decomposed;
say hex(md5($composed));
say hex(md5($decomposed));

my $on-disk = Buf[uint8].new(0x63, 0x61, 0x66, 0x65, 0xCC, 0x81);
say hex(md5($on-disk));

# Output:
#     4 4 True
#     07117fe4a1ebd544965dc19573183da2
#     07117fe4a1ebd544965dc19573183da2
#     10a85865ce7a7d2f0dc3faf37c617a8d
