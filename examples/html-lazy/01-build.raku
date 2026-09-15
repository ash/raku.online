#!/usr/bin/env rakupp
# HTML::Lazy — Building a document
# https://raku.online/modules/html-lazy/#building-a-document
#
# Install what it needs, then run it:
#     rakupp install HTML::Lazy
#     rakupp 01-build.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTML::Lazy;

print render(html-en(
    :attributes({ :lang<en> }),
    node('h1', {}, text('Totals')),
    node('p', {}, text('Rows: 3')),
));

# Output:
#     <!DOCTYPE html>
#     <html lang="en">
#         <h1>
#             Totals
#         </h1>
#         <p>
#             Rows: 3
#         </p>
#     </html>
