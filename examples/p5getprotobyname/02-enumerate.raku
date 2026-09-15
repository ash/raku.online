#!/usr/bin/env rakupp
# P5getprotobyname — Enumerating
# https://raku.online/modules/p5getprotobyname/#enumerating
#
# Install what it needs, then run it:
#     rakupp install P5getprotobyname
#     rakupp 02-enumerate.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getprotobyname;

say 'setprotoent : ', setprotoent(0);
my $n = 0;
loop { my @e = getprotoent() or last; $n++ }
say 'endprotoent : ', endprotoent();
say 'entries walked : ', $n > 0;

# Output:
#     setprotoent : 1
#     endprotoent : 1
#     entries walked : True
