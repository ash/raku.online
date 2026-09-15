#!/usr/bin/env rakupp
# Lingua::EN::Conjugate — The one thing to know
# https://raku.online/modules/lingua-en-conjugate/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Lingua::EN::Conjugate
#     rakupp 04-doubling.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::EN::Conjugate;

say 'progressive (should double the final consonant):';
for <run sit get put stop plan begin travel> -> $v {
    say sprintf('  %-8s -> %s', $v,
                conjugate(:bare($v), :subject<I>, :forms['BeIng']).join(' '));
}
say '';
say 'simple past, same rule:';
for <hug plan offer visit open benefit> -> $v {
    say sprintf('  %-8s -> %s', $v,
                conjugate(:bare($v), :subject<he>, :tense<sp>).join(' '));
}
say '';
say 'the rule is / (.+ <consonant> <stressedw>) (<consonant>) $$/ — the `.+`';
say 'demands a character BEFORE the C-V-C, so the shortest verb it can fire';
say 'on is four letters. It is stress-blind in the other direction too,';
say 'which is where offerred, visitted and openned come from.';

# Output:
#     progressive (should double the final consonant):
#       run      -> I am runing
#       sit      -> I am siting
#       get      -> I am geting
#       put      -> I am puting
#       stop     -> I am stopping
#       plan     -> I am planning
#       begin    -> I am beginning
#       travel   -> I am travelling
#     
#     simple past, same rule:
#       hug      -> he huged
#       plan     -> he planned
#       offer    -> he offerred
#       visit    -> he visitted
#       open     -> he openned
#       benefit  -> he benefitted
#     
#     the rule is / (.+ <consonant> <stressedw>) (<consonant>) $$/ — the `.+`
#     demands a character BEFORE the C-V-C, so the shortest verb it can fire
#     on is four letters. It is stress-blind in the other direction too,
#     which is where offerred, visitted and openned come from.
