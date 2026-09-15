#!/usr/bin/env rakupp
# Constants::Netinet::In — Duplicate values
# https://raku.online/modules/constants-netinet-in/#duplicate-values
#
# Install what it needs, then run it:
#     rakupp install Constants::Netinet::In
#     rakupp 04-duplicates.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Constants::Netinet::In :IP, :IPPROTO;

my $ip = IP.(Any);
my %by-value;
for $ip.enums.kv -> $k, $v { %by-value{$v}.push($k) }
say 'IP values held by more than one name:';
for %by-value.keys.sort({ .Int }) -> $v {
    next unless %by-value{$v}.elems > 1;
    say sprintf('  %-4s %s', $v, %by-value{$v}.sort.join(' / '));
}
say '';
say 'reverse lookup is therefore lossy and arbitrary — $ip(26) returns';
say 'one of the two names and the other is unreachable. Go name to number,';
say 'never the other way.';

# Output:
#     IP values held by more than one name:
#       7    RECVDSTADDR / SENDSRCADDR
#       26   PKTINFO / RECVPKTINFO
#       27   RECVORIGDSTADDR / RECVTOS
#     
#     reverse lookup is therefore lossy and arbitrary — $ip(26) returns
#     one of the two names and the other is unreachable. Go name to number,
#     never the other way.
