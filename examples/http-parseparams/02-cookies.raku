#!/usr/bin/env rakupp
# HTTP::ParseParams — Cookies
# https://raku.online/modules/http-parseparams/#cookies
#
# Install what it needs, then run it:
#     rakupp install HTTP::ParseParams
#     rakupp 02-cookies.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTTP::ParseParams;

my %c = HTTP::ParseParams::parse('session=abc; theme=dark', :cookie);
say %c.keys.sort.map({ "$_={%c{$_}.raku}" }).join(' ');
say '';
say 'a repeated key gives a container rather than a Str:';
my %r = HTTP::ParseParams::parse('a=1; a=2; a=3', :cookie);
say '  the value for a is a ', %r<a>.^name;
say '  and a single key is a ', %c<session>.^name;

# Output:
#     session="abc" theme="dark"
#     
#     a repeated key gives a container rather than a Str:
#       the value for a is a Seq
#       and a single key is a Str
