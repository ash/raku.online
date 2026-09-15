#!/usr/bin/env rakupp
# CCColor — The one thing to know
# https://raku.online/modules/cccolor/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install CCColor
#     rakupp 02-lowercase.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use CCColor;

for '#FF8800', '#ff8800', '#AABBCC', '#aabbcc' -> $hex {
    say sprintf('  %-12s -> [%s]', $hex,
                hex2rgba($hex).map({ ($_ * 255).round }).join(' '));
}
say '';
say 'the validator tests a character with `$c cmp "F"` and rejects anything';
say 'that sorts higher. That is correct for G..Z and catastrophic for a..f,';
say 'whose codepoints (97..102) all sort above "F" (70).';
say '';
say 'the first rejected pair aborts the scan with `last`, so every channel';
say 'keeps its default "0" and alpha keeps 0xFF — opaque black, no';
say 'exception, no return code, and the diagnostic sits behind an';
say 'unreachable debug flag. Lowercase is the dominant CSS convention.';
say '';
say 'upper-case at the call site:';
sub rgba(Str $hex) { hex2rgba($hex.uc) }
say '  rgba("#ff8800") -> [', rgba('#ff8800').map({ ($_ * 255).round }).join(' '), ']';

# Output:
#       #FF8800      -> [255 136 0 255]
#       #ff8800      -> [0 0 0 255]
#       #AABBCC      -> [170 187 204 255]
#       #aabbcc      -> [0 0 0 255]
#     
#     the validator tests a character with `$c cmp "F"` and rejects anything
#     that sorts higher. That is correct for G..Z and catastrophic for a..f,
#     whose codepoints (97..102) all sort above "F" (70).
#     
#     the first rejected pair aborts the scan with `last`, so every channel
#     keeps its default "0" and alpha keeps 0xFF — opaque black, no
#     exception, no return code, and the diagnostic sits behind an
#     unreachable debug flag. Lowercase is the dominant CSS convention.
#     
#     upper-case at the call site:
#       rgba("#ff8800") -> [255 136 0 255]
