#!/usr/bin/env rakupp
# HTML::Parser — The contract is stricter than HTML
# https://raku.online/modules/html-parser/#the-contract-is-stricter-than-html
#
# Install what it needs, then run it:
#     rakupp install HTML::Parser
#     rakupp 04-strict.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTML::Parser;
use XML;

class SimpleParser does HTML::Parser {
    method parse(Str $html) returns XML::Document { $!xmldoc = from-xml($html) }
}

say 'the declared return type is XML::Document, and XML is a STRICT XML';
say 'parser — so real-world HTML cannot satisfy the interface at all:';
for '<p>well formed</p>', '<br>', '<p>unclosed' -> $html {
    my $r = try SimpleParser.new.parse($html);
    say sprintf('  %-22s -> %s', $html.raku, $! ?? 'could not parse' !! 'ok');
}
say '';
say 'an implementation that really handled HTML would have to build the';
say 'XML::Document itself rather than delegating to from-xml — which is';
say 'presumably why nothing in the ecosystem composes this role.';

# Output:
#     the declared return type is XML::Document, and XML is a STRICT XML
#     parser — so real-world HTML cannot satisfy the interface at all:
#       "<p>well formed</p>"   -> ok
#       "<br>"                 -> could not parse
#       "<p>unclosed"          -> could not parse
#     
#     an implementation that really handled HTML would have to build the
#     XML::Document itself rather than delegating to from-xml — which is
#     presumably why nothing in the ecosystem composes this role.
