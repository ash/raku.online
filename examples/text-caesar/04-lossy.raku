#!/usr/bin/env rakupp
# Text::Caesar — The one thing to know
# https://raku.online/modules/text-caesar/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Text::Caesar
#     rakupp 04-lossy.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Caesar;

for 'Straße', 'ﬁle', 'wafﬄe' -> $plain {
    my $cipher = encrypt(1, $plain);
    my $back   = decrypt(1, $cipher);
    say sprintf('%-8s chars=%d  ->  %-10s chars=%d  ->  %-10s  round-trips? %s',
                $plain, $plain.chars, $cipher, $cipher.chars, $back,
                $back eq $plain.uc ?? 'to .uc' !! 'no');
}
say '';
say 'ß upper-cases to SS, so one character enciphers as two —';
say 'and there is no reverse mapping that puts it back.';

# Output:
#     Straße   chars=6  ->  TUSBTTF    chars=7  ->  STRASSE     round-trips? to .uc
#     ﬁle      chars=3  ->  GJMF       chars=4  ->  FILE        round-trips? to .uc
#     wafﬄe    chars=5  ->  XBGGGMF    chars=7  ->  WAFFFLE     round-trips? to .uc
#     
#     ß upper-cases to SS, so one character enciphers as two —
#     and there is no reverse mapping that puts it back.
