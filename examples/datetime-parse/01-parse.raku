#!/usr/bin/env rakupp
# DateTime::Parse — The four forms
# https://raku.online/modules/datetime-parse/#the-four-forms
#
# Install what it needs, then run it:
#     rakupp install DateTime::Parse
#     rakupp 01-parse.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DateTime::Parse;

say DateTime::Parse.new('Sun, 06 Nov 1994 08:49:37 GMT');
say DateTime::Parse.new('Sun Nov  6 08:49:37 1994');
say DateTime::Parse.new('2026-09-14T15:04:05Z');
say DateTime::Parse.new('Sun, 06 Nov 1994 08:49:37 GMT').^name;
say DateTime::Parse.new('Sunday, 06-Nov-94 08:49:37 GMT').year;
say (try { DateTime::Parse.new('2026-09-14 15:04:05') }) // $!.^name;

# Output:
#     1994-11-06T08:49:37Z
#     1994-11-06T08:49:37Z
#     2026-09-14T15:04:05Z
#     DateTime
#     94
#     X::DateTime::CannotParse
