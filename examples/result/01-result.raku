#!/usr/bin/env rakupp
# Result — Constructing and inspecting
# https://raku.online/modules/result/#constructing-and-inspecting
#
# Install what it needs, then run it:
#     rakupp install Result
#     rakupp 01-result.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Result;

my $ok  = Ok(42);
my $err = Err('boom');

for 'Ok(42)', $ok, "Err('boom')", $err -> $label, $r {
    say $label;
    say '  type    : ', $r.^name;
    say '  is-ok   : ', $r.is-ok;
    say '  is-err  : ', $r.is-err;
    say '  Bool    : ', ?$r;
}
say '';
say 'Ok carries a value  : ', $ok.value;
say 'Err carries a Str   : ', $err.error;

# Output:
#     Ok(42)
#       type    : Result::Ok
#       is-ok   : True
#       is-err  : False
#       Bool    : True
#     Err('boom')
#       type    : Result::Err
#       is-ok   : False
#       is-err  : True
#       Bool    : False
#     
#     Ok carries a value  : 42
#     Err carries a Str   : boom
