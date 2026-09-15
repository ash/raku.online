#!/usr/bin/env rakupp
# Constants::Netinet::In — Importing
# https://raku.online/modules/constants-netinet-in/#importing
#
# Install what it needs, then run it:
#     rakupp install Constants::Netinet::In
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Constants::Netinet::In :IP, :IPPROTO;

say 'both symbols are TAG-ONLY — a plain `use` imports neither.';
say '';
say 'on this platform they arrive as: ', IP.^name;
say '  IP ~~ Block      : ', (IP ~~ Block);
say '  IPPROTO ~~ Block : ', (IPPROTO ~~ Block);
say '';
say 'so the documented IP::ADD_MEMBERSHIP spelling does not work here —';
say 'see below. Call the Block to get the enum:';
my $ip = IP.(Any);
my $proto = IPPROTO.(Any);
say '  IP enum values      : ', $ip.enums.elems;
say '  IPPROTO enum values : ', $proto.enums.elems;

# Output:
#     both symbols are TAG-ONLY — a plain `use` imports neither.
#     
#     on this platform they arrive as: Block
#       IP ~~ Block      : True
#       IPPROTO ~~ Block : True
#     
#     so the documented IP::ADD_MEMBERSHIP spelling does not work here —
#     see below. Call the Block to get the enum:
#       IP enum values      : 35
#       IPPROTO enum values : 107
