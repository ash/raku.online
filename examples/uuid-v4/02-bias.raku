#!/usr/bin/env rakupp
# UUID::V4 — The one thing to know
# https://raku.online/modules/uuid-v4/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install UUID::V4
#     rakupp 02-bias.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use UUID::V4;

my %seen;
for ^500 {
    my $hex = uuid-v4().subst('-', '', :g);
    # index 12 is the version nibble and 16 the variant: both are fixed
    for ^32 -> $i { next if $i == 12 | 16; %seen{$hex.substr($i, 1)}++ }
}

say 'digits that occur: ', %seen.keys.sort.join('');
say 'digits that never: ', (flat '0'..'9', 'a'..'f').grep({ !%seen{$_} }).join('');

# Output:
#     digits that occur: 0123456789
#     digits that never: abcdef
