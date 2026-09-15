#!/usr/bin/env rakupp
# MIME::QuotedPrint — Encoding and decoding
# https://raku.online/modules/mime-quotedprint/#encoding-and-decoding
#
# Install what it needs, then run it:
#     rakupp install MIME::QuotedPrint
#     rakupp 01-qp.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use MIME::QuotedPrint;

constant QP = MIME::QuotedPrint;

sub show(Str $s) { $s.subst("\r", '\r', :g).subst("\n", '\n', :g) }

for 'hello world', 'a=b', 'caf' ~ "\c[LATIN SMALL LETTER E WITH ACUTE]",
    "tab\there", 'trailing space ', '' -> $in {
    my $enc = QP.encode-str($in);
    my $dec = QP.decode-str($enc);
    say sprintf('in=%-22s enc=%-26s round-trip=%s',
        $in.raku, show($enc).raku, $dec eq $in ?? 'exact' !! 'DIFFERS');
}

# Output:
#     in="hello world"          enc="hello world"              round-trip=exact
#     in="a=b"                  enc="a=3Db"                    round-trip=exact
#     in="café"                 enc="caf=C3=A9"                round-trip=exact
#     in="tab\there"            enc="tab\there"                round-trip=exact
#     in="trailing space "      enc="trailing space =\\n"      round-trip=exact
#     in=""                     enc=""                         round-trip=exact
