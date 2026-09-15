#!/usr/bin/env rakupp
# HTML::Lazy — Tag helpers
# https://raku.online/modules/html-lazy/#tag-helpers
#
# Install what it needs, then run it:
#     rakupp install HTML::Lazy
#     rakupp 02-tags.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTML::Lazy (:DEFAULT, :tags);

print render(html-en(
    :attributes({ :lang<en> }),
    head({}, title({}, text('A page'))),
    body({}, div({}, text('content'))),
));

# Output:
#     <!DOCTYPE html>
#     <html lang="en">
#         <head>
#             <title>
#                 A page
#             </title>
#         </head>
#         <body>
#             <div>
#                 content
#             </div>
#         </body>
#     </html>
