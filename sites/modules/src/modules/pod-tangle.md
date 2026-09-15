---
name: Pod::Tangle
version: 0.0.2
auth: github:codesections
kind: Distribution · Pod
summary: Strips the Pod out of a Raku file and keeps the code — and a single
  abbreviated directive makes it return an empty file.
status: divergent
suite: no test files, so trivially green
tested: 2026-09-15
license: Artistic-2.0
depends: Pod::Literate
raku-land: https://raku.land/github:codesections/Pod::Tangle
source: https://github.com/codesections/pod-tangle.git
---

## What it is for

Literate programming has two operations: *weave* produces the documentation
and *tangle* produces the code. This distribution is the tangle half for Raku
— read a file, replace every `=begin X … =end X` block with a blank line,
return what is left.

## Tangling

```raku name="basics"
use Pod::Tangle;

my $f = $*TMPDIR.add("tangle-{$*PID}.raku");
LEAVE $f.unlink;
$f.spurt(q:to/END/);
my $x = 1;

=begin pod
Some documentation about $x.
=end pod

say $x + 1;

=begin comment
A comment block.
=end comment

say "done";
END

my $code = tangle($f);
say 'tangled:';
say '[[', $code, ']]';
say '';
say 'each removed block leaves TWO blank lines, and =begin comment is';
say 'stripped exactly like =begin pod.';
```

```output
tangled:
[[my $x = 1;




say $x + 1;




say "done";
]]

each removed block leaves TWO blank lines, and =begin comment is
stripped exactly like =begin pod.
```

## The one thing to know

`tangle` silently destroys your file if it contains a single **abbreviated**
Pod directive — and what you get back differs by engine.

```raku name="abbreviated"
use Pod::Tangle;

my $f = $*TMPDIR.add("tangle2-{$*PID}.raku");
LEAVE $f.unlink;
$f.spurt("=head1 NAME\n\nmy \$x = 1;\nsay \$x;\n");

my $code = tangle($f);
say 'a file whose only Pod is `=head1 NAME`:';
say '  the code survived   : ', $code.contains('say');
say '  anything useful     : ', ($code.contains('say') ?? 'yes' !! 'no');
say '';
say 'Pod::Literate`s grammar only knows "=begin" … "=end", and its';
say '`token code` is [^^ <![=]> \N* \n]+ — so a line starting with "=" that';
say 'is not a =begin block can be matched by neither alternative.';
say '';
say '.parse needs a full match, so parsefile returns Nil, and Pod::Tangle';
say 'then does Nil.caps.map({ when … }) with NO default. On Raku++ that';
say 'yields nothing and you get ""; on Rakudo it yields one element which';
say 'falls out of the when chain, and you get the five-character string';
say '"False".';
say '';
say 'neither throws. And =head1 NAME is the most common Pod idiom in';
say 'Raku — so the failure you will actually hit produces an empty file';
say 'with exit status 0.';
```

```output
a file whose only Pod is `=head1 NAME`:
  the code survived   : False
  anything useful     : no

Pod::Literate`s grammar only knows "=begin" … "=end", and its
`token code` is [^^ <![=]> \N* \n]+ — so a line starting with "=" that
is not a =begin block can be matched by neither alternative.

.parse needs a full match, so parsefile returns Nil, and Pod::Tangle
then does Nil.caps.map({ when … }) with NO default. On Raku++ that
yields nothing and you get ""; on Rakudo it yields one element which
falls out of the when chain, and you get the five-character string
"False".

neither throws. And =head1 NAME is the most common Pod idiom in
Raku — so the failure you will actually hit produces an empty file
with exit status 0.
```

A file whose last line has no trailing newline fails the same way.

## Telling success from failure

```raku name="guard"
use Pod::Tangle;

my $dir = $*TMPDIR.add("tangle3-{$*PID}");
LEAVE { .unlink for $dir.dir; $dir.rmdir }
$dir.mkdir;
$dir.add('good.raku').spurt("my \$x = 1;\n=begin pod\ndocs\n=end pod\nsay \$x;\n");
$dir.add('abbrev.raku').spurt("=head1 NAME\nsay 1;\n");
$dir.add('podonly.raku').spurt("=begin pod\njust docs\n=end pod\n");
$dir.add('empty.raku').spurt('');

say 'an empty result cannot be distinguished from a legitimate one —';
say 'a Pod-only file and an empty file both tangle to "":';
for <good abbrev podonly empty> -> $n {
    my $r = tangle($dir.add("$n.raku"));
    say sprintf('  %-10s -> code survived ? %s', $n, $r.contains('say').so);
}
say '';
say 'so check the input yourself before you trust the output:';
sub safe-tangle(IO::Path $f) {
    my $src = $f.slurp;
    die "abbreviated Pod directive in {$f.basename}"
        if $src ~~ /^^ '=' <!before 'begin'> <!before 'end'> /;
    die "no trailing newline in {$f.basename}" unless $src.ends-with("\n");
    tangle($f)
}
for <good abbrev> -> $n {
    my $r = try safe-tangle($dir.add("$n.raku"));
    say sprintf('  safe-tangle(%-12s) -> %s', "$n.raku",
                $! ?? $!.message !! 'code survived ' ~ $r.contains('say').so);
}
```

```output
an empty result cannot be distinguished from a legitimate one —
a Pod-only file and an empty file both tangle to "":
  good       -> code survived ? True
  abbrev     -> code survived ? False
  podonly    -> code survived ? False
  empty      -> code survived ? False

so check the input yourself before you trust the output:
  safe-tangle(good.raku   ) -> code survived True
  safe-tangle(abbrev.raku ) -> abbreviated Pod directive in abbrev.raku
```

## Where the two engines differ

Exactly the garbage above: `""` on Raku++ and `"False"` on Rakudo, because
`Nil.map` yields zero elements on one engine and one on the other. Reduced
with no module involved, `Nil.caps.map({ … }).elems` is `0` and `1`
respectively.

```raku name="scope"
use Pod::Tangle;

say 'two more things worth knowing before you run this over a project.';
say '';
say '`=begin code` blocks INSIDE pod are stripped along with the prose, so';
say 'tangling a literate file removes its worked examples as well as its';
say 'explanation. If your examples are the code you wanted, this is not';
say 'the tool.';
say '';
say 'and the unit declares `unit module Pod::Tangle:ver<0.0.1>` while the';
say 'distribution META says 0.0.2 — the two disagree.';
say '';
say 'the API is one exported sub: tangle(IO::Path $file --> Str).';
```

```output
two more things worth knowing before you run this over a project.

`=begin code` blocks INSIDE pod are stripped along with the prose, so
tangling a literate file removes its worked examples as well as its
explanation. If your examples are the code you wanted, this is not
the tool.

and the unit declares `unit module Pod::Tangle:ver<0.0.1>` while the
distribution META says 0.0.2 — the two disagree.

the API is one exported sub: tangle(IO::Path $file --> Str).
```
