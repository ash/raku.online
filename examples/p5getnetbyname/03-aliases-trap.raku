#!/usr/bin/env rakupp
# P5getnetbyname — The one thing to know
# https://raku.online/modules/p5getnetbyname/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install P5getnetbyname
#     rakupp 03-aliases-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getnetbyname;
use P5getprotobyname;
use P5getservbyname;

say 'the same slot, across three siblings:';
say '  P5getprotobyname aliases : ', getprotobyname('tcp')[1].^name;
say '  P5getservbyname  aliases : ', getservbyname('http', 'tcp')[1].^name;

setnetent(0);
my @net = getnetent();
endnetent();
say '  P5getnetbyname   aliases : ', @net ?? @net[1].^name !! 'no entries here';
say '';
say 'so .words — which is right for the other two — silently produces';
say 'an Array\'s gist here rather than the alias names. Use .list.';

# Output:
#     the same slot, across three siblings:
#       P5getprotobyname aliases : Str
#       P5getservbyname  aliases : Str
#       P5getnetbyname   aliases : Array
#     
#     so .words — which is right for the other two — silently produces
#     an Array's gist here rather than the alias names. Use .list.
