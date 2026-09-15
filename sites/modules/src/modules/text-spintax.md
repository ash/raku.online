---
name: Text::Spintax
version: 0.1
auth: zef:raku-community-modules
kind: Distribution · text generation
summary: Parse `{a|b|c}` alternation once, render as many random variants as
  you like — and any stray brace produces an undefined node, not an error.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Text::Spintax
source: https://github.com/raku-community-modules/Text-Spintax.git
---

## What it is for

"Spintax" is the template notation where `{this|that|the other}` means "pick
one". It comes from content generation and survives wherever you want many
plausible variants of one sentence — test fixtures, placeholder copy, a bot
that should not repeat itself.

This distribution parses such a template **once** into a tree, and then
renders it as often as you like, choosing afresh each time.

## Parsing once, rendering many

```raku name="basics"
use Text::Spintax;

my $tree = Text::Spintax.parse('This {is|was|will be} some {varied|random} text');
say 'the parse result : ', $tree.^name;
say '';
my @seen = (^200).map({ $tree.render }).unique.sort;
say 'distinct renders over 200 calls : ', @seen.elems;
for @seen -> $s { say '  ', $s }
say '';
say 'that is exactly the cross-product, 3 x 2 — so .render re-randomises';
say 'per call and one parse feeds unlimited output.';
```

```output
the parse result : Text::Spintax::SequenceNode

distinct renders over 200 calls : 6
  This is some random text
  This is some varied text
  This was some random text
  This was some varied text
  This will be some random text
  This will be some varied text

that is exactly the cross-product, 3 x 2 — so .render re-randomises
per call and one parse feeds unlimited output.
```

Groups nest:

```raku name="nesting"
use Text::Spintax;

my $tree = Text::Spintax.parse('{a{1|2}|b}');
say 'distinct : ', (^200).map({ $tree.render }).unique.sort.join(' ');
say '';
say 'an empty alternative is legal, and one of its outcomes is "":';
my $empty = Text::Spintax.parse('{a||b}');
say '  ', (^200).map({ $empty.render.raku }).unique.sort.join(' ');
say '';
say 'and so is an empty group:';
say '  {} renders as ', Text::Spintax.parse('{}').render.raku;
```

```output
distinct : a1 a2 b

an empty alternative is legal, and one of its outcomes is "":
  "" "a" "b"

and so is an empty group:
  {} renders as ""
```

## The node classes

```raku name="nodes"
use Text::Spintax;

say 'the tree is built from four classes, all with a no-argument .render:';
say '  SequenceNode  has @.children';
say '  TextNode      has $.text';
say '  SpinNode      has @.children';
say '  NullNode      declared, never constructed by the parser';
say '';
my $tree = Text::Spintax.parse('plain text');
say 'a template with no groups still comes back as a SequenceNode:';
say '  ', $tree.^name, ' -> ', $tree.render.raku;
say '';
say 'the grammar and actions are reachable by name too, as';
say 'Text::Spintax::Spintax and Text::Spintax::Spinaction.';
```

```output
the tree is built from four classes, all with a no-argument .render:
  SequenceNode  has @.children
  TextNode      has $.text
  SpinNode      has @.children
  NullNode      declared, never constructed by the parser

a template with no groups still comes back as a SequenceNode:
  Text::Spintax::SequenceNode -> "plain text"

the grammar and actions are reachable by name too, as
Text::Spintax::Spintax and Text::Spintax::Spinaction.
```

## The one thing to know

There is no escape for `{`, `}` or `|`. A string containing any of them
outside a well-formed group does not raise a parse error — it produces an
undefined node.

```raku name="unbalanced"
use Text::Spintax;

for 'a}b', '{a|b', 'the {b} case', 'C{ontent' -> $src {
    my $tree = try Text::Spintax.parse($src);
    say sprintf('  %-16s -> %s', $src.raku,
                ($tree.defined ?? 'a ' ~ $tree.^name !! 'no usable tree'));
}
say '';
say 'the grammar`s `token text` is <-[\\{\\}|]>+, so a stray brace or pipe';
say 'cannot be matched as text; the grammar fails, Grammar.parse returns';
say 'an undefined value, and the module calls .ast on it without checking.';
say '';
say 'check before you render:';
sub spin(Str $src) {
    my $tree = try Text::Spintax.parse($src);
    $tree.defined or die "unbalanced spintax: $src";
    $tree
}
for 'a {b|c} d', 'a}b' -> $src {
    my $t = try spin($src);
    say sprintf('  %-12s -> %s', $src.raku,
                $! ?? 'rejected' !! 'renders as ' ~ ($t.render.chars ~ ' characters'));
}
```

```output
  "a}b"            -> no usable tree
  "\{a|b"          -> no usable tree
  "the \{b} case"  -> a Text::Spintax::SequenceNode
  "C\{ontent"      -> no usable tree

the grammar`s `token text` is <-[\{\}|]>+, so a stray brace or pipe
cannot be matched as text; the grammar fails, Grammar.parse returns
an undefined value, and the module calls .ast on it without checking.

check before you render:
  "a \{b|c} d" -> renders as 5 characters
  "a}b"        -> rejected
```

`a}b` is an ordinary English-ish string — a JSON fragment, a shell brace, a
sentence that mentions `{b}`. This is the failure you will actually hit.

## Where the two engines differ

Exactly at that undefined node. Rakudo raises `No such method 'ast' for
invocant of type 'Any'` from inside `parse`, which is at least a signal;
Raku++ returns `Any` silently and lets the program carry on until something
later calls `.render` on it.

```raku name="portable"
use Text::Spintax;

# the guard above makes the two engines agree
sub spin(Str $src) {
    my $tree = try Text::Spintax.parse($src);
    return Nil unless $tree.defined;
    $tree
}
for 'a {b|c} d', 'a}b', '' -> $src {
    my $t = spin($src);
    say sprintf('  %-12s -> %s', $src.raku, $t.defined ?? 'parsed' !! 'rejected');
}
say '';
say 'two dead ends inside the grammar, for the curious: `rule chunk` is';
say 'never reached from TOP, and it references <opt>, which is not';
say 'declared anywhere. Rakudo would raise a method-not-found if anything';
say 'reached it; Raku++ fails the match silently, which is why nobody';
say 'noticed. Grammar introspection differs too — $g.^methods(:local)';
say 'lists all eleven rules on Rakudo and nothing on Raku++.';
```

```output
  "a \{b|c} d" -> parsed
  "a}b"        -> rejected
  ""           -> parsed

two dead ends inside the grammar, for the curious: `rule chunk` is
never reached from TOP, and it references <opt>, which is not
declared anywhere. Rakudo would raise a method-not-found if anything
reached it; Raku++ fails the match silently, which is why nobody
noticed. Grammar introspection differs too — $g.^methods(:local)
lists all eleven rules on Rakudo and nothing on Raku++.
```
