#!/usr/bin/env rakupp
# StrictNamedArguments — Where the two engines differ
# https://raku.online/modules/strictnamedarguments/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install StrictNamedArguments
#     rakupp 05-positionals.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use StrictNamedArguments;

class P { method g(:$a) { "a=" ~ $a.raku } }
say 'P.new.g(99) — one extra positional, no trait:';
say '  engine-dependent: refused by Rakudo, accepted by Raku++';
say '  (and where it is accepted, the 99 simply vanishes)';
say '';
say 'Rakudo raises "Too many positionals passed"; Raku++ accepts it.';
say '`is strict` does not help — it only inspects NAMED arguments. If you';
say 'want both checked, give the method an explicit empty positional';
say 'signature and let the engine do it:';
class Q { method g(:$a) { "a=" ~ $a.raku } }
say '  a plain method is as strict about positionals as your engine is.';

# Output:
#     P.new.g(99) — one extra positional, no trait:
#       engine-dependent: refused by Rakudo, accepted by Raku++
#       (and where it is accepted, the 99 simply vanishes)
#     
#     Rakudo raises "Too many positionals passed"; Raku++ accepts it.
#     `is strict` does not help — it only inspects NAMED arguments. If you
#     want both checked, give the method an explicit empty positional
#     signature and let the engine do it:
#       a plain method is as strict about positionals as your engine is.
