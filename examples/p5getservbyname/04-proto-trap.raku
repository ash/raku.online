#!/usr/bin/env rakupp
# P5getservbyname — The one thing to know
# https://raku.online/modules/p5getservbyname/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install P5getservbyname
#     rakupp 04-proto-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getservbyname;

for 'tcp', 'TCP', '' -> $proto {
    say sprintf('getservbyname("ssh", %-7s) -> %d field(s)',
        $proto.raku, getservbyname('ssh', $proto).elems);
}
say '';
say 'in C you pass NULL for proto to match any protocol.';
say 'here the parameter is Str(), so the only thing you can supply';
say 'is a string — and the empty string matches nothing.';

# Output:
#     getservbyname("ssh", "tcp"  ) -> 4 field(s)
#     getservbyname("ssh", "TCP"  ) -> 0 field(s)
#     getservbyname("ssh", ""     ) -> 0 field(s)
#     
#     in C you pass NULL for proto to match any protocol.
#     here the parameter is Str(), so the only thing you can supply
#     is a string — and the empty string matches nothing.
