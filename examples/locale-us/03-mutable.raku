#!/usr/bin/env rakupp
# Locale::US — Where the two engines differ
# https://raku.online/modules/locale-us/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Locale::US
#     rakupp 03-mutable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Locale::US;

# always copy before you touch it
my @codes = all-state-codes.List;
my @names = all-state-names.List;
say 'a copy is safe on both engines : ', @codes.elems, ' codes, ', @names.elems, ' names';
@codes[0] = 'QQ';
say '  my copy now starts ', @codes[0];
say '  the module still says ', all-state-codes[0];
say '';
say 'Rakudo refuses a write through all-state-codes()[0] with';
say 'X::Assignment::RO. Raku++ accepts it, and a FRESH all-state-codes()';
say 'call then returns the damaged value for the rest of the process.';
say '';
say 'the same difference reaches the miss case:';
say '  code-to-state("ZZ") is Any on Raku++ and Nil on Rakudo.';
say '  .defined is False either way, so // works — but .raku, `with`, and';
say '  assignment into a typed variable do not agree. Use //.';
my $name = code-to-state('ZZ') // 'UNKNOWN';
say '  code-to-state("ZZ") // "UNKNOWN" = ', $name;

# Output:
#     a copy is safe on both engines : 59 codes, 59 names
#       my copy now starts QQ
#       the module still says AK
#     
#     Rakudo refuses a write through all-state-codes()[0] with
#     X::Assignment::RO. Raku++ accepts it, and a FRESH all-state-codes()
#     call then returns the damaged value for the rest of the process.
#     
#     the same difference reaches the miss case:
#       code-to-state("ZZ") is Any on Raku++ and Nil on Rakudo.
#       .defined is False either way, so // works — but .raku, `with`, and
#       assignment into a typed variable do not agree. Use //.
#       code-to-state("ZZ") // "UNKNOWN" = UNKNOWN
