---
name: path-coverage
version: 0.2
auth: github:teodozjan
kind: Distribution · developer tools
summary: Two lint scripts for a distribution's source tree — neither of which
  can see a `.rakumod` file.
status: full
suite: no test files, so trivially green
tested: 2026-09-15
license: Artistic-2.0
depends: File::Find
raku-land: https://raku.land/github:teodozjan/path-coverage
source: git://github.com/teodozjan/path6-coverage.git
---

## What it is for

A distribution's `lib/Foo/Bar.rakumod` should declare `unit class Foo::Bar`,
and its META6 `provides` should list that pair. Checking both by hand is
tedious, so this distribution ships two scripts: one complains about
mismatches, one prints the `provides` entries.

There is no importable API — `provides` is empty and the distribution is two
`bin/` scripts.

## What they print

```raku name="coverage"
my $root = $*TMPDIR.add("pathcov-{$*PID}");
LEAVE { run 'rm', '-rf', $root.Str }
$root.add('lib/Deep').mkdir;
$root.add('lib/Good.pm6').spurt("unit class Good;\n");
$root.add('lib/Bad.pm6').spurt("unit class Wrong;\n");
$root.add('lib/Deep/Ok.pm6').spurt("unit class Deep::Ok;\n");
$root.add('lib/Modern.rakumod').spurt("unit class AlsoWrong;\n");

my $bin = $*HOME.add('.raku/bin');
indir $root, {
    my $cov = run $bin.add('path-coverage').Str, :out;
    say 'path-coverage says:';
    say '  ', $_ for $cov.out.slurp(:close).lines.sort;
    say '';
    my $prov = run $bin.add('path-provides').Str, :out;
    say 'path-provides says:';
    say '  ', $_ for $prov.out.slurp(:close).lines.sort;
}
```

```output
path-coverage says:
  Wrong should be Bad or declared with my keyword

path-provides says:
  "Deep::Ok" : "./lib/Deep/Ok.pm6",
  "Good" : "./lib/Good.pm6",
  "Wrong" : "./lib/Bad.pm6",
```

## The one thing to know

Neither script can see a `.rakumod` or `.raku` file, so on any modern
distribution both print nothing and exit 0 — a clean bill of health that means
"I did not look".

```raku name="blind"
my $root = $*TMPDIR.add("pathcov2-{$*PID}");
LEAVE { run 'rm', '-rf', $root.Str }
$root.add('lib').mkdir;
$root.add('lib/Modern.rakumod').spurt("unit class AlsoWrong;\n");

my $bin = $*HOME.add('.raku/bin/path-coverage').Str;
my @lines = indir $root, { run($bin, :out).out.slurp(:close).lines.grep(*.chars) };
say 'a lib/ holding only Modern.rakumod, declaring `unit class AlsoWrong`:';
say '  path-coverage output lines : ', @lines.elems;
say '';
say 'the file filter is  name => /.p [l||m] 6? $/  — a literal "p" then';
say '"l" or "m" at the end of the name. It matches .pm, .pm6, .pl, .pl6';
say 'and nothing else. A distribution written since the .rakumod rename';
say 'gets a silent all-clear from path-coverage and an EMPTY provides';
say 'block from path-provides, which is precisely the case where you';
say 'most wanted the tool to speak up.';
```

```output
a lib/ holding only Modern.rakumod, declaring `unit class AlsoWrong`:
  path-coverage output lines : 0

the file filter is  name => /.p [l||m] 6? $/  — a literal "p" then
"l" or "m" at the end of the name. It matches .pm, .pm6, .pl, .pl6
and nothing else. A distribution written since the .rakumod rename
gets a silent all-clear from path-coverage and an EMPTY provides
block from path-provides, which is precisely the case where you
most wanted the tool to speak up.
```

## Two more things it gets wrong

```raku name="quirks"
my $root = $*TMPDIR.add("pathcov3-{$*PID}");
LEAVE { run 'rm', '-rf', $root.Str }
$root.add('lib').mkdir;
$root.add('lib/Plain.pm6').spurt("class Inner \{ \}\nmy class Hidden \{ \}\n");
$root.add('lib/R.pl6').spurt("unit role R;\n");
$root.add('Top.pm6').spurt("unit class Top;\n");

indir $root, {
    my $p = run $*HOME.add('.raku/bin/path-coverage').Str, :out;
    say 'path-coverage says:';
    say '  ', $_ for $p.out.slurp(:close).lines.sort;
}
say '';
say 'a non-`unit` inner declaration is reported as if it were the file`s';
say 'package, so any file with a helper class in it produces a false';
say 'positive. `my class` is correctly ignored, so the two ARE told apart';
say '— but only the `my` form.';
say '';
say 'the name stripper only removes \\.pm6?$, so a .pl6 or .p6 file keeps';
say 'its extension in the expected name and can never match. And outside';
say 'a lib/ directory the expected name is derived from the raw relative';
say 'path, giving nonsense like ".::Top".';
```

```output
path-coverage says:
  Inner should be Plain or declared with my keyword
  R should be R.pl6 or declared with my keyword
  Top should be .::Top or declared with my keyword

a non-`unit` inner declaration is reported as if it were the file`s
package, so any file with a helper class in it produces a false
positive. `my class` is correctly ignored, so the two ARE told apart
— but only the `my` form.

the name stripper only removes \.pm6?$, so a .pl6 or .p6 file keeps
its extension in the expected name and can never match. And outside
a lib/ directory the expected name is derived from the raw relative
path, giving nonsense like ".::Top".
```

`path-provides` performs no checking at all — it transcribes whatever name it
finds beside whatever path it found it in, including the mismatched pair that
`path-coverage` flags. Its output is also not valid JSON: every line ends in a
comma, including the last, and there are no enclosing braces.

## Where the two engines differ

Nothing. Both scripts produce byte-identical output on both engines for every
tree above, including the blind spot — this is `File::Find` plus a grammar,
and the parts that could diverge are not reached.

```raku name="grammar"
say 'one implementation detail worth knowing, because it explains the';
say 'shape of the output: the grammar`s TOP requires a `unit` declaration';
say 'immediately followed by a `my unit` declaration on the same line,';
say 'which a real line of source essentially never satisfies.';
say '';
say 'the tool produces output anyway, because Raku action methods fire';
say 'for sub-rules that matched even when the overall parse fails. The';
say 'entire output is a side effect of a parse that never succeeds.';
say '';
say 'both scripts start #!/usr/bin/env perl6. That works through the';
say 'installed ~/.raku/bin wrappers on both engines, but the shebang';
say 'itself would need a perl6 on PATH if you ran the file directly.';
```

```output
one implementation detail worth knowing, because it explains the
shape of the output: the grammar`s TOP requires a `unit` declaration
immediately followed by a `my unit` declaration on the same line,
which a real line of source essentially never satisfies.

the tool produces output anyway, because Raku action methods fire
for sub-rules that matched even when the overall parse fails. The
entire output is a side effect of a parse that never succeeds.

both scripts start #!/usr/bin/env perl6. That works through the
installed ~/.raku/bin wrappers on both engines, but the shebang
itself would need a perl6 on PATH if you ran the file directly.
```
