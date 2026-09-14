#!/usr/bin/env rakupp
# HTML::Escape — The whole API
# https://raku.online/modules/html-escape/#the-whole-api
#
# Install what it needs, then run it:
#     rakupp install HTML::Escape
#     rakupp 01-escape.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTML::Escape;

say escape-html('<a href="x">Tom & Jerry</a>');
say escape-html("it's");
say escape-html('plain text');

# Output:
#     &lt;a href=&quot;x&quot;&gt;Tom &amp; Jerry&lt;/a&gt;
#     it&#39;s
#     plain text
