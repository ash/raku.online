#!/usr/bin/env rakupp
# MIME::QuotedPrint — Mail-header mode
# https://raku.online/modules/mime-quotedprint/#mail-header-mode
#
# Install what it needs, then run it:
#     rakupp install MIME::QuotedPrint
#     rakupp 03-header.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use MIME::QuotedPrint;

constant QP = MIME::QuotedPrint;

for 'a b c', 'under_score', 'x?y', 'caf' ~ "\c[LATIN SMALL LETTER E WITH ACUTE]" -> $in {
    my $enc = QP.encode-str($in, :mime-header);
    say sprintf('%-12s -> %-16s round-trip=%s',
        $in.raku, $enc.raku, QP.decode-str($enc, :mime-header) eq $in ?? 'exact' !! 'DIFFERS');
}

# Output:
#     "a b c"      -> "a_b_c"          round-trip=exact
#     "under_score" -> "under=5Fscore"  round-trip=exact
#     "x?y"        -> "x=3Fy"          round-trip=exact
#     "café"       -> "caf=C3=A9"      round-trip=exact
