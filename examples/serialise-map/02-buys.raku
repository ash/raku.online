#!/usr/bin/env rakupp
# Serialise::Map — What the role buys you
# https://raku.online/modules/serialise-map/#what-the-role-buys-you
#
# Install what it needs, then run it:
#     rakupp install Serialise::Map
#     rakupp 02-buys.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Serialise::Map;

class Point does Serialise::Map {
    has $.x; has $.y;
    method to-map(--> Map) { Map.new(( x => $!x, y => $!y )) }
    method from-map(Map $map) { self.new(|$map) }
}

class Plain { has $.z }

sub save($thing) {
    $thing ~~ Serialise::Map
        ?? 'saved: ' ~ $thing.to-map.sort(*.key).map({ "{.key}={.value}" }).join(' ')
        !! 'cannot serialise a ' ~ $thing.^name
}

say save(Point.new(:x(1), :y(2)));
say save(Plain.new(:z(9)));

# Output:
#     saved: x=1 y=2
#     cannot serialise a Plain
