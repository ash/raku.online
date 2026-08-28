#!/usr/bin/env rakupp
# UUID — What the format promises
# https://raku.online/modules/uuid/#what-the-format-promises
#
# Install what it needs, then run it:
#     rakupp install UUID
#     rakupp 02-format-guarantees.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use UUID;

my $id = UUID.new;
say $id.Str.chars;
say so $id.Str ~~ /^ <xdigit>**8 '-' <xdigit>**4 '-' 4 <xdigit>**3 '-' <[89ab]> <xdigit>**3 '-' <xdigit>**12 $/;
say $id.version;
say $id.Blob.elems;
say UUID.new.Str ne UUID.new.Str;

# Output:
#     36
#     True
#     4
#     16
#     True
