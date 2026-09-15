#!/usr/bin/env rakupp
# HTML::EscapeUtils — Escaping
# https://raku.online/modules/html-escapeutils/#escaping
#
# Install what it needs, then run it:
#     rakupp install HTML::EscapeUtils
#     rakupp 01-escape.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTML::EscapeUtils;

my $raw = q{<a href="x">Tom & Jerry's</a>};
say 'raw     : ', $raw;
say 'escaped : ', escape($raw);
say '';
say 'exactly five characters are escaped:';
for '&', '<', '>', '"', "'", '/', '`', '=', ' ' -> $c {
    say sprintf('  %-4s -> %s', $c.raku, escape($c).raku);
}
say '';
say '& is substituted first, so double-escaping does not occur and the';
say 'round trip is lossless:';
say '  unescape(escape($raw)) eq $raw : ', unescape(escape($raw)) eq $raw;

# Output:
#     raw     : <a href="x">Tom & Jerry's</a>
#     escaped : &lt;a href=&quot;x&quot;&gt;Tom &amp; Jerry&apos;s&lt;/a&gt;
#     
#     exactly five characters are escaped:
#       "\&" -> "\&amp;"
#       "<"  -> "\&lt;"
#       ">"  -> "\&gt;"
#       "\"" -> "\&quot;"
#       "'"  -> "\&apos;"
#       "/"  -> "/"
#       "`"  -> "`"
#       "="  -> "="
#       " "  -> " "
#     
#     & is substituted first, so double-escaping does not occur and the
#     round trip is lossless:
#       unescape(escape($raw)) eq $raw : True
