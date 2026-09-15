#!/usr/bin/env rakupp
# Holidays::US::Federal — A year of holidays
# https://raku.online/modules/holidays-us-federal/#a-year-of-holidays
#
# Install what it needs, then run it:
#     rakupp install Holidays::US::Federal
#     rakupp 01-holidays.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Holidays::US::Federal;

my %h = get-fedholidays(:year(2021), :set-id('S'));

for %h.keys.sort -> $date {
    for %h{$date}.keys.sort -> $key {
        my $e = %h{$date}{$key};
        say sprintf('%s  %-3s  observed %s  %s',
            ~$e.date,
            <Mon Tue Wed Thu Fri Sat Sun>[$e.date.day-of-week - 1],
            ~$e.date-observed, $e.name);
    }
}

# Output:
#     2021-01-01  Fri  observed 2021-01-01  New Year's Day
#     2021-01-18  Mon  observed 2021-01-18  Birthday of Martin Luther King, Jr.
#     2021-02-15  Mon  observed 2021-02-15  Washington's Birthday
#     2021-05-31  Mon  observed 2021-05-31  Memorial Day
#     2021-06-19  Sat  observed 2021-06-18  Juneteenth National Independence Day
#     2021-07-04  Sun  observed 2021-07-05  Independence Day
#     2021-09-06  Mon  observed 2021-09-06  Labor Day
#     2021-10-11  Mon  observed 2021-10-11  Columbus Day
#     2021-11-11  Thu  observed 2021-11-11  Veterans Day
#     2021-11-25  Thu  observed 2021-11-25  Thanksgiving Day
#     2021-12-25  Sat  observed 2021-12-24  Christmas Day
