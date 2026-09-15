---
name: XML::Query
version: 1.1
auth: zef:raku-community-modules
kind: Distribution · XML
summary: CSS-shaped selectors over an XML::Document — where `.class` is an
  exact attribute match, so a multi-class element never matches.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: XML
raku-land: https://raku.land/zef:raku-community-modules/XML::Query
source: https://github.com/raku-community-modules/XML-Query.git
---

## What it is for

Walking an `XML::Document` by hand is tedious; a selector language is not. This
distribution wraps a document in a callable object so that `$xq('div p')`
returns the matching elements — tag name, `#id`, `.class`, `[attr="value"]`,
descendant, direct child and union.

## Selecting

```raku name="basics"
use XML;
use XML::Query;

my $doc = from-xml(q:to/END/);
<html>
  <body id="top">
    <div id="header"><a href="one.html">one</a><a href="two.html">two</a></div>
    <div><p class="decr">A</p><p>B</p></div>
    <div><input type="radio"/><input type="radio"/><input type="text"/></div>
  </body>
</html>
END

my $xq = XML::Query.new($doc);
for 'a', '.decr', '#header', 'input[type=radio]', 'a,p', 'div p', 'body > div' -> $sel {
    say sprintf('  %-20s -> %d', $sel.raku, $xq($sel).elements.elems);
}
say '';
say 'reading a node is two hops — .first, .last and [$i] all return a';
say 'Results, not an element:';
say '  $xq("a").first.element : ', $xq('a').first.element.Str;
say '  $xq("a")[1]            : ', $xq('a')[1].element.Str;
say '  $xq("a").element       : ', $xq('a').element.Str;
```

```output
  "a"                  -> 2
  ".decr"              -> 1
  "#header"            -> 1
  "input[type=radio]"  -> 2
  "a,p"                -> 4
  "div p"              -> 2
  "body > div"         -> 3

reading a node is two hops — .first, .last and [$i] all return a
Results, not an element:
  $xq("a").first.element : <a href="one.html">one</a>
  $xq("a")[1]            : <a href="two.html">two</a>
  $xq("a").element       : <a href="one.html">one</a>
```

## The one thing to know

`.class` is an exact attribute match, so it does not match an element with
more than one class — and there is no selector that will.

```raku name="multiclass"
use XML;
use XML::Query;

my $doc = from-xml(
    '<html><body><p class="decr">A</p><p class="decr big">B</p>' ~
    '<p class="big decr">C</p></body></html>');
my $xq = XML::Query.new($doc);

for '.decr', '.big', '[class="decr big"]' -> $sel {
    my @e = $xq($sel).elements;
    say sprintf('  %-22s -> %d  %s', $sel.raku, @e.elems,
                @e.map({ .nodes[0].Str }).join(' '));
}
say '';
say 'two failures compound. `.decr` becomes elements(class => "decr"),';
say 'which compares the whole attribute string. And the escape hatch is';
say 'closed too: the statement is split on whitespace BEFORE anything is';
say 'interpreted, so [class="decr big"] is torn into two fragments and';
say 'matches nothing.';
say '';
say 'no attribute value containing a space is reachable through this';
say 'selector language. On real HTML, where multi-class elements are the';
say 'norm, .class quietly returns the wrong subset.';
say '';
say 'select by tag and filter yourself:';
my @big = $xq('p').elements.grep({ (.attribs<class> // '').words.grep('big') });
say '  p elements whose class list contains "big" : ', @big.elems;
```

```output
  ".decr"                -> 1  A
  ".big"                 -> 0  
  "[class=\"decr big\"]" -> 0  

two failures compound. `.decr` becomes elements(class => "decr"),
which compares the whole attribute string. And the escape hatch is
closed too: the statement is split on whitespace BEFORE anything is
interpreted, so [class="decr big"] is torn into two fragments and
matches nothing.

no attribute value containing a space is reachable through this
selector language. On real HTML, where multi-class elements are the
norm, .class quietly returns the wrong subset.

select by tag and filter yourself:
  p elements whose class list contains "big" : 2
```

## `.elems` does not return a count

