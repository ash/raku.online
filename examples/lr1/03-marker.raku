#!/usr/bin/env rakupp
# LR1 — The one thing to know
# https://raku.online/modules/lr1/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install LR1
#     rakupp 03-marker.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use LR1;

my $y = LR1Yacc.set-grammar(['Z -> E', 'E -> n']);
$y.analysis;
my $table = $y.get-actions-data;
say 'the top symbol is : ', $y.top;
say '';
my @tokens = <n Z n n>.map({ lr1token($_) });
my @seen;
my $c = LR1Compiling.new;
my $ok = $c.syntax-analysis($table, @tokens, -> $r { @seen.push($r.gn) });
say 'parsing  n Z n n:';
say '  accepted   : ', $ok.so;
say '  reductions : ', @seen.join(' | ');
say '';
say 'the two trailing tokens were never consumed — a token whose `cata`';
say 'equals the top symbol silently terminates the parse. Choose a top';
say 'symbol that cannot appear in your token stream.';

# Output:
#     the top symbol is : Z
#     
#     parsing  n Z n n:
#       accepted   : True
#       reductions : E -> n | Z -> E
#     
#     the two trailing tokens were never consumed — a token whose `cata`
#     equals the top symbol silently terminates the parse. Choose a top
#     symbol that cannot appear in your token stream.
