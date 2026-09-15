#!/usr/bin/env rakupp
# Lingua::EN::Conjugate — The guard you will hit first
# https://raku.online/modules/lingua-en-conjugate/#the-guard-you-will-hit-first
#
# Install what it needs, then run it:
#     rakupp install Lingua::EN::Conjugate
#     rakupp 03-guard.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::EN::Conjugate;

for <p sp i bi ing pp> -> $t {
    say sprintf('  tense=%-4s -> %s', $t,
                conjugate(:bare<go>, :subject<he>, :tense($t)).join(' '));
}
say '';
say '  subject=Bob -> ', conjugate(:bare<go>, :subject<Bob>).join(' ');
say '';
say 'so :tense<ing>, :tense<pp> and any non-pronoun subject give you the';
say 'bare verb back, with no error. Use :alias for a name — but note that';
say 'AGREEMENT still follows :subject:';
say '  he  + alias Bob -> ', conjugate(:bare<run>, :subject<he>,   :alias<Bob>).join(' ');
say '  they+ alias Bob -> ', conjugate(:bare<run>, :subject<they>, :alias<Bob>).join(' ');

# Output:
#       tense=p    -> he goes
#       tense=sp   -> he went
#       tense=i    -> go
#       tense=bi   -> go
#       tense=ing  -> go
#       tense=pp   -> go
#     
#       subject=Bob -> go
#     
#     so :tense<ing>, :tense<pp> and any non-pronoun subject give you the
#     bare verb back, with no error. Use :alias for a name — but note that
#     AGREEMENT still follows :subject:
#       he  + alias Bob -> Bob runs
#       they+ alias Bob -> Bob run
