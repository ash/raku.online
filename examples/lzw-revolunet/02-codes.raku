#!/usr/bin/env rakupp
# LZW::Revolunet — What the codes actually are
# https://raku.online/modules/lzw-revolunet/#what-the-codes-actually-are
#
# Install what it needs, then run it:
#     rakupp install LZW::Revolunet
#     rakupp 02-codes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use LZW::Revolunet;

my $lzw = LZW::Revolunet.new;
my $c = $lzw.compress(s => 'TOBEORNOTTOBEORTOBEORNOT');

say 'compressed codepoints : ', $c.ords.List.raku;
say '';
say 'the highest one       : ', $c.ords.max, '  (U+', $c.ords.max.base(16), ')';
say 'that character alone encodes to ',
    $c.ords.max.chr.encode('utf8').bytes, ' UTF-8 bytes';

# Output:
#     compressed codepoints : (84, 79, 66, 69, 79, 82, 78, 79, 84, 97000, 97002, 97004, 97009, 97003, 97005, 97007)
#     
#     the highest one       : 97009  (U+17AF1)
#     that character alone encodes to 4 UTF-8 bytes
