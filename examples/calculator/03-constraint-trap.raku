#!/usr/bin/env rakupp
# Calculator — The one thing to know
# https://raku.online/modules/calculator/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Calculator
#     rakupp 03-constraint-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Calculator;

sub attempt($label, &c) {
    my $r = try c();
    say sprintf('%-22s %s', $label, $! ?? 'refused' !! 'ok -> ' ~ $r);
}

attempt 'new(x=>10, y=>3).add',  { Calculator.new(x => 10, y => 3).add };
attempt 'new(x=>3,  y=>10).add', { Calculator.new(x => 3,  y => 10).add };
attempt 'new(x=>5,  y=>5).add',  { Calculator.new(x => 5,  y => 5).add };
attempt 'new(x=>5,  y=>0).add',  { Calculator.new(x => 5,  y => 0).add };
attempt 'new(x=>5,  y=>-2).add', { Calculator.new(x => 5,  y => -2).add };

# Output:
#     new(x=>10, y=>3).add   ok -> 13
#     new(x=>3,  y=>10).add  refused
#     new(x=>5,  y=>5).add   refused
#     new(x=>5,  y=>0).add   refused
#     new(x=>5,  y=>-2).add  refused
