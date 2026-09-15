#!/usr/bin/env rakupp
# Text::Lorem — The three methods
# https://raku.online/modules/text-lorem/#the-three-methods
#
# Install what it needs, then run it:
#     rakupp install Text::Lorem
#     rakupp 02-instance.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Lorem;

my $r = try Text::Lorem.words(3);
say 'Text::Lorem.words(3) without .new -> ', $! ?? 'threw' !! $r;
say 'Text::Lorem.new.words(3)          -> ', Text::Lorem.new.words(3).words.elems, ' words';

# Output:
#     Text::Lorem.words(3) without .new -> threw
#     Text::Lorem.new.words(3)          -> 3 words
