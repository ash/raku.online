#!/usr/bin/env rakupp
# allow-no — Where the two engines differ
# https://raku.online/modules/allow-no/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install allow-no
#     rakupp 04-core.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use allow-no;

say 'on Rakudo you have two routes:';
say '  my %*SUB-MAIN-OPTS = :allow-no;   # core';
say '  use allow-no;                     # this module';
say '';
say 'on Raku++ only the second works. The core dynamic variable is not';
say 'implemented, so a script relying on it prints its Usage block and';
say 'exits 2.';
say '';
say 'the portable spelling is to do both — they are idempotent together,';
say 'because the module rewrites --no-foo to --/foo and the core option';
say 'then finds nothing left to do:';
say '  my %*SUB-MAIN-OPTS = :allow-no;';
say '  use allow-no;';

# Output:
#     on Rakudo you have two routes:
#       my %*SUB-MAIN-OPTS = :allow-no;   # core
#       use allow-no;                     # this module
#     
#     on Raku++ only the second works. The core dynamic variable is not
#     implemented, so a script relying on it prints its Usage block and
#     exits 2.
#     
#     the portable spelling is to do both — they are idempotent together,
#     because the module rewrites --no-foo to --/foo and the core option
#     then finds nothing left to do:
#       my %*SUB-MAIN-OPTS = :allow-no;
#       use allow-no;
