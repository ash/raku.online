#!/usr/bin/env rakupp
# Haikunator — Changing the shape
# https://raku.online/modules/haikunator/#changing-the-shape
#
# Install what it needs, then run it:
#     rakupp install Haikunator
#     rakupp 02-options.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Haikunator;

sub shape($s) { $s.subst(/<[a..z]>+/, 'W', :g).subst(/<[0..9a..fA..Z]>+$/, 'T') }

say 'default       : ', shape(haikunate());
say 'delimiter "." : ', shape(haikunate(:delimiter('.')));
say 'delimiter ""  : ', haikunate(:delimiter('')) ~~ /^ <[a..z]>+ \d ** 4 $/ ?? 'no separators' !! '?';
say 'tokenLength 0 : ', haikunate(:tokenLength(0)) ~~ /^ <[a..z]>+ '-' <[a..z]>+ $/ ?? 'no token at all' !! '?';
say 'tokenLength 8 : ', haikunate(:tokenLength(8)).split('-')[2].chars;
say 'tokenHex      : ', ?so haikunate(:tokenHex).split('-')[2] ~~ /^ <[0..9a..f]> ** 4 $/;
say 'tokenChars    : ', ?so haikunate(:tokenChars('ABC')).split('-')[2] ~~ /^ <[ABC]> ** 4 $/;

# Output:
#     default       : W-W-T
#     delimiter "." : W.W.T
#     delimiter ""  : no separators
#     tokenLength 0 : no token at all
#     tokenLength 8 : 8
#     tokenHex      : True
#     tokenChars    : True
