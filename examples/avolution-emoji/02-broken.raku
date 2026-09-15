#!/usr/bin/env rakupp
# Avolution::Emoji — The one thing to know
# https://raku.online/modules/avolution-emoji/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Avolution::Emoji
#     rakupp 02-broken.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Avolution::Emoji;

say 'the thumbs-up shortcode:';
for ':+1:', ':1:', '::::1:', ':thumbsup:', ':-1:' -> $s {
    say sprintf('  %-12s -> %s', $s.raku, Avolution::Emoji.emoji($s).raku);
}
say '';
say 'the pattern is written \:+1\: — the + quantifies the ESCAPED COLON';
say 'instead of being a literal +. So it matches one-or-more colons';
say 'followed by 1:, and the :+1: a user actually types does not match.';
say 'the thumbs-DOWN partner is fine.';
say '';
say 'the crying shortcode:';
for ':sob:', ' ob:', "a\tob::b" -> $s {
    say sprintf('  %-12s -> %s', $s.raku, Avolution::Emoji.emoji($s).raku);
}
say '';
say 'that one is \sob:\: — \s is the WHITESPACE class. It matches';
say 'whitespace, then "ob", then a colon. Any string containing a space';
say 'followed by "ob:" gets rewritten.';

# Output:
#     the thumbs-up shortcode:
#       ":+1:"       -> ":+1:"
#       ":1:"        -> "👍"
#       "::::1:"     -> "👍"
#       ":thumbsup:" -> "👍"
#       ":-1:"       -> "👎"
#     
#     the pattern is written \:+1\: — the + quantifies the ESCAPED COLON
#     instead of being a literal +. So it matches one-or-more colons
#     followed by 1:, and the :+1: a user actually types does not match.
#     the thumbs-DOWN partner is fine.
#     
#     the crying shortcode:
#       ":sob:"      -> ":sob:"
#       " ob:"       -> "😭"
#       "a\tob::b"   -> "a😭:b"
#     
#     that one is \sob:\: — \s is the WHITESPACE class. It matches
#     whitespace, then "ob", then a colon. Any string containing a space
#     followed by "ob:" gets rewritten.
