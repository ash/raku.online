#!/usr/bin/env rakupp
# Data::Geographics — Countries and cities
# https://raku.online/modules/data-geographics/#countries-and-cities
#
# Install what it needs, then run it:
#     rakupp install Data::Geographics
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Geographics;

my @countries = country-data().keys.sort;
say 'countries : ', @countries.elems;
say '  first three : ', @countries.head(3).join(', ');
say '';
say 'note the shape — country-data($name) is keyed BY the country:';
say '  country-data("Bulgaria")<Bulgaria><Area> = ',
    country-data('Bulgaria')<Bulgaria><Area>;
say '';
say 'city fields : ', city-data('Sofia').head<City Country Latitude Longitude>.grep(*.defined) ?? '' !! '';
my $sofia = city-data('Sofia').head;
say 'one city record:';
for $sofia.keys.sort -> $k {
    next if $k eq 'LocationLink';
    say sprintf('  %-12s %s', $k, $sofia{$k});
}
say '';
say 'only nine countries have city data; the other twenty return an';
say 'empty list, not an error.';

# Output:
#     countries : 29
#       first three : Botswana, Brazil, Bulgaria
#     
#     note the shape — country-data($name) is keyed BY the country:
#       country-data("Bulgaria")<Bulgaria><Area> = 110879
#     
#     city fields : 
#     one city record:
#       City         Sofia
#       Country      Bulgaria
#       Elevation    570
#       ID           Bulgaria.Sofia_grad.Sofia
#       Latitude     42.69
#       Longitude    23.31
#       Population   1260120
#       State        Sofia grad
#     
#     only nine countries have city data; the other twenty return an
#     empty list, not an error.
