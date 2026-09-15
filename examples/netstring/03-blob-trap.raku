#!/usr/bin/env rakupp
# Netstring — The one thing to know
# https://raku.online/modules/netstring/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Netstring
#     rakupp 03-blob-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Netstring;

my $binary = Blob.new(0x00, 0x01, 0xFF, 0xFE, 0x80);

say 'to-netstring-buf handles it : ',
    to-netstring-buf($binary).list.map({ .fmt('%02X') }).join(' ');
say '';
my $r = try to-netstring($binary);
say 'to-netstring on the same blob : ', $! ?? 'threw' !! $r.raku;
say '';
say 'the Str-returning candidate UTF-8 DECODES the payload to build';
say 'its return value, so any blob that is not valid UTF-8 fails.';
say 'always use to-netstring-buf for bytes.';

# Output:
#     to-netstring-buf handles it : 35 3A 00 01 FF FE 80 2C
#     
#     to-netstring on the same blob : threw
#     
#     the Str-returning candidate UTF-8 DECODES the payload to build
#     its return value, so any blob that is not valid UTF-8 fails.
#     always use to-netstring-buf for bytes.
