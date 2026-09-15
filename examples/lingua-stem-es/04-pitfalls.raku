#!/usr/bin/env rakupp
# Lingua::Stem::Es — Two shapes that will bite you
# https://raku.online/modules/lingua-stem-es/#two-shapes-that-will-bite-you
#
# Install what it needs, then run it:
#     rakupp install Lingua::Stem::Es
#     rakupp 04-pitfalls.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Stem::Es;

say 'it is NOT idempotent — never feed a stem back in:';
my $once = stem('rápidamente');
say sprintf('  rápidamente -> %s -> %s', $once, stem($once));
say '';
say 'it is NOT a tokenizer — the whole string is treated as one word:';
say '  stem("la casa roja") = ', stem('la casa roja').raku;
say '';
say 'punctuation is DELETED, not split on:';
for 'e-mail', 'e-mails', 'anti-oso' -> $w {
    say sprintf('  %-10s -> %s', $w, stem($w));
}
say '';
say 'clitics come off only when the verb ending also falls inside RV:';
for <hablarle dándoselo cómpramelo vámonos> -> $w {
    say sprintf('  %-12s -> %s', $w, stem($w));
}

# Output:
#     it is NOT idempotent — never feed a stem back in:
#       rápidamente -> rapid -> rap
#     
#     it is NOT a tokenizer — the whole string is treated as one word:
#       stem("la casa roja") = "la casa roj"
#     
#     punctuation is DELETED, not split on:
#       e-mail     -> email
#       e-mails    -> emails
#       anti-oso   -> antios
#     
#     clitics come off only when the verb ending also falls inside RV:
#       hablarle     -> habl
#       dándoselo    -> dandosel
#       cómpramelo   -> compramel
#       vámonos      -> vamon
