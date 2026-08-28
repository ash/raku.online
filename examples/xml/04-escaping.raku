#!/usr/bin/env rakupp
# XML — The sharp edge: nothing is escaped for you
# https://raku.online/modules/xml/#the-sharp-edge-nothing-is-escaped-for-you
#
# Install what it needs, then run it:
#     rakupp install XML
#     rakupp 04-escaping.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use XML;

sub xml-escape(Str $s) {
    $s.subst('&', '&amp;', :g)
      .subst('<', '&lt;',  :g)
      .subst('>', '&gt;',  :g)
      .subst('"', '&quot;', :g)
}

my $e = XML::Element.new(name => 'note');
$e.set('title', xml-escape('Tom & Jerry <"quoted">'));
$e.append(XML::Text.new(text => xml-escape('5 < 6 & 7 > 6')));
say ~$e;

my $back = from-xml(~$e);
say $back.root.attribs<title>;
say $back.root.nodes[0].string;

# Output:
#     <note title="Tom &amp; Jerry &lt;&quot;quoted&quot;&gt;">5 &lt; 6 &amp; 7 &gt; 6</note>
#     Tom &amp; Jerry &lt;&quot;quoted&quot;&gt;
#     5 < 6 & 7 > 6
