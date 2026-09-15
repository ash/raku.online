---
name: as-cli-arguments
version: 0.0.10
auth: zef:lizmat
kind: Distribution · command line
summary: Renders a Capture back into the command line that would have
  produced it — provided every value is already a Str.
status: divergent
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/as-cli-arguments
source: https://github.com/lizmat/as-cli-arguments.git
---

## What it is for

A `MAIN` sub receives a `Capture`. Logging "here is the command that ran", or
building a subprocess invocation that mirrors your own options, means turning
that `Capture` back into argument text. This distribution does exactly that,
in 47 lines.

## Rendering

```raku name="basics"
use as-cli-arguments;

say 'capture       : ', as-cli-arguments(\('a', 'b', :verbose, :n<3>)).raku;
say 'named-anywhere: ', as-cli-arguments(\('a', :verbose, :n<3>), :named-anywhere).raku;
say 'nameds only   : ', as-cli-arguments(\(:a<1>, :b<2>)).raku;
say 'empty capture : ', as-cli-arguments(\()).raku;
say '';
say 'a false boolean renders as Raku`s --/name, not --no-name:';
say '  ', as-cli-arguments(\(:on, :!off)).raku;
say '';
say 'a name with a dash survives:';
say '  ', as-cli-arguments(\(:dry-run)).raku;
```

```output
capture       : "--n=3 --verbose a b"
named-anywhere: "a --n=3 --verbose"
nameds only   : "--a=1 --b=2"
empty capture : ""

a false boolean renders as Raku`s --/name, not --no-name:
  "--/off --on"

a name with a dash survives:
  "--dry-run"
```

Named arguments come out first by default and positionals after; pass
`:named-anywhere` for the more usual order.

## The other three candidates

```raku name="shapes"
use as-cli-arguments;

my %h = apple => 'a', zebra => 'z', mango => 'm';
say 'a Hash is rendered in SORTED key order:';
say '  ', as-cli-arguments(%h).raku;
say '';
my @pairs = zebra => 'z', apple => 'a', mango => 'm';
say 'a list of pairs KEEPS your order:';
say '  ', as-cli-arguments(@pairs).raku;
say '';
say 'if you care about option order, pass a list of pairs.';
say '';
my $pair = url => 'http://x';
say 'a single Pair, passed through a variable:';
say '  ', as-cli-arguments($pair).raku;
say '  note the quoting — a value containing whitespace or a colon is';
say '  wrapped in single quotes.';
```

```output
a Hash is rendered in SORTED key order:
  "--apple=a --mango=m --zebra=z"

a list of pairs KEEPS your order:
  "--zebra=z --apple=a --mango=m"

if you care about option order, pass a list of pairs.

a single Pair, passed through a variable:
  "--url='http://x'"
  note the quoting — a value containing whitespace or a colon is
  wrapped in single quotes.
```

The `Pair:D` candidate looks like the natural entry point and is the hardest
one to hit: `as-cli-arguments(x => '9')` is a *named* argument in Raku, and
the proto demands a positional, so it dies. Pass the pair through a variable.

## The one thing to know

Every value must already be a `Str`. A number throws, from inside the module,
with a message that names neither your argument nor the sub you called.

```raku name="strings"
use as-cli-arguments;

my $r = try as-cli-arguments(\(1, 2));
say 'as-cli-arguments(\(1, 2))        -> ', $! ?? 'threw ' ~ $!.^name !! $r.raku;
my $p = count => 42;
my $r2 = try as-cli-arguments($p);
say 'a Pair with an Int value         -> ', $! ?? 'threw ' ~ $!.^name !! $r2.raku;
say '';
say 'the private stringify is declared --> Str:D and returns its argument';
say 'UNCHANGED whenever it is defined and holds no whitespace or colon —';
say 'so for anything that is not a Str the RETURN type-check fires.';
say '';
say 'stringify your own values first:';
say '  ', as-cli-arguments(\('1', '2')).raku;
my $ok = count => '42';
say '  ', as-cli-arguments($ok).raku;
say '';
say 'the failure happens on the most ordinary input imaginable — a numeric';
say 'option value — and the API gives no hint that .Str is needed.';
```

```output
as-cli-arguments(\(1, 2))        -> threw X::TypeCheck::Return
a Pair with an Int value         -> threw X::TypeCheck::Return

the private stringify is declared --> Str:D and returns its argument
UNCHANGED whenever it is defined and holds no whitespace or colon —
so for anything that is not a Str the RETURN type-check fires.

stringify your own values first:
  "1 2"
  "--count=42"

the failure happens on the most ordinary input imaginable — a numeric
option value — and the API gives no hint that .Str is needed.
```

## Quoting is not escaping

```raku name="quoting"
use as-cli-arguments;

for (msg => 'hello world'), (url => 'http://x'), (who => "it's mine"), (v => Str) -> $p {
    say sprintf('  %-22s -> %s', $p.raku, as-cli-arguments($p).raku);
}
say '';
say 'quoting triggers on whitespace or ":" only. The quote character';
say 'itself is neither checked nor doubled, so a value containing an';
say 'apostrophe renders a string no shell will parse back.';
say '';
say 'and an undefined value renders as an empty string — a Pair gives';
say '--v= and a positional gives nothing at all, a silently dropped';
say 'argument.';
```

```output
  :msg("hello world")    -> "--msg='hello world'"
  :url("http://x")       -> "--url='http://x'"
  :who("it's mine")      -> "--who='it's mine'"
  :v(Str)                -> "--v="

quoting triggers on whitespace or ":" only. The quote character
itself is neither checked nor doubled, so a value containing an
apostrophe renders a string no shell will parse back.

and an undefined value renders as an empty string — a Pair gives
--v= and a positional gives nothing at all, a silently dropped
argument.
```

## Where the two engines differ

The `:named-anywhere` default reads `%*SUB-MAIN-OPTS<named-anywhere>`, and
Raku++ does not see a dynamic variable from inside a parameter default — so
the option is honoured on one engine and ignored on the other.

```raku name="named-anywhere"
use as-cli-arguments;

# pass it explicitly and both engines agree
my $c = \('pos', :n<1>);
say 'default            : ', as-cli-arguments($c).raku;
say ':named-anywhere    : ', as-cli-arguments($c, :named-anywhere).raku;
say '';
say 'setting %*SUB-MAIN-OPTS<named-anywhere> works on Rakudo and is';
say 'invisible to Raku++, because a dynamic variable read in a PARAMETER';
say 'DEFAULT does not see the caller`s frame there. Reading it directly';
say 'inside a routine body works on both.';
say '';
say 'so: pass :named-anywhere at the call site rather than relying on the';
say 'dynamic variable.';
```

```output
default            : "--n=1 pos"
:named-anywhere    : "pos --n=1"

setting %*SUB-MAIN-OPTS<named-anywhere> works on Rakudo and is
invisible to Raku++, because a dynamic variable read in a PARAMETER
DEFAULT does not see the caller`s frame there. Reading it directly
inside a routine body works on both.

so: pass :named-anywhere at the call site rather than relying on the
dynamic variable.
```

Two other candidates to know about: `@nameds` requires every element to be a
`Pair` (a list of plain strings dies with a binding failure on a *private*
sub's parameter), and `as-cli-arguments(\(Str))` renders an undefined
positional as nothing at all.
