#!/usr/bin/env rakupp
# XML — Finding things
# https://raku.online/modules/xml/#finding-things
#
# Install what it needs, then run it:
#     rakupp install XML
#     rakupp 02-navigate.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use XML;

my $doc = from-xml('<a><b x="1"><c>deep</c></b><b x="2"/></a>');
say $doc.root.nodes.elems;
say $doc.root[0].name;
say $doc.root[0]<x>;
say $doc.root.elements(:TAG<b>, :x<2>).elems;
say $doc.root.lookfor(:TAG<c>).map(*.contents.join).join(',');

# Output:
#     2
#     b
#     1
#     1
#     deep
