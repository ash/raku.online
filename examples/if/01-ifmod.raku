#!/usr/bin/env rakupp
# if — A conditional load
# https://raku.online/modules/if/#a-conditional-load
#
# Install what it needs, then run it:
#     rakupp install if
#     rakupp 01-ifmod.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

# The module named is only looked up when the condition is true. Here it is
# false, and the name is a distribution that does not exist anywhere — which
# is the whole point: a platform-only dependency costs nothing off-platform.
use if $*DISTRO.is-win, 'Win32::Only::Thing';

say 'running on windows : ', $*DISTRO.is-win;
say '';
say 'The statement above named a distribution that is not installed';
say 'and does not exist. With a false condition that is not an error,';
say 'not a warning, and not a lookup — the program simply continues.';

# Output:
#     running on windows : False
#     
#     The statement above named a distribution that is not installed
#     and does not exist. With a false condition that is not an error,
#     not a warning, and not a lookup — the program simply continues.
