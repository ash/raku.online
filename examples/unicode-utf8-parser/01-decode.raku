#!/usr/bin/env rakupp
# Unicode::UTF8-Parser — Decoding a stream
# https://raku.online/modules/unicode-utf8-parser/#decoding-a-stream
#
# Install what it needs, then run it:
#     rakupp install Unicode::UTF8-Parser
#     rakupp 01-decode.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Unicode::UTF8-Parser;

sub decode(@bytes) {
    my $supplier = Supplier.new;
    my @out;
    parse-utf8-bytes($supplier.Supply).tap(-> $c { @out.push($c) });
    $supplier.emit($_) for @bytes;
    $supplier.done;
    @out
}

say 'ASCII "Hi"          : ', decode([0x48, 0x69]).raku;
say 'two bytes, U+00E9   : ', decode([0xC3, 0xA9]).raku;
say 'three bytes, U+4E2D : ', decode([0xE4, 0xB8, 0xAD]).raku;
say 'four bytes, U+1F600 : ', decode([0xF0, 0x9F, 0x98, 0x80]).raku;

# Output:
#     ASCII "Hi"          : ["H", "i"]
#     two bytes, U+00E9   : ["é"]
#     three bytes, U+4E2D : ["中"]
#     four bytes, U+1F600 : ["😀"]
