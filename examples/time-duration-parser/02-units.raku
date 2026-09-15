#!/usr/bin/env rakupp
# Time::Duration::Parser — Which unit names it knows
# https://raku.online/modules/time-duration-parser/#which-unit-names-it-knows
#
# Install what it needs, then run it:
#     rakupp install Time::Duration::Parser
#     rakupp 02-units.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Time::Duration::Parser;

my @units = <s sec secs second seconds m min mins minute minutes
             h hr hrs hour hours d day days w wk week weeks
             mo month months y yr year years>;

my (@ok, @no);
for @units -> $u {
    duration-to-seconds("2 $u").defined ?? @ok.push($u) !! @no.push($u);
}
say 'accepted : ', @ok.join(' ');
say 'rejected : ', @no.join(' ');
say '';
say 'a month is ', duration-to-seconds('1 month'), ' seconds — exactly 30 days';
say 'a year  is ', duration-to-seconds('1 year'),  ' seconds — exactly 365 days';

# Output:
#     accepted : s sec secs second seconds m min mins minute minutes h hr hrs hour hours d day days w week weeks mo month months y year years
#     rejected : wk yr
#     
#     a month is 2592000 seconds — exactly 30 days
#     a year  is 31536000 seconds — exactly 365 days
