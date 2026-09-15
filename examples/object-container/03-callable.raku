#!/usr/bin/env rakupp
# Object::Container — You can never store a Callable
# https://raku.online/modules/object-container/#you-can-never-store-a-callable
#
# Install what it needs, then run it:
#     rakupp install Object::Container
#     rakupp 03-callable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Object::Container;

my $c = Object::Container.new;
my &handler = sub { 'I AM THE VALUE' };
$c.register('cb', &handler);
say 'get("cb")       : ', $c.get('cb').raku;
say '  is it Code ?  : ', ($c.get('cb') ~~ Code);
say '';
say 'the Callable:D candidate is NARROWER than Any:D, so register always';
say 'takes the lazy branch and get hands you the RETURN VALUE. A registry';
say 'of handlers or factories is impossible without wrapping each one:';
class Holder { has &.fn }
$c.register('wrapped', Holder.new(fn => &handler));
say '  wrapped       : ', $c.get('wrapped').fn.().raku;
say '';
say 'and a type object or Nil is refused outright:';
my $r = try $c.register('t', Int);
say '  register("t", Int) -> ', $! ?? 'X::Multi::NoMatch' !! 'accepted';

# Output:
#     get("cb")       : "I AM THE VALUE"
#       is it Code ?  : False
#     
#     the Callable:D candidate is NARROWER than Any:D, so register always
#     takes the lazy branch and get hands you the RETURN VALUE. A registry
#     of handlers or factories is impossible without wrapping each one:
#       wrapped       : "I AM THE VALUE"
#     
#     and a type object or Nil is refused outright:
#       register("t", Int) -> X::Multi::NoMatch
