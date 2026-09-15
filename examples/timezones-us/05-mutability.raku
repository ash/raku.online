#!/usr/bin/env rakupp
# Timezones::US — Where the two engines differ
# https://raku.online/modules/timezones-us/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Timezones::US
#     rakupp 05-mutability.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Timezones::US;

# read them, copy them, and never write through the exported name
my %mine = %tzones.keys.map({ $_ => %tzones{$_}<name> });
say 'a copy is yours to change:';
%mine<cst> = 'Central (mine)';
say '  %mine<cst>   : ', %mine<cst>;
say '  %tzones<cst> : ', %tzones<cst><name>, '   — untouched';
say '';
say 'Rakudo refuses a write through %tzones with X::Assignment::RO;';
say 'Raku++ accepts it and the change is visible to every other consumer';
say 'for the rest of the process. Copy first.';

# Output:
#     a copy is yours to change:
#       %mine<cst>   : Central (mine)
#       %tzones<cst> : Central   — untouched
#     
#     Rakudo refuses a write through %tzones with X::Assignment::RO;
#     Raku++ accepts it and the change is visible to every other consumer
#     for the rest of the process. Copy first.
