---
name: DateTime::Location
version: 0.0.1
auth: cpan:TBROWDER
kind: Distribution · geography
summary: A value object for a place — name, coordinates, UTC offset and eight
  optional descriptive fields — that validates almost none of them.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/cpan:TBROWDER/DateTime::Location
source: https://github.com/tbrowder/DateTime-Location.git
---

## What it is for

Programs that compute sunrise, tides or local time need somewhere to keep the
"where": a name, a latitude and longitude, a UTC offset, and whatever
administrative detail the data source supplied. This distribution is that
container — a plain immutable value object, constructed once and read many
times.

It computes nothing. Despite the name there is no `DateTime` in it, no
method that takes or returns one, and no daylight-saving logic; the two DST
attributes are inert slots that nothing ever sets.

`lat`, `lon` and `timezone` are required alongside the identifiers; the eight
descriptive fields are not.

## Building one

```raku name="basics"
use DateTime::Location;

my $loc = DateTime::Location.new(
    id       => 'KDCA',
    name     => 'Washington National',
    lat      => 38.8521,
    lon      => -77.0377,
    timezone => -5e0,
    city     => 'Arlington',
    state    => 'VA',
    country  => 'US',
    region   => 'NA',
);

for <id name lat lon timezone state country region notes dst-start dst-end> -> $f {
    say sprintf('  %-10s %s', $f, $loc."$f"().raku);
}
```

```output
  id         "KDCA"
  name       "Washington National"
  lat        38.8521
  lon        -77.0377
  timezone   -5e0
  state      "VA"
  country    "US"
  region     "NA"
  notes      Any
  dst-start  Any
  dst-end    Any
```

`dst-start` and `dst-end` are always `Nil` — nothing in the class assigns
them.

## The accessor that is not one

```raku name="city"
use DateTime::Location;

my $loc = DateTime::Location.new(
    id => 'X', name => 'X', lat => 0e0, lon => 0e0, timezone => 0e0,
    city => 'Arlington');
my $r = try $loc.city;
say '$loc.city          -> ', $! ?? 'threw' !! $r.raku;
say '$loc.city("other") -> ', $loc.city('other').raku;
say '';
say 'a `method city($city) { }` at the end of the file REPLACES the';
say 'generated accessor. The value you passed as :city is stored and is';
say 'unreachable through any public method. `city` is the only field';
say 'affected — every other one reads back normally.';
```

```output
$loc.city          -> threw
$loc.city("other") -> Nil

a `method city($city) { }` at the end of the file REPLACES the
generated accessor. The value you passed as :city is stored and is
unreachable through any public method. `city` is the only field
affected — every other one reads back normally.
```

## The one thing to know

The construction check reads "you must define at least one of `$id` or
`$name`", and then rejects you for supplying only one — naming the field you
*did not* pass as if you had passed it empty.

```raku name="required"
use DateTime::Location;

my %coords = lat => 51.4775e0, lon => 0e0, timezone => 0e0;
for ('name only', { name => 'Greenwich' }),
    ('id only',   { id => 'EGLL' }),
    ('both',      { id => 'EGLL', name => 'Heathrow' }),
    ('neither',   { }) -> ($label, $args) {
    my $r = try DateTime::Location.new(|%coords, |$args);
    say sprintf('%-12s -> %s', $label,
                $! ?? $!.message.lines.grep(*.trim).tail.trim !! 'built: ' ~ $r.name);
}
say '';
say 'the guard is an `if not (…defined) { } elsif $!id eq "" { }` chain,';
say 'and an undefined Any `eq ""` is True — so the elsif fires for the';
say 'field you left out. Pass both.';
```

```output
name only    -> $id cannot be an empty string
id only      -> $name cannot be an empty string
both         -> built: Heathrow
neither      -> you must define at least one of $id or $name

the guard is an `if not (…defined) { } elsif $!id eq "" { }` chain,
and an undefined Any `eq ""` is True — so the elsif fires for the
field you left out. Pass both.
```

## Validation only fires for `Num`

```raku name="timezone"
use DateTime::Location;

sub build($tz) {
    my $r = try DateTime::Location.new(
        id => 'X', name => 'X', lat => 0e0, lon => 0e0, timezone => $tz);
    $! ?? 'refused' !! 'accepted: ' ~ $r.timezone.raku
}

for -5e0, 999e0, -5, 999, -5.5, 99999.0, 'est', 'zz' -> $tz {
    say sprintf('%-10s %-6s %s', $tz.raku, $tz.WHAT.^name, build($tz));
}
say '';
say 'the range test is `$tz ~~ Num`, so the natural :timezone(-5) and';
say ':timezone(-5.5) skip every check. EVERY three-character code is';
say 'rejected, and the rejection talks about hours rather than codes.';
say '';
say 'latitude and longitude are not checked at all:';
my $wild = DateTime::Location.new(
    id => 'X', name => 'X', lat => 1000, lon => -9999, timezone => 0e0);
say '  lat => 1000, lon => -9999 -> ', $wild.lat, ', ', $wild.lon;
```

```output
-5e0       Num    accepted: -5e0
999e0      Num    refused
-5         Int    accepted: -5
999        Int    accepted: 999
-5.5       Rat    accepted: -5.5
99999.0    Rat    accepted: 99999.0
"est"      Str    refused
"zz"       Str    refused

the range test is `$tz ~~ Num`, so the natural :timezone(-5) and
:timezone(-5.5) skip every check. EVERY three-character code is
rejected, and the rejection talks about hours rather than codes.

latitude and longitude are not checked at all:
  lat => 1000, lon => -9999 -> 1000, -9999
```

The private latitude/longitude checker is an empty stub.

## Where the two engines differ

Nothing behavioural: the same constructions succeed, the same ones die, and
the messages match. One diagnostic differs — Rakudo prints `Use of
uninitialized value $!id of type Any in string context` alongside the failure
above and Raku++ does not, which is the only clue Rakudo gives you that the
`eq ''` test is running against something undefined.

```raku name="portable"
use DateTime::Location;

# the shape that works everywhere: both identifiers, a Num offset,
# and your own range check before you hand the numbers over
sub location(:$id!, :$name!, :$lat!, :$lon!, :$tz!) {
    die "latitude out of range: $lat"  unless -90  <= $lat <= 90;
    die "longitude out of range: $lon" unless -180 <= $lon <= 180;
    DateTime::Location.new(:$id, :$name, lat => $lat.Num, lon => $lon.Num,
                           timezone => $tz.Num)
}

my $l = location(id => 'EGLL', name => 'Heathrow', lat => 51.4706, lon => -0.4619, tz => 0);
say 'built : ', $l.name, ' at ', $l.lat, ', ', $l.lon, ' (UTC', $l.timezone.Int, ')';
my $bad = try location(id => 'X', name => 'X', lat => 1000, lon => 0, tz => 0);
say 'guard : ', $! ?? $!.message !! 'accepted';
```

```output
built : Heathrow at 51.4706, -0.4619 (UTC0)
guard : latitude out of range: 1000
```
