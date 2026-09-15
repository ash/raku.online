#!/usr/bin/env rakupp
# Date::Calendar::Bahai — The one thing to know
# https://raku.online/modules/date-calendar-bahai/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::Bahai
#     rakupp 03-twenty-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Bahai;

say 'month 19 : ', Date::Calendar::Bahai.new(year => 183, month => 19, day => 1).month-name;
say 'month 20 : ', Date::Calendar::Bahai.new(year => 183, month => 20, day => 1).month-name;
say '';
say 'everyone knows this calendar as "19 months of 19 days".';
say 'the intercalary period Ayyám-i-Há gets its own month number, 19,';
say 'which pushes the real nineteenth month out to 20.';
say '';
for 181, 183, 184 -> $y {
    my $len = (1..5).grep({
        (try Date::Calendar::Bahai.new(year => $y, month => 19, day => $_)).defined
    }).elems;
    say sprintf('  year %d: leap=%-5s  Ayyám-i-Há is %d days',
        $y, Date::Calendar::Bahai.new(year => $y, month => 1, day => 1).is-leap, $len);
}

# Output:
#     month 19 : Ayyám-i-Há
#     month 20 : 'Alá
#     
#     everyone knows this calendar as "19 months of 19 days".
#     the intercalary period Ayyám-i-Há gets its own month number, 19,
#     which pushes the real nineteenth month out to 20.
#     
#       year 181: leap=False  Ayyám-i-Há is 4 days
#       year 183: leap=False  Ayyám-i-Há is 4 days
#       year 184: leap=True   Ayyám-i-Há is 5 days
