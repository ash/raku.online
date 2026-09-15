#!/usr/bin/env rakupp
# HTML::Lazy — Composition
# https://raku.online/modules/html-lazy/#composition
#
# Install what it needs, then run it:
#     rakupp install HTML::Lazy
#     rakupp 03-compose.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTML::Lazy;

my $row = -> $label, $value {
    node('tr', {}, node('td', {}, text($label)), node('td', {}, text($value)))
};

print render(node('table', {},
    $row('alpha', '1'),
    $row('beta',  '2'),
));

# Output:
#     <table>
#         <tr>
#             <td>
#                 alpha
#             </td>
#             <td>
#                 1
#             </td>
#         </tr>
#         <tr>
#             <td>
#                 beta
#             </td>
#             <td>
#                 2
#             </td>
#         </tr>
#     </table>
