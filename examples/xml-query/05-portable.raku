#!/usr/bin/env rakupp
# XML::Query — Where the two engines differ
# https://raku.online/modules/xml-query/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install XML::Query
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     one string per call, always:
#       $xq("a, p").elements.elems : 2
#     
#     and the statement parser has a dead branch worth knowing about: the
#     two-element case reads $spec[2], which is always out of range. It is
#     never reached by the shapes above.
#     
#     a small helper that gives you elements directly:
#       sel($xq, "a").map(*.attribs<href>) : one.html
