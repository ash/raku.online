#!/usr/bin/env rakupp
# P5getservbyname — Where the two engines differ
# https://raku.online/modules/p5getservbyname/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install P5getservbyname
#     rakupp 05-miss.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getservbyname;

my @miss = getservbyname('nosuchservice-xyzzy', 'tcp');
say 'list form elems   : ', @miss.elems;
say 'scalar form       : ', getservbyname(Scalar, 'nosuchservice-xyzzy', 'tcp').defined;
say '';
my ($name, $aliases, $port, $proto) = getservbyname('nosuchservice-xyzzy', 'tcp');
say 'port after a failed lookup : ', $port.defined ?? $port !! 'undefined';
say 'the right test is on the list : ',
    ?getservbyname('nosuchservice-xyzzy', 'tcp').elems;

# Output:
#     list form elems   : 0
#     scalar form       : False
#     
#     port after a failed lookup : undefined
#     the right test is on the list : False
