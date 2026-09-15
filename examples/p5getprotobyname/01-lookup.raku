#!/usr/bin/env rakupp
# P5getprotobyname — Looking a protocol up
# https://raku.online/modules/p5getprotobyname/#looking-a-protocol-up
#
# Install what it needs, then run it:
#     rakupp install P5getprotobyname
#     rakupp 01-lookup.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getprotobyname;

for <ip icmp tcp udp> -> $p {
    my @r = getprotobyname($p);
    say sprintf('%-6s fields=%d  name=%-6s number=%d', $p, @r.elems, @r[0], @r[2]);
}
say '';
say 'scalar by name gives the number : ', getprotobyname(Scalar, 'udp');
say 'scalar by number gives the name : ', getprotobynumber(Scalar, 17);

# Output:
#     ip     fields=3  name=ip     number=0
#     icmp   fields=3  name=icmp   number=1
#     tcp    fields=3  name=tcp    number=6
#     udp    fields=3  name=udp    number=17
#     
#     scalar by name gives the number : 17
#     scalar by number gives the name : udp
