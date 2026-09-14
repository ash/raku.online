#!/usr/bin/env rakupp
# SVG — A drawing as data
# https://raku.online/modules/svg/#a-drawing-as-data
#
# Install what it needs, then run it:
#     rakupp install SVG
#     rakupp 01-serialize.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use SVG;

say SVG.serialize('svg' => [ :width(20), :height(10),
    'rect' => [ :x(1), :y(2), :width(8), :height(6) ],
    'text' => [ :x(2), :y(9), 'hi' ] ]);
say SVG.serialize('circle' => [ :cx(5), :cy(5), :r(4) ], :!preamble);

# Output:
#     <svg xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="20" height="10"><rect x="1" y="2" width="8" height="6" /><text x="2" y="9">hi</text></svg>
#     
#     <circle cx="5" cy="5" r="4" />
