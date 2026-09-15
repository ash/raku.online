---
name: Data::Geographics
version: 0.1.5
auth: zef:antononcube
kind: Distribution · geography
summary: 29 countries of statistics and 62 350 cities, plus geohashes and a
  great-circle distance — with a decoder that swaps min and max.
status: divergent
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: JSON::Fast (used, but not declared in META)
raku-land: https://raku.land/zef:antononcube/Data::Geographics
source: https://github.com/antononcube/Raku-Data-Geographics.git
---

## What it is for

A bundled reference dataset: country statistics, city coordinates and
populations, and the geometry to go with them. No network, no API key — the
data ships with the distribution.

## Countries and cities

```raku name="basics"
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
```

```output
countries : 29
  first three : Botswana, Brazil, Bulgaria

note the shape — country-data($name) is keyed BY the country:
  country-data("Bulgaria")<Bulgaria><Area> = 110879

city fields : 
one city record:
  City         Sofia
  Country      Bulgaria
  Elevation    570
  ID           Bulgaria.Sofia_grad.Sofia
  Latitude     42.69
  Longitude    23.31
  Population   1260120
  State        Sofia grad

only nine countries have city data; the other twenty return an
empty list, not an error.
```

## Distance

```raku name="distance"
use Data::Geographics;

my ($sofia-lat, $sofia-lon) = 42.69, 23.31;
my ($paris-lat, $paris-lon) = 48.85,  2.35;

say 'geo-distance takes four positionals, two pairs, or one 4-element list:';
say '  metres     : ', geo-distance($sofia-lat, $sofia-lon, $paris-lat, $paris-lon).round;
say '  kilometres : ',
    geo-distance($sofia-lat, $sofia-lon, $paris-lat, $paris-lon, 'kilometers').round;
say '  miles      : ',
    geo-distance($sofia-lat, $sofia-lon, $paris-lat, $paris-lon, 'miles').round;
say '';
sub haversine($la1, $lo1, $la2, $lo2, $R) {
    my ($p1, $p2) = ($la1, $la2).map(* * pi / 180);
    my $dp = ($la2 - $la1) * pi / 180;
    my $dl = ($lo2 - $lo1) * pi / 180;
    my $a = sin($dp/2)**2 + cos($p1) * cos($p2) * sin($dl/2)**2;
    2 * $R * asin(sqrt($a))
}
say 'against a haversine with the EQUATORIAL radius 6378140 m:';
say '  ', haversine($sofia-lat, $sofia-lon, $paris-lat, $paris-lon, 6378140).round;
say 'and with the usual MEAN radius 6371000 m:';
say '  ', haversine($sofia-lat, $sofia-lon, $paris-lat, $paris-lon, 6371000).round;
say '';
say 'the module uses the equatorial radius, so its distances run about';
say '0.11% long against the conventional answer.';
say '';
say 'an unrecognised unit is a clean die:';
my $r = try geo-distance(0, 0, 1, 1, 'furlongs');
say '  units => "furlongs" -> ', $! ?? 'refused' !! $r;
```

```output
geo-distance takes four positionals, two pairs, or one 4-element list:
  metres     : 1758767
  kilometres : 1759
  miles      : 1093

against a haversine with the EQUATORIAL radius 6378140 m:
  1758767
and with the usual MEAN radius 6371000 m:
  1756798

the module uses the equatorial radius, so its distances run about
0.11% long against the conventional answer.

an unrecognised unit is a clean die:
  units => "furlongs" -> refused
```

## The one thing to know

`geohash-decode` returns the right bounding box with `min` and `max` **swapped**.

