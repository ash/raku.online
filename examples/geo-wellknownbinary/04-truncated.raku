#!/usr/bin/env rakupp
# Geo::WellKnownBinary — Where the two engines differ
# https://raku.online/modules/geo-wellknownbinary/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Geo::WellKnownBinary
#     rakupp 04-truncated.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Geo::WellKnownBinary;

for 'empty', Buf.new,
    'flag only', Buf.new(0x01),
    'half a point', Buf.new(0x01, 0x01,0,0,0, 0,0,0,0) -> $label, $b {
    my $r = try from-wkb($b);
    say sprintf('%-14s -> %s', $label, $! ?? 'threw' !! $r.^name);
}
say '';
say 'an unrecognised type code is the one case both engines agree on:';
my $bad = Buf.new(0x01, 0x63,0x00,0x00,0x00, 0,0,0,0,0,0,0xF0,0x3F, 0,0,0,0,0,0,0,0x40);
my $r = try from-wkb($bad);
say '  ', $! ?? $!.message !! 'no error';

# Output:
#     empty          -> threw
#     flag only      -> threw
#     half a point   -> threw
#     
#     an unrecognised type code is the one case both engines agree on:
#       Can't handle geometry type 99 in from-wkb
