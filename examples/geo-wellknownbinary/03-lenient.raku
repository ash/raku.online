#!/usr/bin/env rakupp
# Geo::WellKnownBinary — The one thing to know
# https://raku.online/modules/geo-wellknownbinary/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Geo::WellKnownBinary
#     rakupp 03-lenient.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Geo::WellKnownBinary;

# the spec allows only 0 (big) and 1 (little); this says 0x42
my $odd = Buf.new(0x42, 0x01,0x00,0x00,0x00,
                  0,0,0,0,0,0,0xF0,0x3F, 0,0,0,0,0,0,0,0x40);
my $r = from-wkb($odd);
say 'byte-order flag 0x42 : ', $r.^name, ' x=', $r.x, ' y=', $r.y;

# four bytes of junk after a complete point
my $extra = Buf.new(0x01, 0x01,0x00,0x00,0x00,
                    0,0,0,0,0,0,0xF0,0x3F, 0,0,0,0,0,0,0,0x40,
                    0xDE,0xAD,0xBE,0xEF);
my $s = from-wkb($extra);
say 'four junk bytes after : ', $s.^name, ' x=', $s.x, ' y=', $s.y;

# Output:
#     byte-order flag 0x42 : Point x=1 y=2
#     four junk bytes after : Point x=1 y=2
