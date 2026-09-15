---
name: allow-no
version: 0.0.1
auth: zef:lizmat
kind: Distribution · command line
summary: One line that rewrites `--no-foo` into Raku's `--/foo` before MAIN
  parses — including after the `--` end-of-options separator.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/allow-no
source: https://github.com/lizmat/allow-no.git
---

## What it is for

Raku spells "turn this flag off" as `--/verbose`. Most other command-line
tools spell it `--no-verbose`, and that is what users type. Rakudo can accept
the familiar form via `%*SUB-MAIN-OPTS<allow-no>`; this distribution is the
shim for engines and versions that cannot.

The whole module is one line:

```raku fragment
INIT $_ .= subst(/^ '--no-' /, '--/') for @*ARGS;
```

## What `use` changes

```raku name="basics"
# this example drives MAIN by hand so the page can show both sides
use allow-no;

my @before = <--no-bar init --no-baz>;
my @rewritten = @before.map({ .subst(/^ '--no-' /, '--/') });
say 'what the INIT block does to @*ARGS:';
for @before Z @rewritten -> ($b, $a) {
    say sprintf('  %-12s -> %s', $b, $a);
}
say '';
say 'and that is all it does. There is no class, no sub, no exported';
say 'symbol — ::("allow-no") is not a package on either engine.';
say '';
say 'in a real script:';
say '  use allow-no;';
say '  sub MAIN(:$bar, *@rest) { … }';
say '  $ script --no-bar        # $bar is False';
```

```output
what the INIT block does to @*ARGS:
  --no-bar     -> --/bar
  init         -> init
  --no-baz     -> --/baz

and that is all it does. There is no class, no sub, no exported
symbol — ::("allow-no") is not a package on either engine.

in a real script:
  use allow-no;
  sub MAIN(:$bar, *@rest) { … }
  $ script --no-bar        # $bar is False
```

## The one thing to know

The rewrite ignores the `--` end-of-options separator, so it mangles ordinary
positional data.

```raku name="separator"
use allow-no;

my @args = <-- --no-brainer>;
say 'a user typed:  -- --no-brainer';
say '  the "--" means "everything after this is a positional".';
say '';
say 'the INIT block rewrites every element unconditionally:';
say '  ', @args.map({ .subst(/^ '--no-' /, '--/') }).raku;
say '';
say 'so a filename, a search term, a branch name — anything that happens';
say 'to start with --no- — is silently corrupted, even when the user';
say 'explicitly ended option parsing.';
say '';
say 'Rakudo`s own %*SUB-MAIN-OPTS<allow-no> shares this bug, so it is not';
say 'a reason to prefer one over the other — but it is a reason to reach';
say 'for a real option parser once your CLI has positional arguments that';
say 'come from users.';
```

```output
a user typed:  -- --no-brainer
  the "--" means "everything after this is a positional".

the INIT block rewrites every element unconditionally:
  ("--", "--/brainer").Seq

so a filename, a search term, a branch name — anything that happens
to start with --no- — is silently corrupted, even when the user
explicitly ended option parsing.

Rakudo`s own %*SUB-MAIN-OPTS<allow-no> shares this bug, so it is not
a reason to prefer one over the other — but it is a reason to reach
for a real option parser once your CLI has positional arguments that
come from users.
```

## It leaks, process-wide

```raku name="leak"
use allow-no;

say 'this is not a lexical pragma. It is an INIT block that mutates one';
say 'process-global array, once.';
say '';
say 'so any DEPENDENCY anywhere in your tree that does `use allow-no`';
say 'changes how YOUR command line parses, and there is no opt-out —';
say 'unlike the core feature, which is opt-in per program.';
say '';
say 'if you want it, say so yourself rather than inheriting it:';
say '  my %*SUB-MAIN-OPTS = :allow-no;   # Rakudo';
say '  use allow-no;                     # both engines';
```

```output
this is not a lexical pragma. It is an INIT block that mutates one
process-global array, once.

so any DEPENDENCY anywhere in your tree that does `use allow-no`
changes how YOUR command line parses, and there is no opt-out —
unlike the core feature, which is opt-in per program.

if you want it, say so yourself rather than inheriting it:
  my %*SUB-MAIN-OPTS = :allow-no;   # Rakudo
  use allow-no;                     # both engines
```

## Where the two engines differ

The core feature the module shims is missing from Raku++: a
`my %*SUB-MAIN-OPTS = :allow-no;` has no effect there, so on Raku++ this
module is not a shim for an older compiler — it is the only way to get
`--no-foo` at all.

```raku name="core"
use allow-no;

say 'on Rakudo you have two routes:';
say '  my %*SUB-MAIN-OPTS = :allow-no;   # core';
say '  use allow-no;                     # this module';
say '';
say 'on Raku++ only the second works. The core dynamic variable is not';
say 'implemented, so a script relying on it prints its Usage block and';
say 'exits 2.';
say '';
say 'the portable spelling is to do both — they are idempotent together,';
say 'because the module rewrites --no-foo to --/foo and the core option';
say 'then finds nothing left to do:';
say '  my %*SUB-MAIN-OPTS = :allow-no;';
say '  use allow-no;';
```

```output
on Rakudo you have two routes:
  my %*SUB-MAIN-OPTS = :allow-no;   # core
  use allow-no;                     # this module

on Raku++ only the second works. The core dynamic variable is not
implemented, so a script relying on it prints its Usage block and
exits 2.

the portable spelling is to do both — they are idempotent together,
because the module rewrites --no-foo to --/foo and the core option
then finds nothing left to do:
  my %*SUB-MAIN-OPTS = :allow-no;
  use allow-no;
```
