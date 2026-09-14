#!/usr/bin/env rakupp
# Color::Names — Looking a colour up, and finding one
# https://raku.online/modules/color-names/#looking-a-colour-up-and-finding-one
#
# Install what it needs, then run it:
#     rakupp install Color::Names
#     rakupp 01-lookup.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Color::Names;
use Color::Names::CSS3 :colors;

my %css = Color::Names.color-data('CSS3');
say %css.elems, ' CSS3 colours';

my %c = %css<rebeccapurple-CSS3>;
say %c<name>, ' = ', %c<rgb>.join(', ');

for find-color(%css, 'slate').sort(*.key) -> $p {
    say $p.key, ' — ', $p.value<name>;
}

# Output:
#     141 CSS3 colours
#     Rebecca Purple = 102, 51, 153
#     darkslateblue-CSS3 — Dark Slate Blue
#     darkslategray-CSS3 — Dark Slate Gray
#     lightslategray-CSS3 — Light Slate Gray
#     mediumslateblue-CSS3 — Medium Slate Blue
#     slateblue-CSS3 — Slate Blue
#     slategray-CSS3 — Slate Gray
