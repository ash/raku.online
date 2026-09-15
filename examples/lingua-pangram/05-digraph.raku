#!/usr/bin/env rakupp
# Lingua::Pangram — Where the two engines differ
# https://raku.online/modules/lingua-pangram/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Lingua::Pangram
#     rakupp 05-digraph.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Pangram;

say 'pangram("the cap", <ch>)     = ', pangram('the cap', <ch>),
    '   <- requires "c" and "h" separately: both present';
say 'pangram("the cap", ("ch",))  = ', pangram('the cap', ('ch',)),
    '   <- requires the substring "ch": absent';
say '';
say 'and an empty requirement is vacuously true, while an empty text is not:';
say '  pangram("anything", ())  = ', pangram('anything', ());
say '  pangram-en("")           = ', pangram-en('');

# Output:
#     pangram("the cap", <ch>)     = True   <- requires "c" and "h" separately: both present
#     pangram("the cap", ("ch",))  = False   <- requires the substring "ch": absent
#     
#     and an empty requirement is vacuously true, while an empty text is not:
#       pangram("anything", ())  = True
#       pangram-en("")           = False