```raku name="geohash"
use Data::Geographics;
use Data::Geographics::GeoHash;

my ($lat, $lon) = 42.69, 23.31;
my $gh = geohash($lat, $lon, p => 8);
say 'geohash(42.69, 23.31, :p(8)) = ', $gh;
say '';
my %box = geohash-decode($gh);
say 'decoded box:';
for <latitude longitude> -> $axis {
    say sprintf('  %-10s min=%-14s max=%-14s min <= max ? %s',
                $axis, %box{$axis}<min>, %box{$axis}<max>,
                %box{$axis}<min> <= %box{$axis}<max>);
}
say '';
say 'the magnitudes are right; the labels are not. So the obvious';
say 'containment test reports FALSE for the very point that produced the';
say 'geohash:';
say '  as labelled : ',
    (%box<latitude><min> <= $lat <= %box<latitude><max>);
say '  swapped     : ',
    (%box<latitude><max> <= $lat <= %box<latitude><min>);
say '';
say 'geohash-neighbors is nevertheless CORRECT — it computes from the';
say 'same negative span and the sign cancels:';
say '  ', geohash("sx8df".Str, format => 'neighbors').sort.join(' ');
```

```output
geohash(42.69, 23.31, :p(8)) = sx8df7mz

decoded box:
  latitude   min=42.690125      max=42.6899529     min <= max ? False
  longitude  min=23.310242      max=23.3098984     min <= max ? False

the magnitudes are right; the labels are not. So the obvious
containment test reports FALSE for the very point that produced the
geohash:
  as labelled : False
  swapped     : True

geohash-neighbors is nevertheless CORRECT — it computes from the
same negative span and the sign cancels:
  sx8d9 sx8dc sx8dd sx8de sx8dg sx8e1 sx8e4 sx8e5
```

## The field whitelist is one arbitrary country's keys

```raku name="fields"
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
```

```output
country-data("fields") lists : one country`s keys — 192 or 193,
                               depending on hash order
the union over all 29 countries : 203

ingest-country-data sets the list to
  %country-records.values.head.keys.sort
— the keys of whichever country hash iteration puts first. So real
data is unreachable through the $fields argument, and the COUNT
differs between engines because hash order does.

fields present in the data and absent from the whitelist : ten or more
  they include BorderingCountries, ExportPartners, ImportPartners,
  NaturalHazards and InfectiousDiseases.

ask for a country and read the hash; do not filter by field.
```

## Where the two engines differ

The field count above, because it comes from hash iteration order — 193 on
Raku++ and 192 on Rakudo, against a real union of 203. And the return shape of
a single-field query: `country-data($spec, 'OneField')` is a `Seq` and
`country-data($spec, <Two Fields>)` is a `Hash`, so associative indexing on
the single-field result dies on Rakudo.

```raku name="portable"
use Data::Geographics;

say 'the shapes that behave identically on both engines:';
say '  country-data($name)<$name><Field>';
say '  city-data($city) / city-data([$country, Whatever, Whatever])';
say '  geo-distance(…) in any of its argument forms';
say '  geohash($lat, $lon, :p($n))  and  geohash($gh, format => "neighbors")';
say '';
say 'a bare Str spec to city-data searches the CITY column only:';
say '  city-data("Bulgaria").elems          : ', city-data('Bulgaria').elems;
say '  city-data(["Bulgaria", *, *]).elems  : ',
    city-data(['Bulgaria', Whatever, Whatever]).elems;
say '';
say 'and city-data(Whatever) dies even though city-data() with no';
say 'arguments returns everything.';
say '';
say 'one last thing worth knowing before you deploy: META declares';
say '"depends": [] while the module does `use JSON::Fast`. It can install';
say 'into a store where it will not load.';
```

```output
the shapes that behave identically on both engines:
  country-data($name)<$name><Field>
  city-data($city) / city-data([$country, Whatever, Whatever])
  geo-distance(…) in any of its argument forms
  geohash($lat, $lon, :p($n))  and  geohash($gh, format => "neighbors")

a bare Str spec to city-data searches the CITY column only:
  city-data("Bulgaria").elems          : 0
  city-data(["Bulgaria", *, *]).elems  : 261

and city-data(Whatever) dies even though city-data() with no
arguments returns everything.

one last thing worth knowing before you deploy: META declares
"depends": [] while the module does `use JSON::Fast`. It can install
into a store where it will not load.
```
