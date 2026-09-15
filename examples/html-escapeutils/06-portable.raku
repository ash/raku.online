#!/usr/bin/env rakupp
# HTML::EscapeUtils — Where the two engines differ
# https://raku.online/modules/html-escapeutils/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install HTML::EscapeUtils
#     rakupp 06-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTML::EscapeUtils;

say 'the lowercase form is fine on both:';
say '  unescape("&#x41;") = ', unescape('&#x41;').raku;
say '';
say 'the uppercase-X form is a Rakudo throw and a Raku++ U+0002. Reject';
say 'it before you get there:';
sub numeric-ok(Str $s) { $s !~~ / '&#' <[X]> / }
for '&#x41;', '&#X41;' -> $e {
    say sprintf('  %-10s acceptable ? %s', $e.raku, numeric-ok($e));
}
say '';
say 'and note what escape does NOT do: no numeric-reference escaping is';
say 'available at all, so if a consumer needs &#x27; rather than &apos;';
say 'you have to build it yourself.';

# Output:
#     the lowercase form is fine on both:
#       unescape("&#x41;") = "A"
#     
#     the uppercase-X form is a Rakudo throw and a Raku++ U+0002. Reject
#     it before you get there:
#       "\&#x41;"  acceptable ? True
#       "\&#X41;"  acceptable ? False
#     
#     and note what escape does NOT do: no numeric-reference escaping is
#     available at all, so if a consumer needs &#x27; rather than &apos;
#     you have to build it yourself.
