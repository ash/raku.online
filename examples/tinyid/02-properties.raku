#!/usr/bin/env rakupp
# TinyID — The properties that hold
# https://raku.online/modules/tinyid/#the-properties-that-hold
#
# Install what it needs, then run it:
#     rakupp install TinyID
#     rakupp 02-properties.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TinyID;

my @alphabet = ('a' .. 'z', 'A' .. 'Z', '0' .. '9').flat;
my $t = TinyID.new(key => @alphabet.pick(*).join);

say 'over a randomly shuffled 62-character key, for 0 .. 3000:';
say '  decode(encode(n)) == n : ',
    so (0 .. 3000).all.map({ $t.decode($t.encode($_)) == $_ });
say '  encode is injective    : ',
    (0 .. 3000).map({ $t.encode($_) }).unique.elems == 3001;
say '  output uses only the key`s characters : ',
    so (0 .. 3000).all.map({ $t.encode($_).comb ⊆ @alphabet });
say '';
say 'and the length boundaries are exactly base-62:';
say '  n < 62      all 1 char  : ', so (^62).all.map({ $t.encode($_).chars == 1 });
say '  62 <= n < 3844 all 2    : ', so (62 ..^ 3844).all.map({ $t.encode($_).chars == 2 });
say '';
say 'the module contains no randomness — encode and decode are pure';
say 'functions of (key, input). Only your CHOICE of key is usually random.';

# Output:
#     over a randomly shuffled 62-character key, for 0 .. 3000:
#       decode(encode(n)) == n : True
#       encode is injective    : True
#       output uses only the key`s characters : True
#     
#     and the length boundaries are exactly base-62:
#       n < 62      all 1 char  : True
#       62 <= n < 3844 all 2    : True
#     
#     the module contains no randomness — encode and decode are pure
#     functions of (key, input). Only your CHOICE of key is usually random.
