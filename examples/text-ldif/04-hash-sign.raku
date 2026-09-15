#!/usr/bin/env rakupp
# Text::LDIF — The one thing to know
# https://raku.online/modules/text-ldif/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Text::LDIF
#     rakupp 04-hash-sign.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::LDIF;

for 'plain', 'C# and F#' -> $desc {
    my $r = Text::LDIF.parse("version: 1\ndn: cn=a\ndescription: $desc\nsn: Smith\n\n");
    say sprintf('%-12s -> %s', $desc.raku, $r<entries>[0]<attrs>.raku);
}
say '';
say 'the pre-pass is .subst(/ "#" .*? "\n" /, "", :g) over the WHOLE file,';
say 'with no anchor to the start of a line. LDAP values routinely contain';
say '"#" — DN escaping uses it, as do passwords, colours and URLs.';

# Output:
#     "plain"      -> Any
#     "C# and F#"  -> Any
#     
#     the pre-pass is .subst(/ "#" .*? "\n" /, "", :g) over the WHOLE file,
#     with no anchor to the start of a line. LDAP values routinely contain
#     "#" — DN escaping uses it, as do passwords, colours and URLs.
