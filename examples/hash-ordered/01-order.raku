#!/usr/bin/env rakupp
# Hash::Ordered — Insertion order, through the ordinary syntax
# https://raku.online/modules/hash-ordered/#insertion-order-through-the-ordinary-syntax
#
# Install what it needs, then run it:
#     rakupp install Hash::Ordered
#     rakupp 01-order.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Hash::Ordered;

my %config is Hash::Ordered;
%config<name>    = 'demo';
%config<port>    = 8080;
%config<verbose> = True;
%config<retries> = 3;

say %config.keys.join(',');
say %config.pairs.map({ .key ~ '=' ~ .value }).join(' ');
say %config<port>;
say %config.elems;

%config<name> = 'renamed';
say %config.keys.join(',');

%config<port>:delete;
say %config.keys.join(',');
%config<port> = 9090;
say %config.keys.join(',');

# Output:
#     name,port,verbose,retries
#     name=demo port=8080 verbose=True retries=3
#     8080
#     4
#     name,port,verbose,retries
#     name,verbose,retries
#     name,verbose,retries,port
