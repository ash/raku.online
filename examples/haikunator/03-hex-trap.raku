#!/usr/bin/env rakupp
# Haikunator — The one thing to know
# https://raku.online/modules/haikunator/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Haikunator
#     rakupp 03-hex-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Haikunator;

my @t = (^400).map({ haikunate(:tokenHex, :tokenChars('XYZ')).split('-')[*-1] });
say 'asked for an alphabet of XYZ, with :tokenHex also set';
say '  tokens containing X, Y or Z : ', @t.grep(/<[XYZ]>/).elems;
say '  tokens made only of hex     : ', @t.grep(/^ <[0..9a..f]>+ $/).elems, ' of 400';

my @u = (^400).map({ haikunate(:tokenChars('XYZ'), :tokenHex).split('-')[*-1] });
say '  argument order reversed, X/Y/Z tokens : ', @u.grep(/<[XYZ]>/).elems;

# Output:
#     asked for an alphabet of XYZ, with :tokenHex also set
#       tokens containing X, Y or Z : 0
#       tokens made only of hex     : 400 of 400
#       argument order reversed, X/Y/Z tokens : 0
