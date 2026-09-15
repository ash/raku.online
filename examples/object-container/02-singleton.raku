#!/usr/bin/env rakupp
# Object::Container — Class methods are a different container
# https://raku.online/modules/object-container/#class-methods-are-a-different-container
#
# Install what it needs, then run it:
#     rakupp install Object::Container
#     rakupp 02-singleton.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Object::Container;

class Widget { has $.id }

Object::Container.register('shared', Widget.new(id => 1));
say 'class method sees "shared"   : ', Object::Container.get('shared').raku;
say '';
my $inst = Object::Container.new;
say 'a fresh instance sees it     : ', $inst.get('shared').raku;
$inst.register('mine', Widget.new(id => 2));
say 'class method sees "mine"     : ', Object::Container.get('mine').raku;
say '';
say 'called as class methods the whole thing collapses to one';
say 'process-wide singleton; instances are separate. Mixing the two';
say 'styles silently loses registrations — pick one.';

# Output:
#     class method sees "shared"   : Widget.new(id => 1)
#     
#     a fresh instance sees it     : Nil
#     class method sees "mine"     : Nil
#     
#     called as class methods the whole thing collapses to one
#     process-wide singleton; instances are separate. Mixing the two
#     styles silently loses registrations — pick one.
