#!/usr/bin/env rakupp
# Text::Spintax — The one thing to know
# https://raku.online/modules/text-spintax/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Text::Spintax
#     rakupp 04-unbalanced.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Spintax;

for 'a}b', '{a|b', 'the {b} case', 'C{ontent' -> $src {
    my $tree = try Text::Spintax.parse($src);
    say sprintf('  %-16s -> %s', $src.raku,
                ($tree.defined ?? 'a ' ~ $tree.^name !! 'no usable tree'));
}
say '';
say 'the grammar`s `token text` is <-[\\{\\}|]>+, so a stray brace or pipe';
say 'cannot be matched as text; the grammar fails, Grammar.parse returns';
say 'an undefined value, and the module calls .ast on it without checking.';
say '';
say 'check before you render:';
sub spin(Str $src) {
    my $tree = try Text::Spintax.parse($src);
    $tree.defined or die "unbalanced spintax: $src";
    $tree
}
for 'a {b|c} d', 'a}b' -> $src {
    my $t = try spin($src);
    say sprintf('  %-12s -> %s', $src.raku,
                $! ?? 'rejected' !! 'renders as ' ~ ($t.render.chars ~ ' characters'));
}

# Output:
#       "a}b"            -> no usable tree
#       "\{a|b"          -> no usable tree
#       "the \{b} case"  -> a Text::Spintax::SequenceNode
#       "C\{ontent"      -> no usable tree
#     
#     the grammar`s `token text` is <-[\{\}|]>+, so a stray brace or pipe
#     cannot be matched as text; the grammar fails, Grammar.parse returns
#     an undefined value, and the module calls .ast on it without checking.
#     
#     check before you render:
#       "a \{b|c} d" -> renders as 5 characters
#       "a}b"        -> rejected
