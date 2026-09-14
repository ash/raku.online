#!/usr/bin/env rakupp
# JSON::Class — In and out
# https://raku.online/modules/json-class/#in-and-out
#
# Install what it needs, then run it:
#     rakupp install JSON::Class
#     rakupp 01-round-trip.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Class;

class Address does JSON::Class { has Str $.city; has Str $.country }
class Person does JSON::Class {
    has Str     $.name;
    has Int     $.born;
    has Address $.address;
    has Str     @.tags;
    has Bool    $.active = True;
    has Str     $!secret = 'not yours';
}

my $ada = Person.new(name => 'Ada', born => 1815, tags => <maths engines>,
                     address => Address.new(city => 'London', country => 'UK'));
say $ada.to-json(:!pretty, :sorted-keys);

my $grace = Person.from-json('{"name":"Grace","born":1906,"tags":["compilers"],'
                           ~ '"address":{"city":"New York","country":"US"}}');
say $grace.address.city, ', ', $grace.address.^name, ', born ', $grace.born + 0;
say $grace.active;

# Output:
#     {"active":true,"address":{"city":"London","country":"UK"},"born":1815,"name":"Ada","tags":["maths","engines"]}
#     New York, Address, born 1906
#     True
