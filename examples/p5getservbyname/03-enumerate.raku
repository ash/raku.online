#!/usr/bin/env rakupp
# P5getservbyname — Enumerating
# https://raku.online/modules/p5getservbyname/#enumerating
#
# Install what it needs, then run it:
#     rakupp install P5getservbyname
#     rakupp 03-enumerate.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getservbyname;

say 'setservent : ', setservent(1);
my ($n, $widest) = 0, 0;
loop {
    my @e = getservent() or last;
    $n++;
    $widest = @e.elems if @e.elems > $widest;
}
say 'endservent : ', endservent();
say 'entries walked : ', $n > 0;
say 'every entry had four fields : ', $widest == 4;

# Output:
#     setservent : 1
#     endservent : 1
#     entries walked : True
#     every entry had four fields : True
