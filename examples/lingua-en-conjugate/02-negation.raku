#!/usr/bin/env rakupp
# Lingua::EN::Conjugate — Conjugating
# https://raku.online/modules/lingua-en-conjugate/#conjugating
#
# Install what it needs, then run it:
#     rakupp install Lingua::EN::Conjugate
#     rakupp 02-negation.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::EN::Conjugate;

sub phrase(*%a) { conjugate(|%a).join(' ') }

say 'negated        : ', phrase(:bare<run>, :subject<he>, :negation);
say 'contracted     : ', phrase(:bare<run>, :subject<he>, :negation, :shortneg);
say 'question       : ', phrase(:bare<run>, :subject<he>, :interrogative);
say 'both, short    : ', phrase(:bare<go>, :subject<you>, :negation, :shortneg, :interrogative);
say 'both, long     : ', phrase(:bare<go>, :subject<you>, :negation, :interrogative);
say '';
say 'the last line is ungrammatical — without :shortneg the question';
say 'word order is wrong. Use :shortneg with :interrogative.';

# Output:
#     negated        : he does not run
#     contracted     : he doesn't run
#     question       : does he run
#     both, short    : don't you go
#     both, long     : do not you go
#     
#     the last line is ungrammatical — without :shortneg the question
#     word order is wrong. Use :shortneg with :interrogative.
