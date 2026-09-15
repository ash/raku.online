#!/usr/bin/env rakupp
# P5getpriority — The one thing to know
# https://raku.online/modules/p5getpriority/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install P5getpriority
#     rakupp 03-minus-one-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getpriority;

constant PRIO_PROCESS = 0;

say 'a pid that does not exist:';
say '  getpriority(PRIO_PROCESS, 999999) = ', getpriority(PRIO_PROCESS, 999_999);
say '';
say 'a process niced to -1 would return exactly the same number,';
say 'and -1 is inside the legal range : ', -20 <= -1 <= 20;
say '';
say 'setpriority has the same ambiguity, except that 0 means success:';
say '  on a nonexistent pid : ', setpriority(PRIO_PROCESS, 999_999, 0);

# Output:
#     a pid that does not exist:
#       getpriority(PRIO_PROCESS, 999999) = -1
#     
#     a process niced to -1 would return exactly the same number,
#     and -1 is inside the legal range : True
#     
#     setpriority has the same ambiguity, except that 0 means success:
#       on a nonexistent pid : -1
