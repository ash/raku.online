#!/usr/bin/env rakupp
# Geo::WellKnownBinary — Decoding a point
# https://raku.online/modules/geo-wellknownbinary/#decoding-a-point
#
# Install what it needs, then run it:
#     rakupp install Geo::WellKnownBinary
#     rakupp 01-point.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Geo::WellKnownBinary;

sub hex(Buf $b) { $b.list.map({ .fmt('%02X') }).join(' ') }

# POINT(1 2), little-endian: 01 | 01000000 | 1.0 | 2.0
my $le = Buf.new(0x01,
                 0x01,0x00,0x00,0x00,
                 0x00,0x00,0x00,0x00,0x00,0x00,0xF0,0x3F,
                 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x40);

# the same point, big-endian
my $be = Buf.new(0x00,
                 0x00,0x00,0x00,0x01,
                 0x3F,0xF0,0x00,0x00,0x00,0x00,0x00,0x00,
                 0x40,0x00,0x00,0x00,0x00,0x00,0x00,0x00);

my $p = from-wkb($le);
my $q = from-wkb($be);
say 'little-endian bytes : ', hex($le);
say '  type : ', $p.^name, '   x=', $p.x, ' y=', $p.y;
say 'big-endian bytes    : ', hex($be);
say '  type : ', $q.^name, '   x=', $q.x, ' y=', $q.y;
say 'the two agree       : ', ($p.x == $q.x && $p.y == $q.y);

# Output:
#     little-endian bytes : 01 01 00 00 00 00 00 00 00 00 00 F0 3F 00 00 00 00 00 00 00 40
#       type : Point   x=1 y=2
#     big-endian bytes    : 00 00 00 00 01 3F F0 00 00 00 00 00 00 40 00 00 00 00 00 00 00
#       type : Point   x=1 y=2
#     the two agree       : True
