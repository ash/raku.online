#!/usr/bin/env rakupp
# XML::Entity::HTML — Encoding and decoding
# https://raku.online/modules/xml-entity-html/#encoding-and-decoding
#
# Install what it needs, then run it:
#     rakupp install XML::Entity::HTML
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use XML::Entity::HTML;

my $src = "Text with <entities> & \c[LEFT-POINTING DOUBLE ANGLE QUOTATION MARK]more\c[RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK]";
my $enc = encode-html-entities($src);
say 'source  : ', $src;
say 'encoded : ', $enc;
say 'decoded : ', decode-html-entities($enc);
say 'round trips : ', decode-html-entities($enc) eq $src;
say '';
say 'the table holds ', XML::Entity::HTML.entityNames.elems, ' names.';
say '';
say 'numeric references decode too, and can be turned off:';
for '&#65;', '&#x41;', '&#8212;', '&#x1F600;' -> $e {
    say sprintf('  %-12s -> %s', $e, decode-html-entities($e));
}
say '  :!numeric leaves them : ', decode-html-entities('&#65;', :!numeric);

# Output:
#     source  : Text with <entities> & «more»
#     encoded : Text with &lt;entities&gt; &amp; &laquo;more&raquo;
#     decoded : Text with <entities> & «more»
#     round trips : True
#     
#     the table holds 2119 names.
#     
#     numeric references decode too, and can be turned off:
#       &#65;        -> A
#       &#x41;       -> A
#       &#8212;      -> —
#       &#x1F600;    -> 😀
#       :!numeric leaves them : &#65;
