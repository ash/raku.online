#!/usr/bin/env rakupp
# Glob::Grammar — The one thing to know
# https://raku.online/modules/glob-grammar/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Glob::Grammar
#     rakupp 02-brackets.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Glob::Grammar;
use Glob::ToRegexActions;

my $actions = Glob::ToRegexActions.new;
sub to-rx(Str $g) {
    my $m = Glob::Grammar.parse($g, :$actions);
    $m ?? $m.made !! Nil
}

say to-rx('[abc]x').raku;
say to-rx('[a-c]x').raku;
say to-rx('[!a]bc').raku;
say to-rx('{one,two}').raku;
say to-rx('a\*b').raku;

# Output:
#     "^<[a b c]>x\$"
#     "^<[a - c]>x\$"
#     "^<[! a]>bc\$"
#     "^\\\{one\\,two\\}\$"
#     "^a\\\\.*b\$"
