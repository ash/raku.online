#!/usr/bin/env rakupp
# XML::Entity::HTML — Encoding is not the inverse of decoding
# https://raku.online/modules/xml-entity-html/#encoding-is-not-the-inverse-of-decoding
#
# Install what it needs, then run it:
#     rakupp install XML::Entity::HTML
#     rakupp 04-inverse.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use XML::Entity::HTML;

say '436 of the 2119 names share a value, so the round trip is one-way:';
for '&AMP;', '&amp;' -> $e {
    say sprintf('  decode(%-8s) = %s   then encode -> %s',
                $e.raku, decode-html-entities($e).raku,
                encode-html-entities(decode-html-entities($e)));
}
say '';
say 'decode(encode(x)) == x for any text; encode(decode(y)) == y is not';
say 'guaranteed. Normalise through decode, not through encode.';
say '';
say 'and the class`s constructor arguments are silently ignored — the';
say 'subclass overrides the accessors with methods, so the base class`s';
say '@.entityNames attribute is set and never read:';
my $custom = XML::Entity::HTML.new(entityNames => ['&x;'], entityValues => ['X']);
say '  a "custom" object still has ', $custom.entityNames.elems, ' names.';

# Output:
#     436 of the 2119 names share a value, so the round trip is one-way:
#       decode("\&AMP;") = "\&"   then encode -> &amp;
#       decode("\&amp;") = "\&"   then encode -> &amp;
#     
#     decode(encode(x)) == x for any text; encode(decode(y)) == y is not
#     guaranteed. Normalise through decode, not through encode.
#     
#     and the class`s constructor arguments are silently ignored — the
#     subclass overrides the accessors with methods, so the base class`s
#     @.entityNames attribute is set and never read:
#       a "custom" object still has 2119 names.
