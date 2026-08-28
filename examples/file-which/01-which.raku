#!/usr/bin/env rakupp
# File::Which — What it is for
# https://raku.online/modules/file-which/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install File::Which
#     rakupp 01-which.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Which;

say which('ls');
say which('sh');
say which('definitely-not-a-program-2026').defined;

# Output:
#     /bin/ls
#     /bin/sh
#     False
