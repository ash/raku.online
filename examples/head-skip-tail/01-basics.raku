#!/usr/bin/env rakupp
# head-skip-tail — The three subs
# https://raku.online/modules/head-skip-tail/#the-three-subs
#
# Install what it needs, then run it:
#     rakupp install head-skip-tail
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use head-skip-tail;

my @a = ^10;
say 'head   4 : ', head(4, @a);
say 'head *-4 : ', head(*-4, @a);
say 'skip   4 : ', skip(4, @a);
say 'skip *-4 : ', skip(*-4, @a);
say 'tail   4 : ', tail(4, @a);
say 'tail *-4 : ', tail(*-4, @a);
say '';
say 'each is a proto (Mu, |) with one multi ($n, +values) that delegates';
say 'to the matching method on the list.';

# Output:
#     head   4 : (0 1 2 3)
#     head *-4 : (0 1 2 3 4 5)
#     skip   4 : (4 5 6 7 8 9)
#     skip *-4 : (6 7 8 9)
#     tail   4 : (6 7 8 9)
#     tail *-4 : (4 5 6 7 8 9)
#     
#     each is a proto (Mu, |) with one multi ($n, +values) that delegates
#     to the matching method on the list.
