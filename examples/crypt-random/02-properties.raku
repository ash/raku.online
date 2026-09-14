#!/usr/bin/env rakupp
# Crypt::Random — Draws
# https://raku.online/modules/crypt-random/#draws
#
# Install what it needs, then run it:
#     rakupp install Crypt::Random
#     rakupp 02-properties.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Crypt::Random;
use Crypt::Random::Extra;

say crypt_random_buf(16).elems;
say so (^500).map({ crypt_random(2) }).all < 65536;
my @draws = (^3000).map({ crypt_random_uniform(6) });
say @draws.unique.sort.join(',');
say so @draws.Bag.values.all > 400;

my %seen;
for ^200 {
    my $hex = crypt_random_UUIDv4.subst('-', '', :g);
    for ^32 -> $i { next if $i == 12 | 16; %seen{$hex.substr($i, 1)}++ }
}
say %seen.keys.sort.join;

# Output:
#     16
#     True
#     0,1,2,3,4,5
#     True
#     0123456789abcdef
