#!/usr/bin/env rakupp
# P5getservbyname — Scalar context
# https://raku.online/modules/p5getservbyname/#scalar-context
#
# Install what it needs, then run it:
#     rakupp install P5getservbyname
#     rakupp 02-scalar.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getservbyname;

say 'by name, gives the port : ', getservbyname(Scalar, 'https', 'tcp');
say 'by port, gives the name : ', getservbyport(Scalar, 443, 'tcp');
say '';
say 'the list forms of the same two calls:';
say '  getservbyname("https","tcp")[2] = ', getservbyname('https', 'tcp')[2];
say '  getservbyport(443,"tcp")[0]     = ', getservbyport(443, 'tcp')[0];

# Output:
#     by name, gives the port : 443
#     by port, gives the name : https
#     
#     the list forms of the same two calls:
#       getservbyname("https","tcp")[2] = 443
#       getservbyport(443,"tcp")[0]     = https
