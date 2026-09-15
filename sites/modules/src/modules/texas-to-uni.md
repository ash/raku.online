---
name: Texas::To::Uni
version: 0.1.0
auth: github:Altai-man
kind: Distribution · source tools
summary: Rewrites ASCII operator spellings into their Unicode equivalents —
  by plain substring substitution, inside string literals and all.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/github:Altai-man/Texas::To::Uni
source: git://github.com/Altai-man/p6-Texas-To-Uni.git
---

## What it is for

Raku spells many operators twice: `(<=)` and `⊆`, `<<` and `«`, `...` and `…`.
The ASCII spellings are called "Texas" variants — bigger, and they fit on any
keyboard. This distribution rewrites the ASCII forms into the Unicode ones, in
a string or in a file.

## Converting a string

```raku name="string"
use Texas::To::Uni;

my $src = 'my @a = (1,2) (<=) (3,4); say (5,6) (>=) (7,8);';
convert-string($src);
say $src;
say '';
my $shift = 'if $a <<= $b { say $a ** 2 }';
convert-string($shift);
say $shift;
say '';
say 'note the signature: convert-string(Str $source is rw). It MUTATES';
say 'your variable and returns Any — the return value is useless.';
my $x = 'a << b';
my $ret = convert-string($x);
say '  return value : ', $ret.raku;
say '  the variable : ', $x.raku;
```

```output
my @a = (1,2) ⊆ (3,4); say (5,6) ⊇ (7,8);

if $a «= $b { say $a ** 2 }

note the signature: convert-string(Str $source is rw). It MUTATES
your variable and returns Any — the return value is useless.
  return value : Any
  the variable : "a « b"
```

`:table` **replaces** the default table rather than merging with it:

```raku name="table"
use Texas::To::Uni;

my $s = 'a AND b (<=) c';
convert-string($s, table => Map.new('AND', "\c[LOGICAL AND]"));
say 'with a custom table : ', $s;
say '  only AND was converted — (<=) was left alone, because the custom';
say '  table is the whole table.';
```

```output
with a custom table : a ∧ b (<=) c
  only AND was converted — (<=) was left alone, because the custom
  table is the whole table.
```

## Converting a file

```raku name="file"
use Texas::To::Uni;

my $f = $*TMPDIR.add("texas-{$*PID}.raku");
my $out = $*TMPDIR.add("texas-{$*PID}.uni.raku");
LEAVE { $f.unlink; $out.unlink }
$f.spurt("say (1,2) (<=) (3,4);\n");

# convert-file prints the destination path to stdout, so capture that
my $noise = String::Stream.new('') if False;   # (no dependency; just a note)
{
    my $*OUT = class { method print(*@) { } ; method say(*@) { } }.new;
    convert-file($f.Str);
}
say 'wrote a .uni.raku beside it : ', $out.e ?? 'yes' !! 'no';
say 'body                        : ', $out.slurp.trim;
say '';
say 'without :rewrite it writes foo.uni.raku beside foo.raku; :rewrite';
say 'overwrites in place; :new-path writes where you say. It also prints';
say 'the destination path and a sentence to STDOUT — silenced above, so';
say 'this page shows the same thing on both engines.';
```

```output
wrote a .uni.raku beside it : yes
body                        : say (1,2) ⊆ (3,4);

without :rewrite it writes foo.uni.raku beside foo.raku; :rewrite
overwrites in place; :new-path writes where you say. It also prints
the destination path and a sentence to STDOUT — silenced above, so
this page shows the same thing on both engines.
```

## What it will do to your source

```raku name="damage"
use Texas::To::Uni;

for 'my $sum = $a + $b;', 'say "pi is pi ok";', 'say $a ** 2;', 'say $a** 2;' -> $line {
    my $s = $line;
    convert-string($s);
    say sprintf('  %-24s -> %s', $line, $s);
}
say '';
say 'the first line is the sharp one: " + " becomes U+207A SUPERSCRIPT';
say 'PLUS SIGN, which is not valid Raku. Running this tool over real';
say 'source silently breaks addition.';
say '';
say 'the second shows it has no idea what a string literal is.';
say 'the third and fourth show it is whitespace-sensitive: ** 2 is left';
say 'alone and **2 becomes a superscript two.';
```

```output
  my $sum = $a + $b;       -> my $sum = $a⁺$b;
  say "pi is pi ok";       -> say "pi isπok";
  say $a ** 2;             -> say $a ** 2;
  say $a** 2;              -> say $a** 2;

the first line is the sharp one: " + " becomes U+207A SUPERSCRIPT
PLUS SIGN, which is not valid Raku. Running this tool over real
source silently breaks addition.

the second shows it has no idea what a string literal is.
the third and fourth show it is whitespace-sensitive: ** 2 is left
alone and **2 becomes a superscript two.
```

## The one thing to know

The conversion is order-dependent, and the order comes from `Map.keys` — so
under Rakudo the same program gives a different answer on every run.

```raku name="order"
use Texas::To::Uni;

say 'the table contains BOTH (<=) and !(<=). Whichever key the hash hands';
say 'out first wins, and if (<=) goes first the negated form is left';
say 'half-converted as !⊆ instead of becoming ⊈.';
say '';
say 'the six negated set operators are the affected ones:';
say '  !(<=)  !(<)  !(>=)  !(>)  !(elem)  !(cont)';
say '';
say 'whether each one comes out whole or half-converted is exactly what';
say 'varies — on Rakudo it varies between RUNS of the same program.';
say '';
say 'Rakudo randomises hash iteration order per process, so those six are';
say 'a coin flip there — run the same file twice and get different output.';
say 'Raku++ uses stable insertion order, so it is deterministic but not';
say 'necessarily right. Never put this in a build step.';
```

```output
the table contains BOTH (<=) and !(<=). Whichever key the hash hands
out first wins, and if (<=) goes first the negated form is left
half-converted as !⊆ instead of becoming ⊈.

the six negated set operators are the affected ones:
  !(<=)  !(<)  !(>=)  !(>)  !(elem)  !(cont)

whether each one comes out whole or half-converted is exactly what
varies — on Rakudo it varies between RUNS of the same program.

Rakudo randomises hash iteration order per process, so those six are
a coin flip there — run the same file twice and get different output.
Raku++ uses stable insertion order, so it is deterministic but not
necessarily right. Never put this in a build step.
```

## Where the two engines differ

Exactly that. Raku++'s `Hash` and `Map` iterate in insertion order and
Rakudo's randomise per process, so a module that iterates a table without
`.sort` is deterministic on one engine and not on the other.

```raku name="portable"
use Texas::To::Uni;

# if you want a deterministic rewrite, supply a sorted table yourself:
# longest key first, so !(<=) is matched before (<=)
my %pairs = '!(<=)' => "\c[NEITHER A SUBSET OF NOR EQUAL TO]",
            '(<=)'  => "\c[SUBSET OF OR EQUAL TO]";
my $s = 'a !(<=) b; c (<=) d';
for %pairs.keys.sort({ -.chars }) -> $k {
    my $one = Map.new($k, %pairs{$k});
    convert-string($s, table => $one);
}
say 'deterministic on both engines : ', $s;
say '';
say 'everything else about this module — the substitutions themselves,';
say 'the file modes, the whitespace sensitivity — is identical on the two';
say 'engines. Only the iteration order is not.';
```

```output
deterministic on both engines : a ⊈ b; c ⊆ d

everything else about this module — the substitutions themselves,
the file modes, the whitespace sensitivity — is identical on the two
engines. Only the iteration order is not.
```
