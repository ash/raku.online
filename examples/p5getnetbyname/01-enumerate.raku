#!/usr/bin/env rakupp
# P5getnetbyname — Reading the database
# https://raku.online/modules/p5getnetbyname/#reading-the-database
#
# Install what it needs, then run it:
#     rakupp install P5getnetbyname
#     rakupp 01-enumerate.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getnetbyname;

setnetent(0);
my @first = getnetent();
endnetent();

if @first {
    say 'record fields  : ', @first.elems;
    say 'name is a Str  : ', @first[0] ~~ Str;
    say 'aliases are a  : ', @first[1].^name;
    say 'addrtype is 2 (AF_INET) : ', @first[2] == 2;
    say 'net is an Int  : ', @first[3] ~~ Int;
}
else {
    say 'this machine has no network database entries';
}
say '';
say 'setnetent : ', setnetent(0);
say 'endnetent : ', endnetent();

# Output:
#     record fields  : 4
#     name is a Str  : True
#     aliases are a  : Array
#     addrtype is 2 (AF_INET) : True
#     net is an Int  : True
#     
#     setnetent : 1
#     endnetent : 1
