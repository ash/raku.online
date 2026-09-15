#!/usr/bin/env rakupp
# Date::Easter — Computing Easter
# https://raku.online/modules/date-easter/#computing-easter
#
# Install what it needs, then run it:
#     rakupp install Date::Easter
#     rakupp 01-easter.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Easter;

my @check = 1818 => '1818-03-22', 2000 => '2000-04-23', 2016 => '2016-03-27',
            2020 => '2020-04-12', 2024 => '2024-03-31', 2026 => '2026-04-05',
            2038 => '2038-04-25';

for @check -> $p {
    my $e = Easter($p.key);
    say sprintf('%d  computed=%s  published=%s  %s  (%s)',
        $p.key, $e.Str, $p.value,
        $e.Str eq $p.value ?? 'match' !! 'DIFFERS',
        $e.day-of-week == 7 ?? 'Sunday' !! 'NOT SUNDAY');
}

# Output:
#     1818  computed=1818-03-22  published=1818-03-22  match  (Sunday)
#     2000  computed=2000-04-23  published=2000-04-23  match  (Sunday)
#     2016  computed=2016-03-27  published=2016-03-27  match  (Sunday)
#     2020  computed=2020-04-12  published=2020-04-12  match  (Sunday)
#     2024  computed=2024-03-31  published=2024-03-31  match  (Sunday)
#     2026  computed=2026-04-05  published=2026-04-05  match  (Sunday)
#     2038  computed=2038-04-25  published=2038-04-25  match  (Sunday)
