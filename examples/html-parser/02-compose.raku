#!/usr/bin/env rakupp
# HTML::Parser — Using it as it is meant
# https://raku.online/modules/html-parser/#using-it-as-it-is-meant
#
# Install what it needs, then run it:
#     rakupp install HTML::Parser
#     rakupp 02-compose.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTML::Parser;
use XML;

class SimpleParser does HTML::Parser {
    method parse(Str $html) returns XML::Document {
        $!xmldoc = from-xml($html);
    }
}

my $p = SimpleParser.new;
say 'before parse : ', $p.xmldoc.defined;
my $doc = $p.parse('<html><body><p class="a">hi</p><p>there</p></body></html>');
say 'doc type     : ', $doc.WHAT.^name;
say 'root         : ', $doc.root.name;
say 'p texts      : ', $doc.root.elements(:TAG<p>, :RECURSE).map({ .nodes[0].Str }).join('|');
say 'class attr   : ', $doc.root.elements(:TAG<p>, :RECURSE)[0].attribs<class>;
say 'stored       : ', $p.xmldoc.defined;
say 'does the role: ', ($p ~~ HTML::Parser);

# Output:
#     before parse : False
#     doc type     : XML::Document
#     root         : html
#     p texts      : hi|there
#     class attr   : a
#     stored       : True
#     does the role: True
