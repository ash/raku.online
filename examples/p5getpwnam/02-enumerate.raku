#!/usr/bin/env rakupp
# P5getpwnam — Enumerating
# https://raku.online/modules/p5getpwnam/#enumerating
#
# Install what it needs, then run it:
#     rakupp install P5getpwnam
#     rakupp 02-enumerate.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getpwnam;

say 'setpwent : ', setpwent();
my $n = 0;
loop { my @e = getpwent() or last; $n++ }
say 'endpwent : ', endpwent();
say 'entries walked : ', $n > 0;

# Output:
#     setpwent : 1
#     endpwent : 1
#     entries walked : True
