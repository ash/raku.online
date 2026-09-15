#!/usr/bin/env rakupp
# Zodiac::Chinese — Where the two engines differ
# https://raku.online/modules/zodiac-chinese/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Zodiac::Chinese
#     rakupp 05-named.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Zodiac::Chinese;

my $r = try ChineseZodiac.new(year => 2020);
say 'ChineseZodiac.new(year => 2020) -> ', $! ?? 'refused' !! 'built an object';
say '';
say 'Rakudo refuses it — "Too few positionals passed". Raku++ silently binds';
say 'the missing required positional to its type object when any named';
say 'argument is present, so the method runs against an undefined DateTime';
say 'instead of raising. Pass the positional.';

# Output:
#     ChineseZodiac.new(year => 2020) -> refused
#     
#     Rakudo refuses it — "Too few positionals passed". Raku++ silently binds
#     the missing required positional to its type object when any named
#     argument is present, so the method runs against an undefined DateTime
#     instead of raising. Pass the positional.
