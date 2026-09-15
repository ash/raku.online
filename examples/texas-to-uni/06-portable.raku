#!/usr/bin/env rakupp
# Texas::To::Uni — Where the two engines differ
# https://raku.online/modules/texas-to-uni/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Texas::To::Uni
#     rakupp 06-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Texas::To::Uni;

# if you want a deterministic rewrite, supply a sorted table yourself:
# longest key first, so !(<=) is matched before (<=)
my %pairs = '!(<=)' => "\c[NEITHER A SUBSET OF NOR EQUAL TO]",
            '(<=)'  => "\c[SUBSET OF OR EQUAL TO]";
my $s = 'a !(<=) b; c (<=) d';
for %pairs.keys.sort({ -.chars }) -> $k {
    my $one = Map.new($k, %pairs{$k});
    convert-string($s, table => $one);
}
say 'deterministic on both engines : ', $s;
say '';
say 'everything else about this module — the substitutions themselves,';
say 'the file modes, the whitespace sensitivity — is identical on the two';
say 'engines. Only the iteration order is not.';

# Output:
#     deterministic on both engines : a ⊈ b; c ⊆ d
#     
#     everything else about this module — the substitutions themselves,
#     the file modes, the whitespace sensitivity — is identical on the two
#     engines. Only the iteration order is not.
