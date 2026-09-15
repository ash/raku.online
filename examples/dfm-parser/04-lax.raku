#!/usr/bin/env rakupp
# DFM::Parser — What the grammar does not check
# https://raku.online/modules/dfm-parser/#what-the-grammar-does-not-check
#
# Install what it needs, then run it:
#     rakupp install DFM::Parser
#     rakupp 04-lax.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DFM::Parser;

my %cases =
    'spaced slashes'     => "object A / TA\nend\n",
    'nine on rank one'   => "object A: TA\n  X = 1\nend\n",
    'seven ranks only'   => "object A: TA\nend\n",
    'dotted name'        => "object A: TA\n  Font.Height = -11\nend\n",
    'hashtag char'       => "object A: TA\n  S = #65#66\nend\n";
for %cases.keys.sort -> $k {
    say sprintf('  %-20s -> %s', $k,
                DFM::Parser.parse(%cases{$k}).defined ?? 'parses' !! 'no parse');
}
say '';
say 'TOP accepts exactly ONE object and is not anchored for leading';
say 'comments, so a real file with a header or two top-level objects will';
say 'not parse either.';

# Output:
#       dotted name          -> parses
#       hashtag char         -> parses
#       nine on rank one     -> parses
#       seven ranks only     -> parses
#       spaced slashes       -> no parse
#     
#     TOP accepts exactly ONE object and is not anchored for leading
#     comments, so a real file with a header or two top-level objects will
#     not parse either.