```raku name="elems"
use XML;
use XML::Query;

my $doc = from-xml('<html><body><a href="one.html">one</a><a href="two.html">two</a></body></html>');
my $xq = XML::Query.new($doc);
my $r = $xq('a');

say '.elements : ', $r.elements.WHAT.^name, ' of ', $r.elements.elems;
say '.elems    : ', $r.elems.WHAT.^name, '   <- the DEPRECATED alias for .elements';
say '';
say 'it happens to look right when you write $r.elems.elems, but';
say '`say $r.elems` prints the markup. Likewise .elem is .element.';
say '';
say 'Rakudo prints a deprecation report at exit; Raku++ prints nothing,';
say 'so on Raku++ there is no signal at all.';
say '';
say 'count with .elements.elems.';
```

```output
.elements : Array of 2
.elems    : Array   <- the DEPRECATED alias for .elements

it happens to look right when you write $r.elems.elems, but
`say $r.elems` prints the markup. Likewise .elem is .element.

Rakudo prints a deprecation report at exit; Raku++ prints nothing,
so on Raku++ there is no signal at all.

count with .elements.elems.
```

## Two more shapes

```raku name="shapes"
use XML;
use XML::Query;

my $doc = from-xml('<html><body><div><p>A</p></div><p>B</p></body></html>');
my $xq = XML::Query.new($doc);

say 'CALL-ME joins with "," (union); AT-KEY joins with " " (descendant):';
say '  $xq("div", "p")  is a union   — but see below';
say '  $xq<div p>       is a hash SLICE and returns a List of two Results';
say '';
say 'so use one selector string per call:';
say '  $xq("div, p").elements.elems : ', $xq('div, p').elements.elems;
say '  $xq("div p").elements.elems  : ', $xq('div p').elements.elems;
say '';
say 'Results has NO jQuery-style filter methods — no filter, children,';
say 'attr, text, next or add. .find re-queries from the current set:';
say '  $xq("div").find("p").elements.elems : ', $xq('div').find('p').elements.elems;
say '';
say 'and never call .raku or .gist on anything from this module —';
say 'XML::Element carries a parent back-reference and .raku recurses.';
```

```output
CALL-ME joins with "," (union); AT-KEY joins with " " (descendant):
  $xq("div", "p")  is a union   — but see below
  $xq<div p>       is a hash SLICE and returns a List of two Results

so use one selector string per call:
  $xq("div, p").elements.elems : 3
  $xq("div p").elements.elems  : 1

Results has NO jQuery-style filter methods — no filter, children,
attr, text, next or add. .find re-queries from the current set:
  $xq("div").find("p").elements.elems : 1

and never call .raku or .gist on anything from this module —
XML::Element carries a parent back-reference and .raku recurses.
```

## Where the two engines differ

Extra selector arguments are silently dropped under Raku++: `$xq('a', 'p')`
throws `Too many positionals passed` on Rakudo and returns just the `a`
matches on Raku++. Everything else — the selectors, the results, the
`.class` limitation — is identical.

```raku name="portable"
use XML;
use XML::Query;

my $doc = from-xml('<html><body><a href="one.html">one</a><p>two</p></body></html>');
my $xq = XML::Query.new($doc);

say 'one string per call, always:';
say '  $xq("a, p").elements.elems : ', $xq('a, p').elements.elems;
say '';
say 'and the statement parser has a dead branch worth knowing about: the';
say 'two-element case reads $spec[2], which is always out of range. It is';
say 'never reached by the shapes above.';
say '';
say 'a small helper that gives you elements directly:';
sub sel($xq, Str $s) { $xq($s).elements }
say '  sel($xq, "a").map(*.attribs<href>) : ',
    sel($xq, 'a').map({ .attribs<href> }).join(' ');
```

```output
one string per call, always:
  $xq("a, p").elements.elems : 2

and the statement parser has a dead branch worth knowing about: the
two-element case reads $spec[2], which is always out of range. It is
never reached by the shapes above.

a small helper that gives you elements directly:
  sel($xq, "a").map(*.attribs<href>) : one.html
```
