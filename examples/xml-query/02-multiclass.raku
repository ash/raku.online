#!/usr/bin/env rakupp
# XML::Query — The one thing to know
# https://raku.online/modules/xml-query/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install XML::Query
#     rakupp 02-multiclass.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#       ".decr"                -> 1  A
#       ".big"                 -> 0  
#       "[class=\"decr big\"]" -> 0  
#     
#     two failures compound. `.decr` becomes elements(class => "decr"),
#     which compares the whole attribute string. And the escape hatch is
#     closed too: the statement is split on whitespace BEFORE anything is
#     interpreted, so [class="decr big"] is torn into two fragments and
#     matches nothing.
#     
#     no attribute value containing a space is reachable through this
#     selector language. On real HTML, where multi-class elements are the
#     norm, .class quietly returns the wrong subset.
#     
#     select by tag and filter yourself:
#       p elements whose class list contains "big" : 2
