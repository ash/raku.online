#!/usr/bin/env rakupp
# HTTP::ParseParams — The one thing to know
# https://raku.online/modules/http-parseparams/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install HTTP::ParseParams
#     rakupp 04-no-equals-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTTP::ParseParams;

for 'a&b=2', '', 'debug&x=1' -> $q {
    my $r = try HTTP::ParseParams::parse($q, :urlencoded);
    say sprintf('%-12s -> %s', $q.raku, $! ?? 'threw' !! 'parsed');
}
say '';
say '?debug&x=1 is ordinary on the real web, and a request with no';
say 'query string at all gives you the empty string.';

# Output:
#     "a\&b=2"     -> threw
#     ""           -> threw
#     "debug\&x=1" -> threw
#     
#     ?debug&x=1 is ordinary on the real web, and a request with no
#     query string at all gives you the empty string.
