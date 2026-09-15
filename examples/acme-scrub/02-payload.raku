#!/usr/bin/env rakupp
# Acme::Scrub — How the payload is built
# https://raku.online/modules/acme-scrub/#how-the-payload-is-built
#
# Install what it needs, then run it:
#     rakupp install Acme::Scrub
#     rakupp 02-payload.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

say 'the two characters it uses:';
say '  U+FEFF ZERO WIDTH NO-BREAK SPACE -> ',
    "\c[ZERO WIDTH NO-BREAK SPACE]".encode('utf8').list.map({ .fmt('%02X') }).join(' ');
say '  U+200B ZERO WIDTH SPACE          -> ',
    "\c[ZERO WIDTH SPACE]".encode('utf8').list.map({ .fmt('%02X') }).join(' ');
say '';
say 'one pair per BIT of the UTF-8 source, so the file grows by';
say 'a factor of about 24 — three bytes per character, eight bits per byte.';

# Output:
#     the two characters it uses:
#       U+FEFF ZERO WIDTH NO-BREAK SPACE -> EF BB BF
#       U+200B ZERO WIDTH SPACE          -> E2 80 8B
#     
#     one pair per BIT of the UTF-8 source, so the file grows by
#     a factor of about 24 — three bytes per character, eight bits per byte.
