#!/usr/bin/env rakupp
# Physics::Error — Bad input
# https://raku.online/modules/physics-error/#bad-input
#
# Install what it needs, then run it:
#     rakupp install Physics::Error
#     rakupp 03-input.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Physics::Error;

for 'Error.new()',                 { Error.new() },
    'Error.new(:value(10))',       { Error.new(:value(10)) },
    'Error.new(:error(Nil))',      { Error.new(:error(Nil)) },
    'Error.new(:error("bananas"))',{ Error.new(:error('bananas')) },
    'Error.new(:error(-3))',       { Error.new(:error(-3)) } -> $label, &c {
    my $e = c();
    say sprintf('%-30s -> %s', $label,
        $e.defined ?? 'an Error with absolute=' ~ $e.absolute !! 'Nil');
}

# Output:
#     Error.new()                    -> Nil
#     Error.new(:value(10))          -> Nil
#     Error.new(:error(Nil))         -> Nil
#     Error.new(:error("bananas"))   -> Nil
#     Error.new(:error(-3))          -> an Error with absolute=3
