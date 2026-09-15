#!/usr/bin/env rakupp
# Lingua::EN::Conjugate — Where the two engines differ
# https://raku.online/modules/lingua-en-conjugate/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Lingua::EN::Conjugate
#     rakupp 06-mod.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::EN::Conjugate;

# the portable spellings
say 'with :mod<will>   : ', conjugate(:bare<go>, :subject<she>, :mod<will>).join(' ');
say 'with mod => "may" : ', conjugate(:bare<go>, :subject<she>, mod => 'may').join(' ');
say '';
say 'the tight `mod=>"will"` does not parse under Raku++ — `mod`, `div`,';
say '`gcd` and `lcm` are read as operators in term position there. Put a';
say 'space in, or use the colonpair form.';
say '';
say 'an unknown modal is silent on both engines:';
say '  :mod<must> -> ', conjugate(:bare<go>, :subject<she>, :mod<must>).raku;
say '  an Any is pushed into the word list.';

# Output:
#     with :mod<will>   : she will go
#     with mod => "may" : she may go
#     
#     the tight `mod=>"will"` does not parse under Raku++ — `mod`, `div`,
#     `gcd` and `lcm` are read as operators in term position there. Put a
#     space in, or use the colonpair form.
#     
#     an unknown modal is silent on both engines:
#       :mod<must> -> ["she", Any, "go"]
#       an Any is pushed into the word list.
