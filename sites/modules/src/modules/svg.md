---
name: SVG
version: 1.0
auth: github:moritz
kind: Distribution · graphics
summary: SVG written as nested pairs and serialised to the XML — the
  drawing described as data, so a program that computes a chart or a
  diagram produces the file without writing angle brackets.
status: full
suite: 1 file, green
tested: 2026-09-14
depends: XML::Writer
raku-land: https://raku.land/github:moritz/SVG
source: https://github.com/moritz/svg
---

## What it is for

A chart, a diagram, a generated icon: a drawing that a program computes is
a tree of elements with attributes, and SVG is that tree written as XML. The
XML is the tedious half. This distribution lets you write the tree as Raku
pairs — an element is `'rect' => [ :x(1), :y(2), … ]`, a pair with an
attribute list, and children are more pairs in that list — and turns it
into the markup with the SVG namespace declared. It is sixteen lines over
`XML::Writer`, and five distributions build their output on it, `SVG::Plot`
among them.

## A drawing as data

```raku name="serialize"
use SVG;

say SVG.serialize('svg' => [ :width(20), :height(10),
    'rect' => [ :x(1), :y(2), :width(8), :height(6) ],
    'text' => [ :x(2), :y(9), 'hi' ] ]);
say SVG.serialize('circle' => [ :cx(5), :cy(5), :r(4) ], :!preamble);
```

```output
<svg xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="20" height="10"><rect x="1" y="2" width="8" height="6" /><text x="2" y="9">hi</text></svg>

<circle cx="5" cy="5" r="4" />
```

A pair whose value is a list is an element: pairs inside the list are its
attributes, further element-pairs are its children, and a bare string is
its text. The root gets the three namespace declarations unless
`:!preamble` says otherwise, which is what you want for a fragment that is
going to be pasted inside a larger document.

## The one thing to know

Write the attributes as a **list**, never as a hash. `[ :x(1), :y(2) ]` is
an Array of pairs and keeps its order; `{ :x(1), :y(2) }` is a Hash, and
under Rakudo a hash's order is randomised per process, so the same drawing
would serialise with its attributes shuffled from one run to the next. The
SVG is equivalent either way — an XML parser does not care — but a file
that changes on every run cannot be diffed, cached by hash or checked into
a repository sensibly. The list form is the idiom the module's author uses
and the one every example here uses.
