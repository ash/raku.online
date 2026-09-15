#!/usr/bin/env rakupp
# LCS::All — Every alignment
# https://raku.online/modules/lcs-all/#every-alignment
#
# Install what it needs, then run it:
#     rakupp install LCS::All
#     rakupp 01-all.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use LCS::All;

sub show(@a, @b) {
    my @r = allLCS(@a, @b);
    say sprintf('%-18s %-18s', @a.join(''), @b.join(''));
    for @r[0].list -> $solution {
        say '  solution : ',
            $solution.elems
              ?? $solution.map({ "({.[0]},{.[1]})" }).join(' ')
              !! '(none)';
    }
}

show [<a b c>], [<a b c>];
show [<a b c>], [<a c b>];
show [<a b c d>], [<b d>];
show [<a b>], [<c d>];

# Output:
#     abc                abc               
#       solution : (0,0) (1,1) (2,2)
#     abc                acb               
#       solution : (0,0) (1,2)
#       solution : (0,0) (2,1)
#     abcd               bd                
#       solution : (1,0) (3,1)
#     ab                 cd                
#       solution : (none)
