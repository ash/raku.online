#!/usr/bin/env rakupp
# XML::Entity::HTML — The one thing to know
# https://raku.online/modules/xml-entity-html/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install XML::Entity::HTML
#     rakupp 03-numeric-dead.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use XML::Entity::HTML;

for '<', "\c[CYRILLIC CAPITAL LETTER PE]" -> $c {
    say sprintf('  encode(%s)                = %s', $c.raku, encode-html-entities($c));
    say sprintf('  encode(%s, %d)             = %s', $c.raku, $c.ord,
                encode-html-entities($c, $c.ord));
    say sprintf('  encode(%s, %d, :hex)       = %s', $c.raku, $c.ord,
                encode-html-entities($c, $c.ord, :hex));
}
say '';
say 'encode runs the NAME substitution first, so by the time the numeric';
say 'loop looks for the raw character it is already gone. Since the HTML';
say 'table covers essentially everything you would want to escape, there';
say 'is no input for which these parameters do anything.';
say '';
say 'if you need &#x27; rather than &apos;, this module cannot produce it —';
say 'do it yourself:';
sub numeric-escape(Str $s, *@chars) {
    my %want = @chars.map({ .chr => sprintf('&#x%X;', $_) });
    my $out = $s;
    $out = $out.subst(.chr, %want{.chr}, :g) for @chars;
    $out
}
say '  numeric-escape(<it-apostrophe-s>, 0x27) = ', numeric-escape("it's", 0x27);

# Output:
#       encode("<")                = &lt;
#       encode("<", 60)             = &lt;
#       encode("<", 60, :hex)       = &lt;
#       encode("П")                = &Pcy;
#       encode("П", 1055)             = &Pcy;
#       encode("П", 1055, :hex)       = &Pcy;
#     
#     encode runs the NAME substitution first, so by the time the numeric
#     loop looks for the raw character it is already gone. Since the HTML
#     table covers essentially everything you would want to escape, there
#     is no input for which these parameters do anything.
#     
#     if you need &#x27; rather than &apos;, this module cannot produce it —
#     do it yourself:
#       numeric-escape(<it-apostrophe-s>, 0x27) = it&#x27;s
