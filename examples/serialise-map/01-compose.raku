#!/usr/bin/env rakupp
# Serialise::Map — Composing it
# https://raku.online/modules/serialise-map/#composing-it
#
# Install what it needs, then run it:
#     rakupp install Serialise::Map
#     rakupp 01-compose.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Serialise::Map;

class Point does Serialise::Map {
    has $.x;
    has $.y;
    method to-map(--> Map) { Map.new(( x => $!x, y => $!y )) }
    method from-map(Map $map) { self.new(|$map) }
}

my $p = Point.new(:x(3), :y(4));
my $m = $p.to-map;

say 'to-map returns a : ', $m.^name;
say '  contents       : ', $m.sort(*.key).map({ "{.key}={.value}" }).join(' ');
say '';
my $q = $p.from-map($m);
say 'round trip : x=', $q.x, ' y=', $q.y;
say 'same class : ', $q.^name eq $p.^name;
say '';
say 'the object does the role : ', $p ~~ Serialise::Map;
say 'the role requires        : ', Serialise::Map.^methods.map(*.name).sort.join(' ');

# Output:
#     to-map returns a : Map
#       contents       : x=3 y=4
#     
#     round trip : x=3 y=4
#     same class : True
#     
#     the object does the role : True
#     the role requires        : from-map to-map
