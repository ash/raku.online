#!/usr/bin/env rakupp
# Text::LDIF — Where the two engines differ
# https://raku.online/modules/text-ldif/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Text::LDIF
#     rakupp 05-failures.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::LDIF;

my %cases =
    'missing version:'      => "dn: cn=a\ncn: a\n\n",
    'no trailing newline'   => "version: 1\ndn: cn=a\ncn: a",
    'a non-ASCII value'     => "version: 1\ndn: cn=a\ncn: Lovelac\c[LATIN SMALL LETTER E WITH ACUTE]\n\n",
    'a well-formed file'    => "version: 1\ndn: cn=a\ncn: a\n\n";

for %cases.keys.sort -> $label {
    my $r = Text::LDIF.parse(%cases{$label});
    say sprintf('%-22s -> %s', $label, $r.defined ?? 'parsed' !! 'Nil');
}
say '';
say 'version: is mandatory and must come first; the file must end in a';
say 'newline; any byte above \x7F fails the WHOLE document (RFC 2849 wants';
say 'base64 there). All three look the same from outside.';

# Output:
#     a non-ASCII value      -> Nil
#     a well-formed file     -> Nil
#     missing version:       -> Nil
#     no trailing newline    -> Nil
#     
#     version: is mandatory and must come first; the file must end in a
#     newline; any byte above \x7F fails the WHOLE document (RFC 2849 wants
#     base64 there). All three look the same from outside.
