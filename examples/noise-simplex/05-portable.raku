#!/usr/bin/env rakupp
# Noise::Simplex — Where the two engines differ
# https://raku.online/modules/noise-simplex/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Noise::Simplex
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Noise::Simplex;

say 'one performance note: create-noise2d copies the 512-entry';
say 'permutation tables into a fresh closure on EVERY call. Build the';
say 'closure once, outside your loop:';
say '';
say '  my &n = Simplex.new(seed => $s).create-noise2d;   # once';
say '  for @points -> ($x, $y) { … n($x, $y) … }         # many';
say '';
my $s = Simplex.new(seed => 3);
my &n = $s.create-noise2d;
say 'a 400-sample heightmap row, quantised to five bands:';
say '  ', (^40).map({
    my $v = n($_ * 0.11, 0.5);
    <. - = # @>[ (($v + 1) / 2 * 4.999).Int ]
}).join;
say '';
say 'the permutation table itself is public, if you want to inspect it:';
say '  build-permutation-table gives ', $s.build-permutation-table.elems, ' entries.';

# Output:
#     one performance note: create-noise2d copies the 512-entry
#     permutation tables into a fresh closure on EVERY call. Build the
#     closure once, outside your loop:
#     
#       my &n = Simplex.new(seed => $s).create-noise2d;   # once
#       for @points -> ($x, $y) { … n($x, $y) … }         # many
#     
#     a 400-sample heightmap row, quantised to five bands:
#       ##==####==-=#@@@#=-----=#@@@@@@#=-.-===-
#     
#     the permutation table itself is public, if you want to inspect it:
#       build-permutation-table gives 512 entries.
