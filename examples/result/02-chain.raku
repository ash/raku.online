#!/usr/bin/env rakupp
# Result — Chaining
# https://raku.online/modules/result/#chaining
#
# Install what it needs, then run it:
#     rakupp install Result
#     rakupp 02-chain.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Result;

my $r = Ok(42).map-ok(-> $res { Ok($res.value + 1) })
              .map-ok(-> $res { Ok($res.value * 2) });
say 'two steps on an Ok   : ', $r.value;
say '';
say 'an Err passes through map-ok untouched:';
say '  ', Err('e').map-ok(-> $res { Ok(1) }).error;
say 'and an Ok passes through map-err:';
say '  ', Ok(9).map-err(-> $res { Err('z') }).value;
say '';
say 'map-err on an Err:';
say '  ', Err('boom').map-err(-> $res { Err($res.error ~ '!') }).error;

# Output:
#     two steps on an Ok   : 86
#     
#     an Err passes through map-ok untouched:
#       e
#     and an Ok passes through map-err:
#       9
#     
#     map-err on an Err:
#       boom!
