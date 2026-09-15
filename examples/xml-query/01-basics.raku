#!/usr/bin/env rakupp
# XML::Query — Selecting
# https://raku.online/modules/xml-query/#selecting
#
# Install what it needs, then run it:
#     rakupp install XML::Query
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use XML;
use XML::Query;

my $doc = from-xml(q:to/END/);
<html>
  <body id="top">
    <div id="header"><a href="one.html">one</a><a href="two.html">two</a></div>
    <div><p class="decr">A</p><p>B</p></div>
    <div><input type="radio"/><input type="radio"/><input type="text"/></div>
  </body>
</html>
END

my $xq = XML::Query.new($doc);
for 'a', '.decr', '#header', 'input[type=radio]', 'a,p', 'div p', 'body > div' -> $sel {
    say sprintf('  %-20s -> %d', $sel.raku, $xq($sel).elements.elems);
}
say '';
say 'reading a node is two hops — .first, .last and [$i] all return a';
say 'Results, not an element:';
say '  $xq("a").first.element : ', $xq('a').first.element.Str;
say '  $xq("a")[1]            : ', $xq('a')[1].element.Str;
say '  $xq("a").element       : ', $xq('a').element.Str;

# Output:
#       "a"                  -> 2
#       ".decr"              -> 1
#       "#header"            -> 1
#       "input[type=radio]"  -> 2
#       "a,p"                -> 4
#       "div p"              -> 2
#       "body > div"         -> 3
#     
#     reading a node is two hops — .first, .last and [$i] all return a
#     Results, not an element:
#       $xq("a").first.element : <a href="one.html">one</a>
#       $xq("a")[1]            : <a href="two.html">two</a>
#       $xq("a").element       : <a href="one.html">one</a>
