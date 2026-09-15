#!/usr/bin/env rakupp
# Result — Turning a throw into a Result
# https://raku.online/modules/result/#turning-a-throw-into-a-result
#
# Install what it needs, then run it:
#     rakupp install Result
#     rakupp 03-capture.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Result;

my $good = result({ 10 / 2 });
say 'result({ 10 / 2 })   : is-ok=', $good.is-ok, ' value=', $good.value;
say '';
my $bad = result({ die 'kaboom' });
say 'result({ die ... })  : is-err=', $bad.is-err;
say '  the error starts with the message : ', $bad.error.starts-with('kaboom');
say '  but it carries a backtrace too    : ', $bad.error.lines.elems > 1;

# Output:
#     result({ 10 / 2 })   : is-ok=True value=5
#     
#     result({ die ... })  : is-err=True
#       the error starts with the message : True
#       but it carries a backtrace too    : True
