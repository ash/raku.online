#!/usr/bin/env rakupp
# HTML::EscapeUtils — Escaping
# https://raku.online/modules/html-escapeutils/#escaping
#
# Install what it needs, then run it:
#     rakupp install HTML::EscapeUtils
#     rakupp 02-attributes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTML::EscapeUtils;

my $payload = q{x" onmouseover="alert(1)};
say 'double-quoted : <a title="', escape($payload), '">';
my $single = q{x' onmouseover='alert(1)};
say 'single-quoted : <a title=', "'", escape($single), "'", '>';
say 'unquoted      : <a title=', escape('x onmouseover=alert(1)'), '>';
say '';
say 'the first two are safe; the third is a live attribute injection.';
say 'ALWAYS quote your attribute values — this escape does not remove';
say 'spaces, backticks or equals signs, and an unquoted attribute needs';
say 'all three handled.';

# Output:
#     double-quoted : <a title="x&quot; onmouseover=&quot;alert(1)">
#     single-quoted : <a title='x&apos; onmouseover=&apos;alert(1)'>
#     unquoted      : <a title=x onmouseover=alert(1)>
#     
#     the first two are safe; the third is a live attribute injection.
#     ALWAYS quote your attribute values — this escape does not remove
#     spaces, backticks or equals signs, and an unquoted attribute needs
#     all three handled.
