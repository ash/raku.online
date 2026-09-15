#!/usr/bin/env rakupp
# HTTP::ParseParams — Parsing a query string
# https://raku.online/modules/http-parseparams/#parsing-a-query-string
#
# Install what it needs, then run it:
#     rakupp install HTTP::ParseParams
#     rakupp 01-urlencoded.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTTP::ParseParams;

my %p = HTTP::ParseParams::parse('name=Ada&lang=raku&year=2026', :urlencoded);
say %p.keys.sort.map({ "$_={%p{$_}.raku}" }).join(' ');
say '';
say 'percent-decoded values:';
my %d = HTTP::ParseParams::parse('n=%48%69&s=a%20b', :urlencoded);
say '  ', %d.keys.sort.map({ "$_={%d{$_}.raku}" }).join(' ');
say '';
say 'it splits on ; as well as &:';
my %s = HTTP::ParseParams::parse('a=1;b=2', :urlencoded);
say '  ', %s.keys.sort.map({ "$_={%s{$_}.raku}" }).join(' ');

# Output:
#     lang="raku" name="Ada" year="2026"
#     
#     percent-decoded values:
#       n="Hi" s="a b"
#     
#     it splits on ; as well as &:
#       a="1" b="2"
