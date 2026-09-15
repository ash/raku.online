#!/usr/bin/env rakupp
# HTTP::ParseParams — Choosing the dialect from a header
# https://raku.online/modules/http-parseparams/#choosing-the-dialect-from-a-header
#
# Install what it needs, then run it:
#     rakupp install HTTP::ParseParams
#     rakupp 03-content-type.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTTP::ParseParams;

my %p = HTTP::ParseParams::parse('a=1&a=2',
    :content-type<application/x-www-form-urlencoded>);
say 'via content-type : ', %p<a>.List.raku;
say '';
my $r = try HTTP::ParseParams::parse('a=1', :content-type<text/plain>);
say 'an unknown content type : ', $! ?? $!.message !! 'accepted';
my $n = try HTTP::ParseParams::parse('a=1');
say 'no dialect at all       : ', $! ?? $!.message !! 'accepted';

# Output:
#     via content-type : ("1", "2")
#     
#     an unknown content type : Unable to understand content type text/plain
#     no dialect at all       : Nothing to do!
