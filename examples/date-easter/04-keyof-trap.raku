#!/usr/bin/env rakupp
# Date::Easter — The one thing to know
# https://raku.online/modules/date-easter/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Date::Easter
#     rakupp 04-keyof-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Easter;

my $bound := get-easter-events-hashlist(:year(2025));
say 'bound with :=';
say '  type  : ', $bound.^name;
say '  keyof : ', $bound.keyof.^name;
say '  index by a Date object : ', $bound{Date.new(2025, 4, 20)}[0].name;

my %copied = get-easter-events-hashlist(:year(2025));
say '';
say 'assigned to my %h';
say '  type  : ', %copied.^name;
say '  keyof : ', %copied.keyof.^name;
say '  index by a string      : ', %copied{'2025-04-20'}[0].name;

# Output:
#     bound with :=
#       type  : Hash[Array,Date]
#       keyof : Date
#       index by a Date object : Easter Sunday
#     
#     assigned to my %h
#       type  : Hash
#       keyof : Str(Any)
#       index by a string      : Easter Sunday
