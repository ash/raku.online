#!/usr/bin/env rakupp
# XML::Query — Two more shapes
# https://raku.online/modules/xml-query/#two-more-shapes
#
# Install what it needs, then run it:
#     rakupp install XML::Query
#     rakupp 04-shapes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     CALL-ME joins with "," (union); AT-KEY joins with " " (descendant):
#       $xq("div", "p")  is a union   — but see below
#       $xq<div p>       is a hash SLICE and returns a List of two Results
#     
#     so use one selector string per call:
#       $xq("div, p").elements.elems : 3
#       $xq("div p").elements.elems  : 1
#     
#     Results has NO jQuery-style filter methods — no filter, children,
#     attr, text, next or add. .find re-queries from the current set:
#       $xq("div").find("p").elements.elems : 1
#     
#     and never call .raku or .gist on anything from this module —
#     XML::Element carries a parent back-reference and .raku recurses.
