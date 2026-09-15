#!/usr/bin/env rakupp
# Serialise::Map — The one thing to know
# https://raku.online/modules/serialise-map/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Serialise::Map
#     rakupp 03-instance-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Serialise::Map;

class Point does Serialise::Map {
    has $.x; has $.y;
    method to-map(--> Map) { Map.new(( x => $!x, y => $!y )) }
    method from-map(Map $map) { self.new(|$map) }
}

my $m = Point.new(:x(1), :y(2)).to-map;

say 'on an instance    : ', Point.new(:x(0), :y(0)).from-map($m).x;
say 'on the type object: ', Point.from-map($m).x;
say '';
say 'the second works only because THIS body happens to be self.new(|$map).';
say 'a body that assigns to attributes would compose just as legally';
say 'and could not be called on the type object at all.';

# Output:
#     on an instance    : 1
#     on the type object: 1
#     
#     the second works only because THIS body happens to be self.new(|$map).
#     a body that assigns to attributes would compose just as legally
#     and could not be called on the type object at all.
