#!/usr/bin/env rakupp
# Lingua::Lipogram — Asking
# https://raku.online/modules/lingua-lipogram/#asking
#
# Install what it needs, then run it:
#     rakupp install Lingua::Lipogram
#     rakupp 02-empty.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Lipogram;

say q{lipogram('anything', '')  = }, lipogram('anything', '');
say q{lipogram('anything', ())  = }, lipogram('anything', ());
say '';
say 'the five candidates take (Str|IO::Path) x (Str|Range|Positional),';
say 'minus the IO::Path + Positional combination, which does not exist.';

# Output:
#     lipogram('anything', '')  = True
#     lipogram('anything', ())  = True
#     
#     the five candidates take (Str|IO::Path) x (Str|Range|Positional),
#     minus the IO::Path + Positional combination, which does not exist.
