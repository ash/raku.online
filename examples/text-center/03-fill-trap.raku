#!/usr/bin/env rakupp
# Text::Center — The one thing to know
# https://raku.online/modules/text-center/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Text::Center
#     rakupp 03-fill-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Center;

for '.', '<>', '-=-' -> $f {
    my $r = center('hi', 12, :fill($f));
    say sprintf('fill=%-6s asked for 12, got %2d  [%s]', "'$f'", $r.chars, $r);
}

# Output:
#     fill='.'    asked for 12, got 12  [.... hi ....]
#     fill='<>'   asked for 12, got 20  [<><><><> hi <><><><>]
#     fill='-=-'  asked for 12, got 28  [-=--=--=--=- hi -=--=--=--=-]
