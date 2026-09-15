#!/usr/bin/env rakupp
# XML::Writer — Writing a document
# https://raku.online/modules/xml-writer/#writing-a-document
#
# Install what it needs, then run it:
#     rakupp install XML::Writer
#     rakupp 01-serialise.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use XML::Writer;

say XML::Writer.serialize(:html[
    :head[ :title[ 'Report' ] ],
    :body[ :h1[ 'Totals' ], :p[ 'Rows: 3' ] ],
]);

# Output:
#     <html><head><title>Report</title></head><body><h1>Totals</h1><p>Rows: 3</p></body>
#     </html>
