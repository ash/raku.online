#!/usr/bin/env rakupp
# Hash::Ordered — Insertion order, through the ordinary syntax
# https://raku.online/modules/hash-ordered/#insertion-order-through-the-ordinary-syntax
#
# Install what it needs, then run it:
#     rakupp install Hash::Ordered
#     rakupp 02-copying.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Hash::Ordered;

my %source is Hash::Ordered;
%source{$_} = $_.uc for <zebra apple mango>;

my %kept is Hash::Ordered = %source;
say %kept.keys.join(',');

my %plain = %source;
say %plain.^name;
say %source.keys.join(',');

# Output:
#     zebra,apple,mango
#     Hash
#     zebra,apple,mango
