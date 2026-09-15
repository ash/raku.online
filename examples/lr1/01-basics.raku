#!/usr/bin/env rakupp
# LR1 — Generating and parsing
# https://raku.online/modules/lr1/#generating-and-parsing
#
# Install what it needs, then run it:
#     rakupp install LR1
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use LR1;

my @rules = (
    'S -> E',
    'E -> E plus T',
    'E -> T',
    'T -> T star F',
    'T -> F',
    'F -> n',
    'F -> lp E rp',
);

my $y = LR1Yacc.set-grammar(@rules);
$y.analysis;
say 'productions : ', $y.grammars.elems;
say 'top symbol  : ', $y.top;
say 'states      : ', $y.states.elems;
say '';
my $table = $y.get-actions-data;
say 'table keys  : ', $table.keys.sort.join(', ');
say '';
my @tokens = <n plus n star n>.map({ lr1token($_) });
my @reductions;
my $c = LR1Compiling.new;
my $ok = $c.syntax-analysis($table, @tokens, -> $r { @reductions.push($r.gn) });
say 'accepted    : ', $ok.so;
say 'reductions  :';
say '  ', $_ for @reductions;

# Output:
#     productions : 7
#     top symbol  : S
#     states      : 22
#     
#     table keys  : data, grammars, gtop, payloads, top
#     
#     accepted    : True
#     reductions  :
#       F -> n
#       T -> F
#       E -> T
#       F -> n
#       T -> F
#       F -> n
#       T -> T star F
#       E -> E plus T
#       S -> E
