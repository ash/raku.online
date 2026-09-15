#!/usr/bin/env rakupp
# P5getgrnam — Walking the database
# https://raku.online/modules/p5getgrnam/#walking-the-database
#
# Install what it needs, then run it:
#     rakupp install P5getgrnam
#     rakupp 02-enumerate.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getgrnam;

say 'setgrent : ', setgrent();
my ($n, $widest) = 0, 0;
loop {
    my @e = getgrent() or last;
    $n++;
    $widest = @e.elems if @e.elems > $widest;
}
say 'endgrent : ', endgrent();
say '';
say 'entries walked         : ', $n > 0;
say 'every entry had 4 fields : ', $widest == 4;

# Output:
#     setgrent : 1
#     endgrent : 1
#     
#     entries walked         : True
#     every entry had 4 fields : True
