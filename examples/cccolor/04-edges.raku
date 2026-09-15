#!/usr/bin/env rakupp
# CCColor — Where the two engines differ
# https://raku.online/modules/cccolor/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install CCColor
#     rakupp 04-edges.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use CCColor;

say 'an empty string prints two diagnostics — to STDOUT, which will';
say 'corrupt a program whose stdout is data — and answers black:';
say '  hex2rgba("") -> [', hex2rgba('').map({ ($_ * 255).round }).join(' '), ']';
say '';
say 'the portable wrapper:';
sub rgba(Str:D $raw) {
    my $h = $raw.subst(/\s/, '', :g).subst(/^'#'/, '').uc;
    die "not hex: $raw" unless $h ~~ /^ <[0..9A..F]>+ $/;
    die "wrong length: $raw" unless $h.chars == 6 | 8;
    hex2rgba($h)
}
for '#ff8800', '  #FF8800  ', '#GG0000', '#F80' -> $raw {
    my $r = try rgba($raw);
    say sprintf('  %-14s -> %s', $raw.raku,
                $! ?? $!.message !! '[' ~ $r.map({ ($_ * 255).round }).join(' ') ~ ']');
}

# Output:
#     an empty string prints two diagnostics — to STDOUT, which will
#     corrupt a program whose stdout is data — and answers black:
#     Error: ill hex string
#     Error: ill hex string
#       hex2rgba("") -> [0 0 0 255]
#     
#     the portable wrapper:
#       "#ff8800"      -> [255 136 0 255]
#       "  #FF8800  "  -> [255 136 0 255]
#       "#GG0000"      -> not hex: #GG0000
#       "#F80"         -> wrong length: #F80
