#!/usr/bin/env rakupp
# LR1 — The one thing to know
# https://raku.online/modules/lr1/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install LR1
#     rakupp 02-top.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use LR1;

sub build(@rules) {
    my $y = try { my $g = LR1Yacc.set-grammar(@rules); $g.analysis; $g };
    $! ?? 'DIED: ' ~ $!.message.lines[0] !! 'top = ' ~ $y.top
}

say 'the obvious grammar:';
say '  ', build(['S -> a S', 'S -> a']);
say '';
say 'with a wrapper production:';
say '  ', build(['Z -> S', 'S -> a S', 'S -> a']);
say '';
say 'two eligible symbols is also an error:';
say '  ', build(['Z -> E', 'Y -> F', 'E -> n', 'F -> m']).subst(/'(' .*? ')'/, '(…)');
say '';
say 'so every grammar needs exactly one wrapper rule whose left side';
say 'appears nowhere else.';

# Output:
#     the obvious grammar:
#     S => 1
#       DIED: TOP not found
#     
#     with a wrapper production:
#       top = Z
#     
#     two eligible symbols is also an error:
#       DIED: TOP (…) more then one
#     
#     so every grammar needs exactly one wrapper rule whose left side
#     appears nowhere else.
