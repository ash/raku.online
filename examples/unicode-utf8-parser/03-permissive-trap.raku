#!/usr/bin/env rakupp
# Unicode::UTF8-Parser — The one thing to know
# https://raku.online/modules/unicode-utf8-parser/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Unicode::UTF8-Parser
#     rakupp 03-permissive-trap.raku
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

say 'C0 80    — an overlong U+0000 : ', decode([0xC0, 0x80]).map({ .ords }).raku;
say 'E0 80 AF — an overlong "/"    : ', decode([0xE0, 0x80, 0xAF]).map({ .ords }).raku;
say 'ED A0 80 — a surrogate        : ', decode([0xED, 0xA0, 0x80]).map({ .ords }).raku;
say '';
say 'for comparison, Raku\'s own decoder on the same bytes:';
for [0xC0, 0x80], [0xE0, 0x80, 0xAF], [0xED, 0xA0, 0x80] -> @b {
    my $r = try Buf.new(@b).decode('utf8');
    say sprintf('  %-12s -> %s', @b.map({ .fmt('%02X') }).join(' '),
        $! ?? 'rejected' !! 'accepted');
}

# Output:
#     C0 80    — an overlong U+0000 : ((0,).Seq,).Seq
#     E0 80 AF — an overlong "/"    : ((47,).Seq,).Seq
#     ED A0 80 — a surrogate        : ((55296,).Seq,).Seq
#     
#     for comparison, Raku's own decoder on the same bytes:
#       C0 80        -> rejected
#       E0 80 AF     -> rejected
#       ED A0 80     -> rejected
