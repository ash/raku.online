---
name: DFM::Parser
version: 0.0.1
auth: zef:massa
kind: Distribution · data formats
summary: A grammar for Delphi form files — no actions, no serialiser, and a
  number list of more than one number never parses.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:massa/DFM::Parser
source: https://github.com/massa/DFM-Parser.git
---

## What it is for

A `.dfm` file is the textual form of a Delphi form: nested `object … end`
blocks with `Name = Value` components. Reading one — to migrate a UI, to audit
a legacy application, to extract strings — needs a parser for its small,
idiosyncratic syntax.

This distribution is the grammar. It ships no actions class and no serialiser,
so you get a raw `Match` tree and do your own walking.

## Parsing

```raku name="basics"
use DFM::Parser;

my $dfm = q:to/END/;
object Form1: TForm1
  Left = 192
  Caption = 'Hello'
  Font.Height = -11
  object Panel1: TPanel
    Align = alTop
  end
end
END

my $m = DFM::Parser.parse($dfm);
say 'parsed      : ', $m.defined;
say 'id          : ', $m<object><id>.Str;
say 'classname   : ', $m<object><classname>.Str;
say '';
for $m<object><component>.list -> $c {
    if $c<object> {
        say '  nested object: ', $c<object><classname>.Str;
    } else {
        say sprintf('  %-14s = %s', $c<component-name>.Str, $c<component-value>.Str.trim);
    }
}
```

```output
parsed      : True
id          : Form1
classname   : TForm1

  Left           = 192
  Caption        = 'Hello'
  Font.Height    = -11
  nested object: TPanel
```

## The one thing to know

A number list with more than one number never parses.

```raku name="number-list"
use DFM::Parser;

for '(1 2)', '(1)', '()', "('a' 'b')" -> $v {
    my $m = DFM::Parser.parse($v, rule => 'component-value');
    say sprintf('  component-value %-10s -> %s', $v.raku, $m.defined ?? 'MATCH' !! 'no match');
}
say '';
say 'number-list is a `rule` whose body is <number>*, and `number` is a';
say '`token` — so nothing eats the whitespace BETWEEN repetitions. A';
say 'rule`s implicit <.ws> sits after the quantified atom, not inside it.';
say '';
say 'string-list survives only because `string` is itself a rule and';
say 'swallows its own trailing space.';
say '';
say 'any real .dfm containing a Left = (0 0 100 100) fails outright, and';
say 'you get Nil, not a diagnostic.';
```

```output
  component-value "(1 2)"    -> no match
  component-value "(1)"      -> MATCH
  component-value "()"       -> MATCH
  component-value "('a' 'b')" -> MATCH

number-list is a `rule` whose body is <number>*, and `number` is a
`token` — so nothing eats the whitespace BETWEEN repetitions. A
rule`s implicit <.ws> sits after the quantified atom, not inside it.

string-list survives only because `string` is itself a rule and
swallows its own trailing space.

any real .dfm containing a Left = (0 0 100 100) fails outright, and
you get Nil, not a diagnostic.
```

## Every failure is `Nil`

```raku name="failures"
use DFM::Parser;

my %cases =
    'well formed'      => "object A: TA\n  X = 1\nend\n",
    'missing end'      => "object A: TA\n  X = 1\n",
    'total garbage'    => "not a form at all\n",
    'empty string'     => '',
    'unterminated str' => "object A: TA\n  X = 'oops\nend\n";

for %cases.keys.sort -> $k {
    my $m = DFM::Parser.parse(%cases{$k});
    say sprintf('  %-18s -> defined=%-6s isFailure=%s',
                $k, $m.defined, ($m ~~ Failure).so);
}
say '';
say 'never an exception, never a Failure — always Nil. And the failure is';
say 'easy to miss, because indexing the result gives silent garbage:';
my $bad = DFM::Parser.parse('garbage');
say '  $bad<object>          : ', $bad<object>.raku;
say '  $bad<o><c>.elems      : ', $bad<o><c>.elems, '   <- Any.elems is 1';
say '';
say 'test .defined on the result; never trust .elems of a chained subscript.';
```

```output
  empty string       -> defined=False  isFailure=False
  missing end        -> defined=False  isFailure=False
  total garbage      -> defined=False  isFailure=False
  unterminated str   -> defined=False  isFailure=False
  well formed        -> defined=True   isFailure=False

never an exception, never a Failure — always Nil. And the failure is
easy to miss, because indexing the result gives silent garbage:
  $bad<object>          : Any
  $bad<o><c>.elems      : 1   <- Any.elems is 1

test .defined on the result; never trust .elems of a chained subscript.
```

## What the grammar does not check

```raku name="lax"
use DFM::Parser;

my %cases =
    'spaced slashes'     => "object A / TA\nend\n",
    'nine on rank one'   => "object A: TA\n  X = 1\nend\n",
    'seven ranks only'   => "object A: TA\nend\n",
    'dotted name'        => "object A: TA\n  Font.Height = -11\nend\n",
    'hashtag char'       => "object A: TA\n  S = #65#66\nend\n";
for %cases.keys.sort -> $k {
    say sprintf('  %-20s -> %s', $k,
                DFM::Parser.parse(%cases{$k}).defined ?? 'parses' !! 'no parse');
}
say '';
say 'TOP accepts exactly ONE object and is not anchored for leading';
say 'comments, so a real file with a header or two top-level objects will';
say 'not parse either.';
```

```output
  dotted name          -> parses
  hashtag char         -> parses
  nine on rank one     -> parses
  seven ranks only     -> parses
  spaced slashes       -> no parse

TOP accepts exactly ONE object and is not anchored for leading
comments, so a real file with a header or two top-level objects will
not parse either.
```

## Where the two engines differ

Bracketed identifier sets — `BorderIcons = [biSystemMenu, biMinimize]`, which
almost every real form has — are unreachable through `component-value` under
Raku++, although `:rule<dset>` matches them directly there.

```raku name="dset"
use DFM::Parser;

say 'the rule matches on its own:';
say '  :rule<dset> on "[a, b]" -> ',
    DFM::Parser.parse('[a, b]', rule => 'dset').defined ?? 'MATCH' !! 'no match';
say '';
say 'reaching it through component-value is engine-dependent — Raku++`s';
say 'longest-token alternation cannot select a branch containing a';
say '%-separated quantifier, so a form with a BorderIcons line parses on';
say 'Rakudo and fails on Raku++.';
say '';
say 'and the rule will not accept internal spaces on either engine:';
for '[a,b]', '[a, b]', '[ a , b ]' -> $v {
    say sprintf('  %-12s -> %s', $v.raku,
                DFM::Parser.parse($v, rule => 'dset').defined ?? 'MATCH' !! 'no match');
}
```

```output
the rule matches on its own:
  :rule<dset> on "[a, b]" -> MATCH

reaching it through component-value is engine-dependent — Raku++`s
longest-token alternation cannot select a branch containing a
%-separated quantifier, so a form with a BorderIcons line parses on
Rakudo and fails on Raku++.

and the rule will not accept internal spaces on either engine:
  "[a,b]"      -> MATCH
  "[a, b]"     -> MATCH
  "[ a , b ]"  -> no match
```
