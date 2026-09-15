---
name: XML::Writer
version: *
auth: none stated
kind: Distribution · markup
summary: Serialise a nested Raku data structure into XML, where a Pair with a
  Positional value is an element and one without is an attribute.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/?/XML::Writer
source: git://github.com/masak/xml-writer.git
---

## What it is for

Building XML by string concatenation gets the escaping wrong eventually.
Building it through a DOM is more machinery than a small document needs. The
middle path is to describe the tree as ordinary Raku data and let something
else turn it into text.

This distribution is that: a tree of `Pair`s in, a string of XML out, with the
escaping handled.

## Writing a document

```raku name="serialise"
use XML::Writer;

say XML::Writer.serialize(:html[
    :head[ :title[ 'Report' ] ],
    :body[ :h1[ 'Totals' ], :p[ 'Rows: 3' ] ],
]);
```

```output
<html><head><title>Report</title></head><body><h1>Totals</h1><p>Rows: 3</p></body>
</html>
```

The rule is one line long: a `Pair` whose value is `Positional` is an
**element**, a `Pair` whose value is not is an **attribute**, and a bare `Str`
or number is a text node.

## Attributes and empty elements

```raku name="attributes"
use XML::Writer;

say XML::Writer.serialize(:a[ :href<http://example.invalid/>, :class<lnk>, 'click' ]);
say XML::Writer.serialize(:br[]);
say XML::Writer.serialize(:n[ 42 ]);
say XML::Writer.serialize(:img[ :src<a.png>, :alt<A> ]);
```

```output
<a href="http://example.invalid/" class="lnk">click</a>
<br />
<n>42</n>
<img src="a.png" alt="A" />
```

An element with no children renders as a self-closing tag.

## Escaping

```raku name="escaping"
use XML::Writer;

say XML::Writer.serialize(:p[ '<script>a&b"c"</script>' ]);
say XML::Writer.serialize(:a[ :title('" onmouseover=x "'), 'hi' ]);
```

```output
<p>&lt;script&gt;a&amp;b&quot;c&quot;&lt;/script&gt;</p>
<a title="&quot; onmouseover=x &quot;">hi</a>
```

`<`, `>`, `"` and `&` are escaped in **both** text nodes and attribute values,
which is the part most hand-rolled serialisers get half right. The quoted
attack string in the second line comes back inert.

It does not escape `'`, which is safe only because the writer always emits
double quotes. If you post-process the output into single-quoted attributes,
you have reintroduced the hole.

## What it refuses

```raku name="refuses"
use XML::Writer;

sub attempt($label, &c) {
    my $r = try c();
    say sprintf('%-30s %s', $label, $! ?? $!.message !! $r.raku);
}

attempt 'no argument',          { XML::Writer.serialize() };
attempt 'two root elements',    { XML::Writer.serialize(:a[1], :b[2]) };
attempt 'a bare string',        { XML::Writer.serialize('plain') };
attempt 'one root element',     { XML::Writer.serialize(:a[1]) };
```

```output
no argument                    Please pass exactly one argument to XML::Writer.serialize
two root elements              Please pass exactly one argument to XML::Writer.serialize
a bare string                  The XML tree must have a single root node
one root element               "<a>1</a>"
```

Exactly one argument, and it must be an element. The two failure messages
distinguish "no root" from "not an element", which is more than most
serialisers bother with.

## The one thing to know

The serialiser injects newlines into the markup, at positions determined
purely by character count — including inside whitespace-significant elements.

```raku name="newline-trap"
use XML::Writer;

my $out = XML::Writer.serialize(:pre[ (1..10).map({ 'span' => ["chunk$_"] }) ]);
say 'newlines inside the <pre> : ', $out.comb("\n").elems - 1;
say '';
say $out.subst("\n", '\n' ~ "\n", :g);
```

```output
newlines inside the <pre> : 2

<pre><span>chunk1</span><span>chunk2</span><span>chunk3</span><span>chunk4</span>\n
<span>chunk5</span><span>chunk6</span><span>chunk7</span><span>chunk8</span>\n
<span>chunk9</span><span>chunk10</span></pre>\n
```

The walker appends a newline whenever the accumulated output has grown more
than seventy characters since the last one. In XML that is legal but not
neutral: inside `<pre>`, or any element carrying `xml:space="preserve"`, it
changes the content.

It also makes the output non-deterministic with respect to **element name
length** — rename a tag and the line breaks move, so byte-comparing two
serialisations of the same tree is not a safe test.

Strip the newlines if the document has whitespace-significant elements in it.

## Where the two engines differ

Nowhere. Every document, every escape and every rejection in this page was
byte-identical on Raku++ and Rakudo.

The distribution declares **no version at all** in its metadata — the field is
literally `*` — so it cannot be depended on with a version range and the
installers cannot order upgrades against it. It declares no `auth` either.
