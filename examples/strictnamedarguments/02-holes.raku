#!/usr/bin/env rakupp
# StrictNamedArguments — Two holes in the guard
# https://raku.online/modules/strictnamedarguments/#two-holes-in-the-guard
#
# Install what it needs, then run it:
#     rakupp install StrictNamedArguments
#     rakupp 02-holes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use StrictNamedArguments;

class Guarded { method go(:$a) is strict { "a=" ~ $a.raku } }
say 'the implicit *%_ contributes the NAME "_", so :_ is always accepted:';
say '  .go(:_(9)) -> ', Guarded.new.go(:_(9));
say '';
class Slurpy { method go(:$rest, *%more) is strict { "rest=" ~ $rest.raku } }
my $r = try Slurpy.new.go(rest => 1, zz => 2);
say 'and an EXPLICIT *%more slurpy is refused everything but :rest:';
say '  .go(rest => 1, zz => 2) -> ', $! ?? 'refused' !! $r;
say '';
say 'so the trait makes an explicit slurpy unusable, and leaves one';
say 'undeclared named argument permanently open.';

# Output:
#     the implicit *%_ contributes the NAME "_", so :_ is always accepted:
#       .go(:_(9)) -> a=Any
#     
#     and an EXPLICIT *%more slurpy is refused everything but :rest:
#       .go(rest => 1, zz => 2) -> refused
#     
#     so the trait makes an explicit slurpy unusable, and leaves one
#     undeclared named argument permanently open.
