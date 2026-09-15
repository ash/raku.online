#!/usr/bin/env rakupp
# XML::Writer — The one thing to know
# https://raku.online/modules/xml-writer/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install XML::Writer
#     rakupp 05-newline-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use XML::Writer;

my $out = XML::Writer.serialize(:pre[ (1..10).map({ 'span' => ["chunk$_"] }) ]);
say 'newlines inside the <pre> : ', $out.comb("\n").elems - 1;
say '';
say $out.subst("\n", '\n' ~ "\n", :g);

# Output:
#     newlines inside the <pre> : 2
#     
#     <pre><span>chunk1</span><span>chunk2</span><span>chunk3</span><span>chunk4</span>\n
#     <span>chunk5</span><span>chunk6</span><span>chunk7</span><span>chunk8</span>\n
#     <span>chunk9</span><span>chunk10</span></pre>\n
