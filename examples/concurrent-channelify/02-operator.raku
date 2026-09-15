#!/usr/bin/env rakupp
# Concurrent::Channelify — The operator
# https://raku.online/modules/concurrent-channelify/#the-operator
#
# Install what it needs, then run it:
#     rakupp install Concurrent::Channelify
#     rakupp 02-operator.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Concurrent::Channelify;

say 'the module imports a sub and a postfix operator,';
say 'both bound to the same routine.';
say '';
my @a = 1 .. 5;
say 'the sub form : ', channelify(@a).list.sort.join(' ');

# Output:
#     the module imports a sub and a postfix operator,
#     both bound to the same routine.
#     
#     the sub form : 1 2 3 4 5
