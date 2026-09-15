#!/usr/bin/env rakupp
# Locale::US — Looking up
# https://raku.online/modules/locale-us/#looking-up
#
# Install what it needs, then run it:
#     rakupp install Locale::US
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Locale::US;

say 'code-to-state("CA")         : ', code-to-state('CA').raku;
say 'code-to-state("ca")         : ', code-to-state('ca').raku;
say 'state-to-code("California") : ', state-to-code('California').raku;
say 'state-to-code("CALIFORNIA") : ', state-to-code('CALIFORNIA').raku;
say '';
say 'both lookups upper-case their argument, so input case does not matter.';
say 'every NAME comes back shouted — there is no display-cased form anywhere';
say 'in the module.';
say '';
say 'a miss is an undefined value, not an exception:';
say '  code-to-state("ZZ").defined : ', code-to-state('ZZ').defined;
say '  state-to-code("Atlantis")   : ', state-to-code('Atlantis').defined;

# Output:
#     code-to-state("CA")         : "CALIFORNIA"
#     code-to-state("ca")         : "CALIFORNIA"
#     state-to-code("California") : "CA"
#     state-to-code("CALIFORNIA") : "CA"
#     
#     both lookups upper-case their argument, so input case does not matter.
#     every NAME comes back shouted — there is no display-cased form anywhere
#     in the module.
#     
#     a miss is an undefined value, not an exception:
#       code-to-state("ZZ").defined : False
#       state-to-code("Atlantis")   : False
