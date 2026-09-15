#!/usr/bin/env rakupp
# Locale::Dates — What the tables actually contain
# https://raku.online/modules/locale-dates/#what-the-tables-actually-contain
#
# Install what it needs, then run it:
#     rakupp install Locale::Dates
#     rakupp 04-quirks.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Locale::Dates;

my $fr = Locale::Dates.new('FR');
say 'French abbreviated months : ', $fr.abbreviated-months[1..12].join(' ');
say '  distinct ?              : ',
    $fr.abbreviated-months[1..12].unique.elems, ' of 12';
say '  juin and juillet both abbreviate to the same three letters.';
say '';
for <RU BG> -> $c {
    my $l = Locale::Dates.new($c);
    say sprintf('%s am/pm : %s / %s   (both empty — a 12-hour formatter gets nothing)',
                $c, $l.am.raku, $l.pm.raku);
}
say '';
my $ru = Locale::Dates.new('RU');
say 'Russian months are in the GENITIVE — the form used inside a date,';
say 'not the name of the month:';
say '  ', $ru.months[1..3].join(' ');

# Output:
#     French abbreviated months : jan fév mar avr mai jui jui aoû sep oct nov déc
#       distinct ?              : 11 of 12
#       juin and juillet both abbreviate to the same three letters.
#     
#     RU am/pm : "" / ""   (both empty — a 12-hour formatter gets nothing)
#     BG am/pm : "" / ""   (both empty — a 12-hour formatter gets nothing)
#     
#     Russian months are in the GENITIVE — the form used inside a date,
#     not the name of the month:
#       января февраля марта
