#!/usr/bin/env rakupp
# Encoding::Huffman::PP6 — The one thing to know
# https://raku.online/modules/encoding-huffman-pp6/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Encoding::Huffman::PP6
#     rakupp 03-digits.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Encoding::Huffman::PP6;

for '0', '4', '9', ' ', 'a', 'HTTP 404 gone' -> $s {
    my $back = huffman-decode(huffman-encode($s));
    say sprintf('  %-16s -> %-24s %s', $s.raku, $back.raku,
                $back eq $s ?? 'OK' !! 'WRONG');
}
say '';
say 'the reverse lookup gives back a one-character Str, and the line';
say '  $r ~= try {%a{$a}.chr} // %a{$a}';
say 'calls .chr on it. Str.chr numifies first, so "4".chr is 4.chr — a';
say 'control character — and the `try` never fires because nothing failed.';
say '';
say 'encoding a header value, a date, a status code or anything with a';
say 'space through this module is lossy. Sixteen characters are affected:';
say '  tab, newline, VT, FF, CR, space, and the ten digits.';

# Output:
#       "0"              -> "\0"                     WRONG
#       "4"              -> "\x[4]"                  WRONG
#       "9"              -> "\t"                     WRONG
#       " "              -> "\0"                     WRONG
#       "a"              -> "a"                      OK
#       "HTTP 404 gone"  -> "HTTP\0\x[4]\0\x[4]\0gone" WRONG
#     
#     the reverse lookup gives back a one-character Str, and the line
#       $r ~= try {%a{$a}.chr} // %a{$a}
#     calls .chr on it. Str.chr numifies first, so "4".chr is 4.chr — a
#     control character — and the `try` never fires because nothing failed.
#     
#     encoding a header value, a date, a status code or anything with a
#     space through this module is lossy. Sixteen characters are affected:
#       tab, newline, VT, FF, CR, space, and the ten digits.
