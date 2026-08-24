#!/usr/bin/env rakupp
# XML — Building a document
# https://raku.online/ecosystem/xml/#building-a-document
#
# Install what it needs, then run it:
#     rakupp install XML
#     rakupp 03-build.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use XML;

my $item = XML::Element.new(name => 'item');
$item.set('sku', 'A-17');
$item.append(XML::Text.new(text => 'Widget'));
say ~$item;

my $doc = XML::Document.new(XML::Element.new(name => 'order'));
$doc.root.append($item);
say ~$doc;

# Output:
#     <item sku="A-17">Widget</item>
#     <?xml version="1.0"?><order><item sku="A-17">Widget</item></order>
