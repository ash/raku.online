---
name: XML
version: 0.3.6
auth: zef:raku-community-modules
kind: Distribution · data format
summary: Parse an XML document into a tree you can walk, and build one node by
  node — with one sharp edge to know about before you write any output.
status: full
license: Artistic-2.0
suite: 15 files, green
tested: 2026-08-28
raku-land: https://raku.land/zef:raku-community-modules/XML
source: https://github.com/raku-community-modules/XML
---

## What it is for

Something upstream still speaks XML — an RSS feed, a SOAP endpoint, an Office
document, a `.plist`, half the configuration formats written before 2010. This
module parses it into a tree of `XML::Element` and `XML::Text` nodes, and lets
you build one the same way:

```raku name="tour"
use XML;

my $doc = from-xml(q:to/XML/);
    <catalog>
      <book id="1"><title>Learning Raku</title><price>39.99</price></book>
      <book id="2"><title>Raku Recipes</title><price>44.50</price></book>
    </catalog>
    XML

say $doc.root.name;
say $doc.elements(:TAG<book>).elems;
for $doc.elements(:TAG<book>) -> $b {
    say $b.attribs<id>, ': ', $b.elements(:TAG<title>, :SINGLE).contents.join;
}
```

```output
catalog
2
1: Learning Raku
2: Raku Recipes
```

`from-xml` takes a string. Its neighbours are `from-xml-file` for a path and
`from-xml-stream` for a handle.

## Finding things

`elements` is the workhorse. It looks at the **direct children** of a node and
filters them: `:TAG<name>` by element name, any other named pair by attribute
value, and `:SINGLE` to get one node back instead of a list.

```raku name="navigate"
use XML;

my $doc = from-xml('<a><b x="1"><c>deep</c></b><b x="2"/></a>');
say $doc.root.nodes.elems;
say $doc.root[0].name;
say $doc.root[0]<x>;
say $doc.root.elements(:TAG<b>, :x<2>).elems;
say $doc.root.lookfor(:TAG<c>).map(*.contents.join).join(',');
```

```output
2
b
1
1
deep
```

Three shorthands are worth learning because they shorten nearly every walk:
`$node[0]` is the first child, `$node<attr>` is an attribute, and `lookfor`
searches the whole subtree rather than only the direct children — that last one
is the difference between `elements` and finding something nested at unknown
depth.

## Building a document

Nodes are constructed and appended. `set` writes an attribute; `append` adds a
child:

```raku name="build"
use XML;

my $item = XML::Element.new(name => 'item');
$item.set('sku', 'A-17');
$item.append(XML::Text.new(text => 'Widget'));
say ~$item;

my $doc = XML::Document.new(XML::Element.new(name => 'order'));
$doc.root.append($item);
say ~$doc;
```

```output
<item sku="A-17">Widget</item>
<?xml version="1.0"?><order><item sku="A-17">Widget</item></order>
```

Stringifying an `XML::Document` adds the declaration; stringifying an element
gives you just that element.

## The sharp edge: nothing is escaped for you

`XML::Text` stores text **verbatim** and writes it back verbatim. So does
`set`. Put an ampersand or an angle bracket into either and the document you
produce is not valid XML — and this module will not read it back:

```raku fragment
$e.set('title', 'Tom & Jerry');
$e.append(XML::Text.new(text => '5 < 6'));
say ~$e;              # <note title="Tom & Jerry">5 < 6</note>
from-xml(~$e);        # dies: could not parse XML
```

That is by design — the module treats the `text` attribute as the document's
own bytes, entities included — but it means **escaping on the way in is your
job**. Four substitutions cover it:

```raku name="escaping"
use XML;

sub xml-escape(Str $s) {
    $s.subst('&', '&amp;', :g)
      .subst('<', '&lt;',  :g)
      .subst('>', '&gt;',  :g)
      .subst('"', '&quot;', :g)
}

my $e = XML::Element.new(name => 'note');
$e.set('title', xml-escape('Tom & Jerry <"quoted">'));
$e.append(XML::Text.new(text => xml-escape('5 < 6 & 7 > 6')));
say ~$e;

my $back = from-xml(~$e);
say $back.root.attribs<title>;
say $back.root.nodes[0].string;
```

```output
<note title="Tom &amp; Jerry &lt;&quot;quoted&quot;&gt;">5 &lt; 6 &amp; 7 &gt; 6</note>
Tom &amp; Jerry &lt;&quot;quoted&quot;&gt;
5 < 6 & 7 > 6
```

Reading has the same asymmetry, and the last two lines show it. `.attribs` and
`.contents` give you the **raw** text with entities still in it; `.string` on a
text node decodes them. Use `.string` when you want the value a human meant,
and `.contents` when you want the document's own bytes.

## Where the two engines differ

Nothing on this page. Every example prints the same bytes under Raku++ and
under Rakudo, twice on each — the escaping behaviour above included: the
unescaped document fails to re-parse on both engines, and the escaped one
round-trips on both.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install XML`, no dependencies to pull.
3. **Test** — the distribution's own suite: 15 files, green.
4. **Run** — every example on this page, twice under each engine, as the site
   is built.

XML was one of the nine distributions the campaign's first wide measurement
found outright broken: `from-xml("<a><b>hi</b></a>").root.name` answered
`'a a'` instead of `'a'`. Three general fixes closed it, and the first is the
one worth reading.

**`$<name>` in match position is a backreference, not a capture.** XML's
close-tag rule is `'</' $<name> '>'` — match the same text the open tag
captured. Raku++ was consuming only the `$` and then re-parsing `<name>` as a
*fresh* named capture, so every tag name was captured twice and the root's name
came back doubled. That is a regex-engine fix, not an XML one, and it applies
to every grammar in the language.

The other two were parser gaps the module happened to reach: `::(EXPR)` as a
**parameter** constraint — `method reparent(::(q<XML::Element>) $parent)` — was
accepted in expression position but not in a signature; and a coercion-type
attribute, `has IO::Path() $.filename`, was rejected outright with "Attribute
$!filename not declared".
