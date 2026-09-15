#!/usr/bin/env rakupp
# X::Intl — Where the two engines differ
# https://raku.online/modules/x-intl/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install X::Intl
#     rakupp 04-sibling.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use X::Intl;
use CX::Warn::Intl;

say 'both roles, both explicitly used:';
say '  X::Intl        : ', X::Intl.^name;
say '  CX::Warn::Intl : ', CX::Warn::Intl.^name;
say '';
say 'Raku++ additionally makes CX::Warn::Intl visible after `use X::Intl`';
say 'alone, because a `use` of one unit there resolves a sibling unit of';
say 'the same distribution. Rakudo does not. Write both `use` lines.';
say '';
say 'introspecting the role groups is not portable either —';
say 'X::Intl.^parents is ("Exception",) on Raku++ and empty on Rakudo.';
say 'Check with ~~ instead.';

# Output:
#     both roles, both explicitly used:
#       X::Intl        : X::Intl
#       CX::Warn::Intl : CX::Warn::Intl
#     
#     Raku++ additionally makes CX::Warn::Intl visible after `use X::Intl`
#     alone, because a `use` of one unit there resolves a sibling unit of
#     the same distribution. Rakudo does not. Write both `use` lines.
#     
#     introspecting the role groups is not portable either —
#     X::Intl.^parents is ("Exception",) on Raku++ and empty on Rakudo.
#     Check with ~~ instead.
