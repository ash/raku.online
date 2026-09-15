---
name: HTML::Parser
version: 0.1.1
auth: zef:tony-o
kind: Distribution · interfaces
summary: Six lines: a role declaring one attribute and one stubbed method —
  an interface for somebody else's parser, not a parser.
status: full
suite: no test files, so trivially green
tested: 2026-09-15
license: none stated
depends: XML
raku-land: https://raku.land/zef:tony-o/HTML::Parser
source: git://github.com/tony-o/perl6-html-parser.git
---

## What it is for

If several HTML parsers exist, code that consumes one should not have to care
which. A role that declares "this thing turns a `Str` into an
`XML::Document`" is the contract that makes them interchangeable.

That is what this distribution is — and it is important to be clear that it
contains no parser. The whole executable content is six lines.

## The whole declaration

```raku name="declaration"
use HTML::Parser;

say 'HTML::Parser is a : ', HTML::Parser.HOW.^name;
say '';
say 'it declares:';
say '  has XML::Document $.xmldoc;';
say '  method parse(Str $html) returns XML::Document {*}';
say '';
say 'and that is all. No `is export`, no constructor help, no other unit.';
```

```output
HTML::Parser is a : Perl6::Metamodel::ParametricRoleGroupHOW

it declares:
  has XML::Document $.xmldoc;
  method parse(Str $html) returns XML::Document {*}

and that is all. No `is export`, no constructor help, no other unit.
```

## Using it as it is meant

```raku name="compose"
use HTML::Parser;
use XML;

class SimpleParser does HTML::Parser {
    method parse(Str $html) returns XML::Document {
        $!xmldoc = from-xml($html);
    }
}

my $p = SimpleParser.new;
say 'before parse : ', $p.xmldoc.defined;
my $doc = $p.parse('<html><body><p class="a">hi</p><p>there</p></body></html>');
say 'doc type     : ', $doc.WHAT.^name;
say 'root         : ', $doc.root.name;
say 'p texts      : ', $doc.root.elements(:TAG<p>, :RECURSE).map({ .nodes[0].Str }).join('|');
say 'class attr   : ', $doc.root.elements(:TAG<p>, :RECURSE)[0].attribs<class>;
say 'stored       : ', $p.xmldoc.defined;
say 'does the role: ', ($p ~~ HTML::Parser);
```

```output
before parse : False
doc type     : XML::Document
root         : html
p texts      : hi|there
class attr   : a
stored       : True
does the role: True
```

Note two things. The class must write `$!xmldoc` — the attribute the role
already composed in; **re-declaring it in the class is a compile error** on
both engines. And do not name your class `Real`: under Raku++ a user class
whose name collides with a core *role* gets the core role's `new`, so
`Real.new` hands you a `Num`.

## The one thing to know

Calling `parse` on a class that composes the role but does not implement it
throws a *return type-check* error, because `{*}` evaluates to `*`.

```raku name="stub"
use HTML::Parser;

class Naive does HTML::Parser { }

say 'the role composes fine : ', (Naive.new ~~ HTML::Parser);
say 'xmldoc on a fresh one  : ', Naive.new.xmldoc.defined;
my $r = try Naive.new.parse('<p>hi</p>');
say 'calling parse          : ', $! ?? 'threw ' ~ $!.^name !! 'returned';
say '';
say 'the message names Whatever and mentions nothing about the method';
say 'being unimplemented — "Type check failed for return value; expected';
say 'XML::Document but got Whatever (*)".';
say '';
say 'a role stub that is meant to be required should be written  { ... }';
say 'rather than  {*}  — the yada form makes the engine enforce it at';
say 'composition time, with a message that names the method.';
```

```output
the role composes fine : True
xmldoc on a fresh one  : False
calling parse          : threw X::TypeCheck::Return

the message names Whatever and mentions nothing about the method
being unimplemented — "Type check failed for return value; expected
XML::Document but got Whatever (*)".

a role stub that is meant to be required should be written  { ... }
rather than  {*}  — the yada form makes the engine enforce it at
composition time, with a message that names the method.
```

## The contract is stricter than HTML

```raku name="strict"
use HTML::Parser;
use XML;

class SimpleParser does HTML::Parser {
    method parse(Str $html) returns XML::Document { $!xmldoc = from-xml($html) }
}

say 'the declared return type is XML::Document, and XML is a STRICT XML';
say 'parser — so real-world HTML cannot satisfy the interface at all:';
for '<p>well formed</p>', '<br>', '<p>unclosed' -> $html {
    my $r = try SimpleParser.new.parse($html);
    say sprintf('  %-22s -> %s', $html.raku, $! ?? 'could not parse' !! 'ok');
}
say '';
say 'an implementation that really handled HTML would have to build the';
say 'XML::Document itself rather than delegating to from-xml — which is';
say 'presumably why nothing in the ecosystem composes this role.';
```

```output
the declared return type is XML::Document, and XML is a STRICT XML
parser — so real-world HTML cannot satisfy the interface at all:
  "<p>well formed</p>"   -> ok
  "<br>"                 -> could not parse
  "<p>unclosed"          -> could not parse

an implementation that really handled HTML would have to build the
XML::Document itself rather than delegating to from-xml — which is
presumably why nothing in the ecosystem composes this role.
```

## Where the two engines differ

Nothing behavioural: the composition, the attribute conflict and the stub
failure are the same. Only reflection on a parametric role group differs —
Raku++ lists `parse` and `xmldoc` with a full signature, Rakudo lists `parse`
with `(|)`.

```raku name="portable"
use HTML::Parser;

say 'so if you are designing an interface role, two things this one shows:';
say '';
say '  1. write  { ... }  for a required method, not  {*}  — the yada';
say '     form is enforced at composition and names the method;';
say '';
say '  2. do not declare the implementation`s state in the interface.';
say '     `has XML::Document $.xmldoc` means every implementor inherits';
say '     a slot it may not want, and re-declaring it is a compile error:';
say '';
say '       class SimpleParser does HTML::Parser {';
say '           has XML::Document $.xmldoc;   # conflicts';
say '       }';
say '';
say '  the role`s own attribute is writable from the class, which is what';
say '  the working example on this page does.';
```

```output
so if you are designing an interface role, two things this one shows:

  1. write  { ... }  for a required method, not  {*}  — the yada
     form is enforced at composition and names the method;

  2. do not declare the implementation`s state in the interface.
     `has XML::Document $.xmldoc` means every implementor inherits
     a slot it may not want, and re-declaring it is a compile error:

       class SimpleParser does HTML::Parser {
           has XML::Document $.xmldoc;   # conflicts
       }

  the role`s own attribute is writable from the class, which is what
  the working example on this page does.
```
