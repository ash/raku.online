#!/usr/bin/env rakupp
# HTML::EscapeUtils — The one thing to know
# https://raku.online/modules/html-escapeutils/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install HTML::EscapeUtils
#     rakupp 04-unknown.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTML::EscapeUtils;

for '&notanentity;', '&123;', '&;', 'plain text', 'a & b' -> $s {
    my $r = try unescape($s);
    say sprintf('  %-18s -> %s', $s.raku, $! ?? 'threw ' ~ $!.^name !! $r.raku);
}
say '';
say 'the internal replace does  return $match if %codepoints{$match}:!exists;';
say '— returning the Match from a --> Str sub, so the RETURN type-check';
say 'fires.';
say '';
say 'you cannot run unescape over arbitrary HTML. One unknown entity, one';
say 'stray &…;, even a bare &;, and it explodes.';
say '';
say 'guard it:';
sub safe-unescape(Str $s) {
    $s.subst(/ '&' <-[&;\s]>+ ';' /, { (try unescape($/.Str)) // $/.Str }, :g)
}
say '  safe-unescape("&amp; &nope; &lt;") = ',
    safe-unescape('&amp; &nope; &lt;').raku;

# Output:
#       "\&notanentity;"   -> threw X::TypeCheck::Return
#       "\&123;"           -> threw X::TypeCheck::Return
#       "\&;"              -> threw X::TypeCheck::Return
#       "plain text"       -> "plain text"
#       "a \& b"           -> "a \& b"
#     
#     the internal replace does  return $match if %codepoints{$match}:!exists;
#     — returning the Match from a --> Str sub, so the RETURN type-check
#     fires.
#     
#     you cannot run unescape over arbitrary HTML. One unknown entity, one
#     stray &…;, even a bare &;, and it explodes.
#     
#     guard it:
#       safe-unescape("&amp; &nope; &lt;") = "\& \&nope; <"
