#!/usr/bin/env rakupp
# Netstring — Where the two engines differ
# https://raku.online/modules/netstring/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Netstring
#     rakupp 04-reader.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Netstring;

class FakeSocket does IO::Socket {
    has Buf $.data;
    has Int $.pos is rw = 0;
    method read($n) {
        my $take = min $n.Int, $!data.elems - $!pos;
        my $out = Buf.new($!data[$!pos ..^ $!pos + $take]);
        $!pos += $take;
        $out
    }
}
sub sock(Str $s) { FakeSocket.new(data => Buf.new($s.encode('latin-1').list)) }

# malformed input is refused on both engines, so this much is portable
for 'bad terminator', '5:hello;',
    'non-digit length', 'x:hello,',
    'no colon', '5hello,',
    'empty stream', '' -> $label, $wire {
    my $r = try read-netstring(sock($wire));
    say sprintf('%-18s %-12s -> %s', $label, $wire.raku, $! ?? 'refused' !! 'accepted');
}

# Output:
#     bad terminator     "5:hello;"   -> refused
#     non-digit length   "x:hello,"   -> refused
#     no colon           "5hello,"    -> refused
#     empty stream       ""           -> refused
