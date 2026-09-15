#!/usr/bin/env rakupp
# P5getpriority — Reading a priority
# https://raku.online/modules/p5getpriority/#reading-a-priority
#
# Install what it needs, then run it:
#     rakupp install P5getpriority
#     rakupp 01-priority.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getpriority;

constant PRIO_PROCESS = 0;   # from <sys/resource.h>
constant PRIO_PGRP    = 1;
constant PRIO_USER    = 2;

# "who = 0" means "me". The absolute value is not portable; the range is.
my $me = getpriority(PRIO_PROCESS, 0);
say 'own nice value is in -20..20 : ', -20 <= $me <= 20;
say 'own nice value is an Int     : ', $me ~~ Int;
say '';
say 'process-group priority in range : ', -20 <= getpriority(PRIO_PGRP, 0) <= 20;
say 'getppid is positive             : ', getppid() > 0;
say 'getpgrp is positive             : ', getpgrp() > 0;

# Output:
#     own nice value is in -20..20 : True
#     own nice value is an Int     : True
#     
#     process-group priority in range : True
#     getppid is positive             : True
#     getpgrp is positive             : True
