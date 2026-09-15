---
name: Pod::Literate
version: 0.0.2
auth: github:codesections
kind: Distribution · Pod
summary: A grammar that splits a Raku source file into alternating
  documentation and code chunks, handing back the matched substrings.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/github:codesections/Pod::Literate
source: https://github.com/codesections/pod-literate.git
---

## What it is for

Literate programming interleaves prose and code, and a tool that wants to
extract either half needs to know where one ends and the other begins. Raku
already puts both in one file; what is missing is the split.

This distribution is that split, as a grammar. It is a pure text operation: it
does not build Pod objects and does not compile the code, it hands you the
matched substrings and lets you decide what they are for.

## Splitting a file

```raku name="split"
use Pod::Literate;

my $source = q:to/END/;
unit module Literate;

=begin pod
This is the first documentation block.
It has two lines.
=end pod

sub first() is export { 1 }

=begin pod
A second block, after some code.
=end pod

sub second() is export { 2 }
END

my $m = Pod::Literate.parse($source);
say 'matched     : ', $m.defined;
say 'pod chunks  : ', $m<pod>.elems;
for $m<pod>.kv -> $i, $p { say "  pod[$i]  = <<{$p.Str.trim}>>" }
say 'code chunks : ', $m<code>.elems;
for $m<code>.kv -> $i, $c { say "  code[$i] = <<{$c.Str.trim}>>" }
```

```output
matched     : True
pod chunks  : 2
  pod[0]  = <<=begin pod
This is the first documentation block.
It has two lines.
=end pod>>
  pod[1]  = <<=begin pod
A second block, after some code.
=end pod>>
code chunks : 3
  code[0] = <<unit module Literate;>>
  code[1] = <<sub first() is export { 1 }>>
  code[2] = <<sub second() is export { 2 }>>
```

The unit **is** the grammar. There is no actions class and no wrapper sub, so
`Pod::Literate.parse($text)` or `.parsefile($path)` is the whole interface,
and you read `$/<pod>` and `$/<code>` yourself. Both are lists of matches.

## What it recognises

```raku name="recognises"
use Pod::Literate;

sub try-parse($label, $text) {
    my $m = Pod::Literate.parse($text);
    say sprintf('%-32s -> %s', $label,
        $m.defined ?? "matched ({$m<pod>.elems} pod, {$m<code>.elems} code)" !! 'Nil');
}

try-parse 'delimited =begin/=end',      "=begin pod\nhi\n=end pod\nmy \$x = 1;\n";
try-parse 'abbreviated =head1',         "=head1 NAME\n\nmy \$x = 1;\n";
try-parse '=head1 inside =begin pod',   "=begin pod\n=head1 NAME\n=end pod\nmy \$x = 1;\n";
try-parse 'paragraph =for',             "=for comment\nthis\n\nmy \$x = 1;\n";
try-parse 'code only',                  "my \$x = 1;\n";
try-parse 'code, no trailing newline',  "my \$x = 1;";
try-parse 'empty string',               "";
```

```output
delimited =begin/=end            -> matched (1 pod, 1 code)
abbreviated =head1               -> Nil
=head1 inside =begin pod         -> matched (1 pod, 1 code)
paragraph =for                   -> Nil
code only                        -> matched (0 pod, 1 code)
code, no trailing newline        -> Nil
empty string                     -> matched (0 pod, 0 code)
```

## The one thing to know

Only `=begin`/`=end` pod is understood, and anything else makes the **whole
file** fail to parse.

The `pod` token requires a literal `=begin`, and the `code` token forbids any
line starting with `=`. A top-level `=head1 NAME` therefore matches neither
alternative, `TOP` cannot consume the input, and `.parse` returns **`Nil`** —
not a partial match, not an exception, not a diagnostic.

That is the common case, not a corner. The conventional Raku module preamble
is exactly `=head1 NAME` outside any `=begin pod` block, and the spike above
proves the split: `=head1` at top level gives `Nil`, while the identical
`=head1` nested inside a `=begin pod` block parses fine. `=for` paragraph
blocks fail the same way — and the grammar declares `pod-paragraph-line` and
`pod-abbreviated-block-line` tokens that `TOP` never reaches.

Since every failure mode is a silent `Nil`, check the match before touching
`$/<pod>`:

```raku name="guard"
use Pod::Literate;

my $awkward = "=head1 NAME\n\nmy \$x = 1;\n";
with Pod::Literate.parse($awkward) -> $m {
    say 'parsed, pod chunks: ', $m<pod>.elems;
}
else {
    say 'did not parse — check for abbreviated pod or a missing trailing newline';
}
```

```output
did not parse — check for abbreviated pod or a missing trailing newline
```

## Where the two engines differ

Nowhere. Every spike in this page behaved identically on Raku++ and Rakudo,
which makes this the most portable of the Pod-handling distributions in the
handbook.

One more failure mode, for the same reason as the others: a file whose last
line has **no trailing newline** returns `Nil` too, because both `pod` and
`code` require a terminating `\n`. Append one before parsing if the source
might have been trimmed.
