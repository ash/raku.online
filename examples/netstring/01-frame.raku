#!/usr/bin/env rakupp
# Netstring — Framing a message
# https://raku.online/modules/netstring/#framing-a-message
#
# Install what it needs, then run it:
#     rakupp install Netstring
#     rakupp 01-frame.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Netstring;

for 'hello', '', 'a', 'x' x 12 -> $s {
    say sprintf('to-netstring(%-14s) = %s', $s.raku, to-netstring($s).raku);
}
say '';
my $u = 'caf' ~ "\c[LATIN SMALL LETTER E WITH ACUTE]";
say 'the prefix is a BYTE count, not a character count:';
say '  input          : ', $u.raku;
say '  .chars         : ', $u.chars;
say '  utf8 bytes     : ', $u.encode('utf8').bytes;
say '  to-netstring   : ', to-netstring($u).raku;

# Output:
#     to-netstring("hello"       ) = "5:hello,"
#     to-netstring(""            ) = "0:,"
#     to-netstring("a"           ) = "1:a,"
#     to-netstring("xxxxxxxxxxxx") = "12:xxxxxxxxxxxx,"
#     
#     the prefix is a BYTE count, not a character count:
#       input          : "café"
#       .chars         : 4
#       utf8 bytes     : 5
#       to-netstring   : "5:café,"
