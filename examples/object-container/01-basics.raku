#!/usr/bin/env rakupp
# Object::Container — Registering and fetching
# https://raku.online/modules/object-container/#registering-and-fetching
#
# Install what it needs, then run it:
#     rakupp install Object::Container
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Object::Container;

class Widget { has $.id }

my $c = Object::Container.new;
$c.register('w', Widget.new(id => 7));
say 'get("w")      : ', $c.get('w').raku;
say 'get(missing)  : ', $c.get('nope').raku;
say 'remove("w")   : ', $c.remove('w');
say 'remove again  : ', $c.remove('w');
say 'get after rm  : ', $c.get('w').raku;
say '';
my $built = 0;
$c.register('lazy', sub { $built++; Widget.new(id => 99) });
say 'built before get : ', $built;
say 'first get        : ', $c.get('lazy').raku, '  built=', $built;
say 'second get       : ', $c.get('lazy').raku, '  built=', $built;
say 'same object      : ', $c.get('lazy') === $c.get('lazy');
$c.clear;
say 'after clear      : ', $c.get('lazy').raku;

# Output:
#     get("w")      : Widget.new(id => 7)
#     get(missing)  : Nil
#     remove("w")   : True
#     remove again  : False
#     get after rm  : Nil
#     
#     built before get : 0
#     first get        : Widget.new(id => 99)  built=1
#     second get       : Widget.new(id => 99)  built=1
#     same object      : True
#     after clear      : Nil
