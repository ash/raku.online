#!/usr/bin/env rakupp
# Text::Markdown — Rendering a document
# https://raku.online/modules/text-markdown/#rendering-a-document
#
# Install what it needs, then run it:
#     rakupp install Text::Markdown
#     rakupp 01-markdown.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Markdown;

my $md = q:to/MD/;
# A heading

Some *emphasis*, some **strong**, and a `literal`.

- one
- two

> a quote

    a code block
MD

say parse-markdown($md).to-html;

# Output:
#     <h1>A heading</h1><p>Some <em>emphasis</em>, some <strong>strong</strong>, and a <code>literal</code>.</p><p>- one - two</p><blockquote><p>a quote</p></blockquote><pre><code>a code block</code></pre>
