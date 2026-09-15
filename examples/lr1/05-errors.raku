#!/usr/bin/env rakupp
# LR1 — Where the two engines differ
# https://raku.online/modules/lr1/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install LR1
#     rakupp 05-errors.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use LR1;

my $y = LR1Yacc.set-grammar(['Z -> E', 'E -> n']);
$y.analysis;
my $table = $y.get-actions-data;
my $c = LR1Compiling.new;

say 'a bad parse is a DIE, not a return value:';
my $r = try $c.syntax-analysis($table, <plus>.map({ lr1token($_) }).List, -> $ { });
say '  ', $! ?? 'threw — wrap it' !! 'returned ' ~ $r.raku;
say '';
say 'an empty token stream returns Nil rather than False:';
say '  ', $c.syntax-analysis($table, (), -> $ { }).raku;
say '';
say 'one structural limit worth knowing: !firsts only inspects';
say '$g.right[0], so nullable productions are not handled. And the';
say '"TOP not found" diagnostic PUTs the symbol table to stdout while the';
say 'die goes to stderr, so the two interleave unpredictably.';

# Output:
#     a bad parse is a DIE, not a return value:
#       threw — wrap it
#     
#     an empty token stream returns Nil rather than False:
#       Nil
#     
#     one structural limit worth knowing: !firsts only inspects
#     $g.right[0], so nullable productions are not handled. And the
#     "TOP not found" diagnostic PUTs the symbol table to stdout while the
#     die goes to stderr, so the two interleave unpredictably.
