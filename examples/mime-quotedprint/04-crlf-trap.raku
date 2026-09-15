#!/usr/bin/env rakupp
# MIME::QuotedPrint — The one thing to know
# https://raku.online/modules/mime-quotedprint/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install MIME::QuotedPrint
#     rakupp 04-crlf-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use MIME::QuotedPrint;

constant QP = MIME::QuotedPrint;

my $mine = QP.encode-str('A' x 100);
say 'this encoder emits its soft break as : ', $mine.substr(74, 3).ords.List.raku,
    "   ('=' then LF)";
say 'and decodes its own output exactly   : ', QP.decode-str($mine) eq 'A' x 100;
say '';
my $rfc = $mine.subst("=\n", "=\r\n", :g);
say 'the RFC form is                      : ', $rfc.substr(74, 4).ords.List.raku,
    "   ('=' then CR then LF)";
my $out = try QP.decode-str($rfc);
say 'decoding it                          : ', $! ?? 'threw' !! 'ok';
say '';
say 'the fix is to normalise first:';
say '  ', QP.decode-str($rfc.subst("=\r\n", "=\n", :g)) eq 'A' x 100;

# Output:
#     this encoder emits its soft break as : (65, 61, 10)   ('=' then LF)
#     and decodes its own output exactly   : True
#     
#     the RFC form is                      : (65, 61, 13, 10, 65)   ('=' then CR then LF)
#     decoding it                          : threw
#     
#     the fix is to normalise first:
#       True
