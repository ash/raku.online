#!/usr/bin/env rakupp
# Result — The one thing to know
# https://raku.online/modules/result/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Result
#     rakupp 04-bind-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Result;

say 'what the block actually receives:';
Ok(42).map-ok(-> $x { say '  a ', $x.^name, ' carrying ', $x.value; Ok($x) });
say '';
say 'the natural reading fails:';
my $r = try Ok(42).map-ok(-> $x { $x.value + 1 });
say '  ', $! ?? 'threw ' ~ $!.^name !! 'worked';
say '';
say 'the working form unwraps and rewraps:';
say '  ', Ok(42).map-ok(-> $res { Ok($res.value + 1) }).value;

# Output:
#     what the block actually receives:
#       a Result::Ok carrying 42
#     
#     the natural reading fails:
#       threw X::TypeCheck::Return
#     
#     the working form unwraps and rewraps:
#       43
