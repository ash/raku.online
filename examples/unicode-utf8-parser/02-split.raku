#!/usr/bin/env rakupp
# Unicode::UTF8-Parser — Sequences split across emissions
# https://raku.online/modules/unicode-utf8-parser/#sequences-split-across-emissions
#
# Install what it needs, then run it:
#     rakupp install Unicode::UTF8-Parser
#     rakupp 02-split.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Unicode::UTF8-Parser;

sub decode(@chunks) {
    my $supplier = Supplier.new;
    my @out;
    parse-utf8-bytes($supplier.Supply).tap(-> $c { @out.push($c) });
    for @chunks -> @chunk { $supplier.emit($_) for @chunk }
    $supplier.done;
    @out
}

say 'U+4E2D all at once   : ', decode([[0xE4, 0xB8, 0xAD],]).raku;
say 'the same, one byte at a time : ', decode([[0xE4], [0xB8], [0xAD]]).raku;
say 'and mixed with ASCII : ', decode([[0x48], [0xE4, 0xB8], [0xAD], [0x69]]).raku;

# Output:
#     U+4E2D all at once   : ["中"]
#     the same, one byte at a time : ["中"]
#     and mixed with ASCII : ["H", "中", "i"]
