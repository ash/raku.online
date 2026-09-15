#!/usr/bin/env rakupp
# Avolution::Emoji — Where the two engines differ
# https://raku.online/modules/avolution-emoji/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Avolution::Emoji
#     rakupp 04-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Avolution::Emoji;

# the shortcodes that work are the ones worth using; check before you ship
sub works(Str $code) { Avolution::Emoji.emoji($code) ne $code }

my @candidates = <:smile: :tada: :heart: :+1: :thumbsup: :sob: :fire: :rocket:>;
say 'shortcode      fires?  result';
for @candidates -> $c {
    say sprintf('  %-14s %-6s %s', $c, works($c),
                works($c) ?? Avolution::Emoji.emoji($c) !! '(unchanged)');
}
say '';
say 'the file extension is .pm6 and the unit is `module Avolution`, with';
say 'the class inside it — so the name you `use` and the name you call';
say 'are the same only by convention.';

# Output:
#     shortcode      fires?  result
#       :smile:        True   😀
#       :tada:         False  (unchanged)
#       :heart:        True   ❤
#       :+1:           False  (unchanged)
#       :thumbsup:     True   👍
#       :sob:          False  (unchanged)
#       :fire:         True   🔥
#       :rocket:       False  (unchanged)
#     
#     the file extension is .pm6 and the unit is `module Avolution`, with
#     the class inside it — so the name you `use` and the name you call
#     are the same only by convention.
