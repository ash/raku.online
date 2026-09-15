#!/usr/bin/env rakupp
# Data::DPath6 — The whole API
# https://raku.online/modules/data-dpath6/#the-whole-api
#
# Install what it needs, then run it:
#     rakupp install Data::DPath6
#     rakupp 01-whole-api.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::DPath6;

say 'the type            : ', Data::DPath6.^name;
say 'its methods         : ',
    Data::DPath6.^methods(:local).map(*.name).grep(* ne 'POPULATE').sort.join(', ');
say 'its attributes      : ', Data::DPath6.^attributes(:local).elems;
say '';
say 'Data::DPath6.hello  : ', Data::DPath6.hello;
say 'on an instance      : ', Data::DPath6.new.hello;
say '';
say 'nothing is exported : the class name is what you get.';

# Output:
#     the type            : Data::DPath6
#     its methods         : hello
#     its attributes      : 0
#     
#     Data::DPath6.hello  : 42
#     on an instance      : 42
#     
#     nothing is exported : the class name is what you get.
