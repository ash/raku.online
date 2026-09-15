#!/usr/bin/env rakupp
# Avolution::Emoji — The table is not what the names say
# https://raku.online/modules/avolution-emoji/#the-table-is-not-what-the-names-say
#
# Install what it needs, then run it:
#     rakupp install Avolution::Emoji
#     rakupp 03-collisions.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Avolution::Emoji;

say 'several shortcodes land on a different emoji than their name:';
for ':see-no-evil:', ':hear-no-evil:', ':speak-no-evil:',
    ':smile-cat:', ':kissing-cat:', ':grin:', ':grimacing:' -> $s {
    say sprintf('  %-18s -> %s', $s, Avolution::Emoji.emoji($s));
}
say '';
say 'hear-no-evil and speak-no-evil both give you the SEE-no-evil monkey;';
say 'kissing-cat gives the smiling cat; grin gives the grimacing face.';
say '';
say 'and one key is misspelled in the table, so the correct spelling';
say 'does nothing while the typo works:';
for ':disappointed-relieved:', ':dissapointed-relieved:' -> $s {
    say sprintf('  %-26s -> %s', $s, Avolution::Emoji.emoji($s).raku);
}

# Output:
#     several shortcodes land on a different emoji than their name:
#       :see-no-evil:      -> 🙈
#       :hear-no-evil:     -> 🙈
#       :speak-no-evil:    -> 🙈
#       :smile-cat:        -> 😺
#       :kissing-cat:      -> 😺
#       :grin:             -> 😬
#       :grimacing:        -> 😬
#     
#     hear-no-evil and speak-no-evil both give you the SEE-no-evil monkey;
#     kissing-cat gives the smiling cat; grin gives the grimacing face.
#     
#     and one key is misspelled in the table, so the correct spelling
#     does nothing while the typo works:
#       :disappointed-relieved:    -> ":disappointed-relieved:"
#       :dissapointed-relieved:    -> "😥"
