#!/usr/bin/env rakupp
# JSON::Class — In and out
# https://raku.online/modules/json-class/#in-and-out
#
# Install what it needs, then run it:
#     rakupp install JSON::Class
#     rakupp 02-typed-array.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Class;

class Person does JSON::Class { has Str $.name; has Int $.born }
constant People = (Array[Person] but JSON::Class);

my $many = People.from-json('[{"name":"Ada","born":1815},{"name":"Grace","born":1906}]');
say $many.elems, ' ', $many[0].^name, ' ', $many.map(*.name).join(' & ');
say $many.to-json(:!pretty, :sorted-keys);

# Output:
#     2 Person Ada & Grace
#     [{"born":1815,"name":"Ada"},{"born":1906,"name":"Grace"}]
