#!/usr/bin/env rakupp
# Constants::Netinet::In — Reading the values
# https://raku.online/modules/constants-netinet-in/#reading-the-values
#
# Install what it needs, then run it:
#     rakupp install Constants::Netinet::In
#     rakupp 02-values.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Constants::Netinet::In :IP, :IPPROTO;

my $ip = IP.(Any);
my $proto = IPPROTO.(Any);

say 'IP:';
for <ADD_MEMBERSHIP DROP_MEMBERSHIP HDRINCL MULTICAST_TTL> -> $k {
    say sprintf('  %-18s %s', $k, $ip.enums{$k} // '(absent)');
}
say '';
say 'IPPROTO:';
for <IP ICMP TCP UDP RAW> -> $k {
    say sprintf('  %-18s %s', $k, $proto.enums{$k} // '(absent)');
}
say '';
say 'the first ten IP names, sorted:';
say '  ', $ip.enums.keys.sort.head(10).join(' ');

# Output:
#     IP:
#       ADD_MEMBERSHIP     12
#       DROP_MEMBERSHIP    13
#       HDRINCL            2
#       MULTICAST_TTL      10
#     
#     IPPROTO:
#       IP                 0
#       ICMP               1
#       TCP                6
#       UDP                17
#       RAW                255
#     
#     the first ten IP names, sorted:
#       ADD_MEMBERSHIP ADD_SOURCE_MEMBERSHIP BLOCK_SOURCE BOUND_IF DROP_MEMBERSHIP DROP_SOURCE_MEMBERSHIP FAITH HDRINCL IPSEC_POLICY MSFILTER
