#!/usr/bin/env rakupp
# Lingua::Stem::Es — Stemming
# https://raku.online/modules/lingua-stem-es/#stemming
#
# Install what it needs, then run it:
#     rakupp install Lingua::Stem::Es
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Stem::Es;

for <gato gata gatos gatas casa libro> -> $w {
    say sprintf('  %-12s -> %s', $w, stem($w));
}
say '';
for <hablar hablo hablamos hablando hablado hablaría> -> $w {
    say sprintf('  %-12s -> %s', $w, stem($w));
}
say '';
for <nacionalismo nacional nacionalidad nacionalizar> -> $w {
    say sprintf('  %-14s -> %s', $w, stem($w));
}
say '';
say 'case and punctuation are handled:';
for 'Casa', 'CASA', 'casa,', '¡Hola!' -> $w {
    say sprintf('  %-10s -> %s', $w.raku, stem($w));
}

# Output:
#       gato         -> gat
#       gata         -> gat
#       gatos        -> gat
#       gatas        -> gat
#       casa         -> cas
#       libro        -> libr
#     
#       hablar       -> habl
#       hablo        -> habl
#       hablamos     -> habl
#       hablando     -> habl
#       hablado      -> habl
#       hablaría     -> habl
#     
#       nacionalismo   -> nacional
#       nacional       -> nacional
#       nacionalidad   -> nacional
#       nacionalizar   -> nacionaliz
#     
#     case and punctuation are handled:
#       "Casa"     -> cas
#       "CASA"     -> cas
#       "casa,"    -> cas
#       "¡Hola!"   -> hol
