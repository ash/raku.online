#!/usr/bin/env rakupp
# XML — What it is for
# https://raku.online/ecosystem/xml/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install XML
#     rakupp 01-tour.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     catalog
#     2
#     1: Learning Raku
#     2: Raku Recipes
