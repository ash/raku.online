#!/usr/bin/env rakupp
# XML::Writer — Attributes and empty elements
# https://raku.online/modules/xml-writer/#attributes-and-empty-elements
#
# Install what it needs, then run it:
#     rakupp install XML::Writer
#     rakupp 02-attributes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use XML::Writer;

say XML::Writer.serialize(:a[ :href<http://example.invalid/>, :class<lnk>, 'click' ]);
say XML::Writer.serialize(:br[]);
say XML::Writer.serialize(:n[ 42 ]);
say XML::Writer.serialize(:img[ :src<a.png>, :alt<A> ]);

# Output:
#     <a href="http://example.invalid/" class="lnk">click</a>
#     <br />
#     <n>42</n>
#     <img src="a.png" alt="A" />
