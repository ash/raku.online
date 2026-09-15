#!/usr/bin/env rakupp
# LR1 — Semantic values do not flow
# https://raku.online/modules/lr1/#semantic-values-do-not-flow
#
# Install what it needs, then run it:
#     rakupp install LR1
#     rakupp 04-values.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use LR1;

my @rules = ('Z -> E', 'E -> E plus T', 'E -> T', 'T -> n');
my $y = LR1Yacc.set-grammar(@rules);
$y.analysis;
my $table = $y.get-actions-data;

my @stack;
my $c = LR1Compiling.new;
$c.syntax-analysis($table, <n plus n>.map({ lr1token($_) }).List, -> $r {
    given $r.gn {
        when 'T -> n'          { @stack.push(7) }        # a real parser reads the token
        when 'E -> E plus T'   { @stack.push(@stack.pop + @stack.pop) }
        default                { }
    }
});
say 'a hand-kept stack gives : ', @stack.raku;
say '';
say 'after a reduction the runner pushes a bare lr1token($g[0]), so';
say '$r.syms for a non-terminal child is a NAME with no value:';
say '  the callback sees the production text and the symbol names, and';
say '  nothing else. Keep your own stack, as above.';
say '';
say 'lr1token mixes a role into $obj.Str:';
my $t = lr1token('42');
say '  isa Str        : ', ($t ~~ Str);
say '  does LR1Token  : ', ($t ~~ LR1Token);
say '  .cata          : ', $t.cata.raku;
say '  .lineno        : ', $t.lineno, '   <- -1 with no Match';

# Output:
#     a hand-kept stack gives : [14]
#     
#     after a reduction the runner pushes a bare lr1token($g[0]), so
#     $r.syms for a non-terminal child is a NAME with no value:
#       the callback sees the production text and the symbol names, and
#       nothing else. Keep your own stack, as above.
#     
#     lr1token mixes a role into $obj.Str:
#       isa Str        : True
#       does LR1Token  : True
#       .cata          : "42"
#       .lineno        : -1   <- -1 with no Match
