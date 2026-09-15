#!/usr/bin/env rakupp
# Doublephone — What the input can be
# https://raku.online/modules/doublephone/#what-the-input-can-be
#
# Install what it needs, then run it:
#     rakupp install Doublephone
#     rakupp 03-input.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Doublephone;

sub show($label, $in) {
    my ($p, $s) = double-metaphone($in);
    say sprintf('%-22s -> (%s, %s)', $label, $p.raku, $s.raku);
}

show 'empty string',    '';
show 'digits only',     '12345';
show 'lowercase',       'smith';
show 'mixed case',      'SmItH';
show 'hyphenated',      'Smith-Jones';
show 'leading spaces',  '  Smith';
show 'accented',        "Ren\c[LATIN SMALL LETTER E WITH ACUTE]e";
show 'Cyrillic',        "\c[CYRILLIC CAPITAL LETTER I]\c[CYRILLIC SMALL LETTER VE]";

# Output:
#     empty string           -> ("", "")
#     digits only            -> ("", "")
#     lowercase              -> ("SM0", "XMT")
#     mixed case             -> ("SM0", "XMT")
#     hyphenated             -> ("SM0J", "XMTJ")
#     leading spaces         -> ("SM0", "SMT")
#     accented               -> ("RN", "RN")
#     Cyrillic               -> ("", "")
