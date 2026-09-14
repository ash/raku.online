#!/usr/bin/env rakupp
# Date::Names — Names in and out
# https://raku.online/modules/date-names/#names-in-and-out
#
# Install what it needs, then run it:
#     rakupp install Date::Names
#     rakupp 01-names.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Names;

my $en = Date::Names.new;
say $en.mon(9), ' ', $en.mon(9, 3), ' ', $en.dow(1), ' ', $en.dow(7, 2);
say $en.mon2num('September'), ' ', $en.dow2num('Sat');
for <de fr es nl uk> -> $lang {
    my $d = Date::Names.new(:$lang);
    say "$lang: ", $d.mon(9), ' / ', $d.dow(1), ' / ', $d.mon(9, 3);
}
say Date::Names.new(lang => 'de').mfull.join(', ');
say (try { $en.mon(13) }) // $!.^name;
say (try { Date::Names.new(lang => 'xx') }) // $!.^name;

# Output:
#     September Sep Monday Su
#     9 6
#     de: September / Montag / Sep
#     fr: septembre / lundi / sep
#     es: septiembre / lunes / sep
#     nl: september / maandag / sep
#     uk: вересень / понеділок / вер
#     Januar, Februar, März, April, Mai, Juni, Juli, August, September, Oktober, November, Dezember
#     X::TypeCheck::Binding::Parameter
#     X::NoSuchSymbol
