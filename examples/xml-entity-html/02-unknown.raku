#!/usr/bin/env rakupp
# XML::Entity::HTML — What it does with input it does not know
# https://raku.online/modules/xml-entity-html/#what-it-does-with-input-it-does-not-know
#
# Install what it needs, then run it:
#     rakupp install XML::Entity::HTML
#     rakupp 02-unknown.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use XML::Entity::HTML;

for '&lt', '&nosuchentity;', '&#;', '&#x;', '&amp;amp;', '&#0;', '&#-1;' -> $e {
    my $r = try decode-html-entities($e);
    say sprintf('  %-16s -> %s', $e.raku, $! ?? 'threw' !! $r.raku);
}
say '';
say 'unknown and truncated entities pass through unchanged, and decoding';
say 'is a single .trans pass, so &amp;amp; does NOT double-decode.';
say '';
say 'an out-of-range numeric entity is the one that throws:';
my $r = try decode-html-entities('&#999999999999;');
say '  &#999999999999; -> ', $! ?? 'X::AdHoc, codepoint out of bounds' !! $r;

# Output:
#       "\&lt"           -> "\&lt"
#       "\&nosuchentity;" -> "\&nosuchentity;"
#       "\&#;"           -> "\&#;"
#       "\&#x;"          -> "\&#x;"
#       "\&amp;amp;"     -> "\&amp;"
#       "\&#0;"          -> "\0"
#       "\&#-1;"         -> "\&#-1;"
#     
#     unknown and truncated entities pass through unchanged, and decoding
#     is a single .trans pass, so &amp;amp; does NOT double-decode.
#     
#     an out-of-range numeric entity is the one that throws:
#       &#999999999999; -> X::AdHoc, codepoint out of bounds
