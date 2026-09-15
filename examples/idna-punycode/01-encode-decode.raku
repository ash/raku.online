#!/usr/bin/env rakupp
# IDNA::Punycode — Both directions
# https://raku.online/modules/idna-punycode/#both-directions
#
# Install what it needs, then run it:
#     rakupp install IDNA::Punycode
#     rakupp 01-encode-decode.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use IDNA::Punycode;

for <münchen bücher ελλάς 日本語 россия> -> $label {
    my $encoded = encode_punycode($label);
    say $label, ' -> ', $encoded, ' -> ', decode_punycode($encoded);
}

say encode_punycode('example');
say decode_punycode('plain');

# Output:
#     münchen -> xn--mnchen-3ya -> münchen
#     bücher -> xn--bcher-kva -> bücher
#     ελλάς -> xn--hxarsa0b -> ελλάς
#     日本語 -> xn--wgv71a119e -> 日本語
#     россия -> xn--h1alffa9f -> россия
#     example
#     plain
