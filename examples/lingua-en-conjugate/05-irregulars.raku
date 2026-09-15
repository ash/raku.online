#!/usr/bin/env rakupp
# Lingua::EN::Conjugate — The one thing to know
# https://raku.online/modules/lingua-en-conjugate/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Lingua::EN::Conjugate
#     rakupp 05-irregulars.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::EN::Conjugate;

for <know stride leap bear get dive burn> -> $v {
    say sprintf('  %-8s sp: %-14s pp: %s', $v,
        conjugate(:bare($v), :subject<he>, :tense<sp>).join(' '),
        conjugate(:bare($v), :subject<he>, :tense<sp>, :forms['HaveEn']).join(' '));
}
say '';
say 'know -> "had know": the participle field is missing its n.';
say 'the table also mixes dialects without saying so — gotten and dove are';
say 'American, burnt and travelling British.';

# Output:
#       know     sp: he knew        pp: he had know
#       stride   sp: he strod       pp: he had stridden
#       leap     sp: he lept        pp: he had lept
#       bear     sp: he bore        pp: he had born
#       get      sp: he got         pp: he had gotten
#       dive     sp: he dove        pp: he had dived
#       burn     sp: he burnt       pp: he had burnt
#     
#     know -> "had know": the participle field is missing its n.
#     the table also mixes dialects without saying so — gotten and dove are
#     American, burnt and travelling British.
