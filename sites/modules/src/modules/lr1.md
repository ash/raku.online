---
name: LR1
version: 0.0.5
auth: zef:codechurch
kind: Distribution · parsing
summary: An LR(1) parser generator and runner in one module — where you never
  declare the start symbol, so the obvious grammar fails.
status: full
suite: no test files, so trivially green
tested: 2026-09-15
license: none stated
depends: none beyond the core
raku-land: https://raku.land/zef:codechurch/LR1
source: unstated in META
---

## What it is for

Raku grammars are recursive descent with backtracking, which is wonderful
until you need a deterministic bottom-up parse — a language with genuine
operator precedence, or a grammar you already have in yacc form. This
distribution builds the LR(1) action and goto tables from a rule list and
walks a token stream against them.

## Generating and parsing

```raku name="basics"
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
```

```output
productions : 7
top symbol  : S
states      : 22

table keys  : data, grammars, gtop, payloads, top

accepted    : True
reductions  :
  F -> n
  T -> F
  E -> T
  F -> n
  T -> F
  F -> n
  T -> T star F
  E -> E plus T
  S -> E
```

## The one thing to know

You never declare the start symbol. It is *inferred* as the one non-terminal
that appears on no right-hand side — so a directly recursive start symbol is
not eligible, and the most natural grammar in the world dies.

```raku name="top"
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
```

```output
the obvious grammar:
S => 1
  DIED: TOP not found

with a wrapper production:
  top = Z

two eligible symbols is also an error:
  DIED: TOP (…) more then one

so every grammar needs exactly one wrapper rule whose left side
appears nowhere else.
```

That same symbol doubles as the **end-of-input marker**, which is the second
half of the trap:

```raku name="marker"
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
```

```output
the top symbol is : Z

parsing  n Z n n:
  accepted   : True
  reductions : E -> n | Z -> E

the two trailing tokens were never consumed — a token whose `cata`
equals the top symbol silently terminates the parse. Choose a top
symbol that cannot appear in your token stream.
```

## Semantic values do not flow

```raku name="values"
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
```

```output
a hand-kept stack gives : [14]

after a reduction the runner pushes a bare lr1token($g[0]), so
$r.syms for a non-terminal child is a NAME with no value:
  the callback sees the production text and the symbol names, and
  nothing else. Keep your own stack, as above.

lr1token mixes a role into $obj.Str:
  isa Str        : True
  does LR1Token  : True
  .cata          : "42"
  .lineno        : -1   <- -1 with no Match
```

## Where the two engines differ

Nothing in the tables or the parse. One text difference: the terminal list
inside a syntax-error message comes from `%hash.keys`, whose order is stable
under Raku++ and randomised per process under Rakudo — so the message text
varies there.

```raku name="errors"
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
```

```output
a bad parse is a DIE, not a return value:
  threw — wrap it

an empty token stream returns Nil rather than False:
  Nil

one structural limit worth knowing: !firsts only inspects
$g.right[0], so nullable productions are not handled. And the
"TOP not found" diagnostic PUTs the symbol table to stdout while the
die goes to stderr, so the two interleave unpredictably.
```
