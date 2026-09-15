#!/usr/bin/env rakupp
# XML::Entity::HTML — Where the two engines differ
# https://raku.online/modules/xml-entity-html/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install XML::Entity::HTML
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use XML::Entity::HTML;

say 'so: do not call .add. If you need extra entities, decode with the';
say 'module and then handle your own:';
my %mine = 'nbsp-visible;' => "\c[MIDDLE DOT]";
sub decode-plus(Str $s) {
    my $r = decode-html-entities($s);
    $r.subst(/ '&' (<-[;]>+ ';') /, { %mine{$0.Str} // "&$0" }, :g)
}
say '  decode-plus("&amp; &nbsp-visible;") = ', decode-plus('&amp; &nbsp-visible;');
say '';
say 'one more edge, shared but sharper on Rakudo: a lone surrogate';
say 'decodes to a one-character string on both engines, and PRINTING it';
say 'kills the process on Rakudo — it cannot encode a lone surrogate.';
say 'The throw happens at output time, so a try around decode-html-entities';
say 'will not catch it. Reject &#xD800;..&#xDFFF; before decoding.';

# Output:
#     so: do not call .add. If you need extra entities, decode with the
#     module and then handle your own:
#       decode-plus("&amp; &nbsp-visible;") = & &nbsp-visible;
#     
#     one more edge, shared but sharper on Rakudo: a lone surrogate
#     decodes to a one-character string on both engines, and PRINTING it
#     kills the process on Rakudo — it cannot encode a lone surrogate.
#     The throw happens at output time, so a try around decode-html-entities
#     will not catch it. Reject &#xD800;..&#xDFFF; before decoding.
