#!/usr/bin/env rakupp
# P5getpriority — Writing one
# https://raku.online/modules/p5getpriority/#writing-one
#
# Install what it needs, then run it:
#     rakupp install P5getpriority
#     rakupp 02-setpriority.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getpriority;

constant PRIO_PROCESS = 0;

# writing back the value already there is a no-op, and 0 means success
my $me = getpriority(PRIO_PROCESS, 0);
say 'setpriority to the current value : ', setpriority(PRIO_PROCESS, 0, $me);
say 'and it is unchanged              : ', getpriority(PRIO_PROCESS, 0) == $me;

# Output:
#     setpriority to the current value : 0
#     and it is unchanged              : True
