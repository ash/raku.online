#!/usr/bin/env rakupp
# Digest::FNV — The one thing to know
# https://raku.online/modules/digest-fnv/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Digest::FNV
#     rakupp 03-mask-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Digest::FNV :DEFAULT, :DEPRECATED;

my ($a, $b) = "\x[00E9]", "\x[01E9]";     # é and ǩ
say 'codepoints    : ', $a.ords, ' and ', $b.ords;
say '489 +& 0xff   : ', 489 +& 0xff;
say 'fnv1a of each : ', fnv1a($a), ' and ', fnv1a($b);
say 'they collide  : ', fnv1a($a) == fnv1a($b);
say '';
my $h = 0xcbf29ce484222325;
for $a.encode('utf8').list { $h = (($h +^ $_) * 0x100000001B3) +& 0xffffffffffffffff }
say 'byte-oriented FNV-1a of the UTF-8 bytes : ', $h;
say 'this module agrees with it              : ', $h == fnv1a($a);

# Output:
#     codepoints    : (233) and (489)
#     489 +& 0xff   : 233
#     fnv1a of each : 12638336734137078692 and 12638336734137078692
#     they collide  : True
#     
#     byte-oriented FNV-1a of the UTF-8 bytes : 775207407765167617
#     this module agrees with it              : False
