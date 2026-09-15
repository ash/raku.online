#!/usr/bin/env rakupp
# Swedish::TextDates_sv — What comes back is not a Str
# https://raku.online/modules/swedish-textdates-sv/#what-comes-back-is-not-a-str
#
# Install what it needs, then run it:
#     rakupp install Swedish::TextDates_sv
#     rakupp 03-types.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Swedish::TextDates_sv;

my $w = Whole-Date-Names_sv.new(whole_date => '2017-07-12');
my @fancy  = $w.fancy-date;
my @formal = $w.formal-date;

say 'fancy-date[0]  : ', @fancy[0].raku,  '  .WHAT = ', @fancy[0].WHAT.^name;
say '  ~~ Str       : ', @fancy[0] ~~ Str;
say '  eq works     : ', @fancy[0] eq 'tolfte';
say '  === does not : ', @fancy[0] === 'tolfte';
say '  .Int         : ', @fancy[0].Int;
say '';
say 'formal-date[1] : ', @formal[1].raku, '  .WHAT = ', @formal[1].WHAT.^name;
say '';
say 'the two methods on the same class have different return shapes:';
say 'fancy-date gives enum elements, formal-date a plain Str for the month.';
say 'and the enum types are NOT exported, so you cannot name them to';
say 'smart-match against. Use `eq`, or call .Str.';

# Output:
#     fancy-date[0]  : day_of_month_name_sv::tolfte  .WHAT = day_of_month_name_sv
#       ~~ Str       : False
#       eq works     : True
#       === does not : False
#       .Int         : 12
#     
#     formal-date[1] : "juli"  .WHAT = Str
#     
#     the two methods on the same class have different return shapes:
#     fancy-date gives enum elements, formal-date a plain Str for the month.
#     and the enum types are NOT exported, so you cannot name them to
#     smart-match against. Use `eq`, or call .Str.
