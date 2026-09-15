#!/usr/bin/env rakupp
# Data::Geographics — The field whitelist is one arbitrary country's keys
# https://raku.online/modules/data-geographics/#the-field-whitelist-is-one-arbitrary-countrys-keys
#
# Install what it needs, then run it:
#     rakupp install Data::Geographics
#     rakupp 04-fields.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Geographics;

my @listed = country-data('fields').list;
my $union = country-data().values.map(*.keys.Slip).unique.elems;
say 'country-data("fields") lists : one country`s keys — 192 or 193,';
say '                               depending on hash order';
say 'the union over all 29 countries : ', $union;
say '';
say 'ingest-country-data sets the list to';
say '  %country-records.values.head.keys.sort';
say '— the keys of whichever country hash iteration puts first. So real';
say 'data is unreachable through the $fields argument, and the COUNT';
say 'differs between engines because hash order does.';
say '';
my @missing = country-data().values.map(*.keys.Slip).unique.grep({ $_ !~~ any(@listed) }).sort;
say 'fields present in the data and absent from the whitelist : ',
    @missing >= 10 ?? 'ten or more' !! @missing.elems;
say '  they include BorderingCountries, ExportPartners, ImportPartners,';
say '  NaturalHazards and InfectiousDiseases.';
say '';
say 'ask for a country and read the hash; do not filter by field.';

# Output:
#     country-data("fields") lists : one country`s keys — 192 or 193,
#                                    depending on hash order
#     the union over all 29 countries : 203
#     
#     ingest-country-data sets the list to
#       %country-records.values.head.keys.sort
#     — the keys of whichever country hash iteration puts first. So real
#     data is unreachable through the $fields argument, and the COUNT
#     differs between engines because hash order does.
#     
#     fields present in the data and absent from the whitelist : ten or more
#       they include BorderingCountries, ExportPartners, ImportPartners,
#       NaturalHazards and InfectiousDiseases.
#     
#     ask for a country and read the hash; do not filter by field.
