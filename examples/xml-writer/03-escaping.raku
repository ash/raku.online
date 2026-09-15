#!/usr/bin/env rakupp
# XML::Writer — Escaping
# https://raku.online/modules/xml-writer/#escaping
#
# Install what it needs, then run it:
#     rakupp install XML::Writer
#     rakupp 03-escaping.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use XML::Writer;

say XML::Writer.serialize(:p[ '<script>a&b"c"</script>' ]);
say XML::Writer.serialize(:a[ :title('" onmouseover=x "'), 'hi' ]);

# Output:
#     <p>&lt;script&gt;a&amp;b&quot;c&quot;&lt;/script&gt;</p>
#     <a title="&quot; onmouseover=x &quot;">hi</a>
