#!/usr/bin/env rakupp
# as-cli-arguments — Where the two engines differ
# https://raku.online/modules/as-cli-arguments/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install as-cli-arguments
#     rakupp 05-named-anywhere.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use as-cli-arguments;

# pass it explicitly and both engines agree
my $c = \('pos', :n<1>);
say 'default            : ', as-cli-arguments($c).raku;
say ':named-anywhere    : ', as-cli-arguments($c, :named-anywhere).raku;
say '';
say 'setting %*SUB-MAIN-OPTS<named-anywhere> works on Rakudo and is';
say 'invisible to Raku++, because a dynamic variable read in a PARAMETER';
say 'DEFAULT does not see the caller`s frame there. Reading it directly';
say 'inside a routine body works on both.';
say '';
say 'so: pass :named-anywhere at the call site rather than relying on the';
say 'dynamic variable.';

# Output:
#     default            : "--n=1 pos"
#     :named-anywhere    : "pos --n=1"
#     
#     setting %*SUB-MAIN-OPTS<named-anywhere> works on Rakudo and is
#     invisible to Raku++, because a dynamic variable read in a PARAMETER
#     DEFAULT does not see the caller`s frame there. Reading it directly
#     inside a routine body works on both.
#     
#     so: pass :named-anywhere at the call site rather than relying on the
#     dynamic variable.
