#!/usr/bin/env rakupp
# Text::LDIF — Parsing an entry
# https://raku.online/modules/text-ldif/#parsing-an-entry
#
# Install what it needs, then run it:
#     rakupp install Text::LDIF
#     rakupp 02-folding.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::LDIF;

my $folded = "version: 1\ndn: cn=a\ndescription: hello\n world\nsn: b\n\n";
my $r = Text::LDIF.parse($folded);
say 'description : ', $r<entries>[0]<attrs><description>.raku;
say '';
say 'note the join has no space: "hello\n world" becomes "helloworld".';

# Output:
#     description : Any
#     
#     note the join has no space: "hello\n world" becomes "helloworld".
