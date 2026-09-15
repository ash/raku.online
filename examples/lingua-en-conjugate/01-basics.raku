#!/usr/bin/env rakupp
# Lingua::EN::Conjugate — Conjugating
# https://raku.online/modules/lingua-en-conjugate/#conjugating
#
# Install what it needs, then run it:
#     rakupp install Lingua::EN::Conjugate
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::EN::Conjugate;

sub phrase(*%a) { conjugate(|%a).join(' ') }

say phrase(:bare<run>,  :subject<I>);
say phrase(:bare<run>,  :subject<he>);
say phrase(:bare<run>,  :subject<he>, :tense<sp>);
say phrase(:bare<go>,   :subject<she>, :tense<sp>, :forms['HaveEn']);
say phrase(:bare<eat>,  :subject<they>, :mod<will>, :forms['HaveEn', 'BeIng']);
say phrase(:bare<see>,  :subject<you>,  :tense<sp>, :forms['BeEn']);
say phrase(:bare<be>,   :subject<I>);
say phrase(:bare<have>, :subject<he>);

# Output:
#     I run
#     he runs
#     he ran
#     she had gone
#     they will have been eating
#     you were seen
#     I am
#     he has
