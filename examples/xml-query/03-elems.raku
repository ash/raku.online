#!/usr/bin/env rakupp
# XML::Query — `.elems` does not return a count
# https://raku.online/modules/xml-query/#elems-does-not-return-a-count
#
# Install what it needs, then run it:
#     rakupp install XML::Query
#     rakupp 03-elems.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     .elements : Array of 2
#     .elems    : Array   <- the DEPRECATED alias for .elements
#     
#     it happens to look right when you write $r.elems.elems, but
#     `say $r.elems` prints the markup. Likewise .elem is .element.
#     
#     Rakudo prints a deprecation report at exit; Raku++ prints nothing,
#     so on Raku++ there is no signal at all.
#     
#     count with .elements.elems.
