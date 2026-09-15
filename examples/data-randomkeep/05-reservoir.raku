#!/usr/bin/env rakupp
# Data::RandomKeep — Where the two engines differ
# https://raku.online/modules/data-randomkeep/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Data::RandomKeep
#     rakupp 05-reservoir.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::RandomKeep;

my $short = 0;
my $with-any = 0;
for ^2000 {
    my $k = Data::RandomKeep.new(3);
    $k.offer($_) for ^10;
    my @kept = $k.kept;
    $short++ unless @kept.elems == 3;
    $with-any++ if @kept.grep({ !.defined });
}
say '2000 draws of keep-3-from-10:';
say '  draws that came back short      : ', $short;
say '  draws containing an undefined   : ', $with-any;
say '';
say 'both zero on both engines. A keep-1 reservoir always indexed slot 0,';
say 'which is why the old bug never showed in the obvious first test.';

# Output:
#     2000 draws of keep-3-from-10:
#       draws that came back short      : 0
#       draws containing an undefined   : 0
#     
#     both zero on both engines. A keep-1 reservoir always indexed slot 0,
#     which is why the old bug never showed in the obvious first test.
