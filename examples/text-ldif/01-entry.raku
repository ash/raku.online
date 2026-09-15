#!/usr/bin/env rakupp
# Text::LDIF — Parsing an entry
# https://raku.online/modules/text-ldif/#parsing-an-entry
#
# Install what it needs, then run it:
#     rakupp install Text::LDIF
#     rakupp 01-entry.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::LDIF;

my $ldif = q:to/END/;
version: 1
dn: cn=Ada Lovelace,dc=example,dc=com
objectclass: person
cn: Ada Lovelace
sn: Lovelace

END

my $r = Text::LDIF.parse($ldif);
say 'result type : ', $r.WHAT.^name;
say 'version     : ', $r<version>;
say 'entries     : ', $r<entries>.elems;
say 'dn          : ', $r<entries>[0]<dn>.raku;
say 'attrs keys  : ', $r<entries>[0]<attrs>.keys.sort.join(', ');

# Output:
#     result type : Any
#     version     : (Any)
#     entries     : 1
#     dn          : Any
#     attrs keys  : 
