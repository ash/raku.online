#!/usr/bin/env rakupp
# IDNA::Punycode — The one thing to know
# https://raku.online/modules/idna-punycode/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install IDNA::Punycode
#     rakupp 02-whole-domain.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use IDNA::Punycode;

say encode_punycode('münchen.de');
say decode_punycode(encode_punycode('münchen.de'));
say 'münchen.de'.split('.').map({ encode_punycode($_) }).join('.');
say decode_punycode('XN--MNCHEN-3YA');

# Output:
#     xn--mnchen.de-q9a
#     münchen.de
#     xn--mnchen-3ya.de
#     XN--MNCHEN-3YA
