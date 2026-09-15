#!/usr/bin/env rakupp
# HTML::Lazy — The one thing to know
# https://raku.online/modules/html-lazy/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install HTML::Lazy
#     rakupp 04-escape-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTML::Lazy;

my $evil = q{<script>alert("x&y")</script>};

say 'in a text node, escaped:';
print render(node('p', {}, text($evil)));
say '';
say 'in an attribute, NOT escaped:';
print render(node('a', { :title($evil) }));
say '';
say 'which means an attacker can close the quote:';
print render(node('a', { :title(q{" onmouseover=alert(1) x="}) }));

# Output:
#     in a text node, escaped:
#     <p>
#         &lt;script&gt;alert(&quot;x&amp;y&quot;)&lt;/script&gt;
#     </p>
#     in an attribute, NOT escaped:
#     <a title="<script>alert("x&y")</script>"></a>
#     which means an attacker can close the quote:
#     <a title="" onmouseover=alert(1) x=""></a>
