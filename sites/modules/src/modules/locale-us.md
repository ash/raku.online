---
name: Locale::US
version: 0.0.2
auth: zef:raku-community-modules
kind: Distribution · localisation
summary: Two-letter postal codes to place names and back — 59 rows, not 50,
  and every name comes back SHOUTED.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Locale::US
source: git://github.com/raku-community-modules/Locale-US.git
---

## What it is for

Forms ask for a state and store `CA`; reports want `CALIFORNIA`. This
distribution is that lookup, in both directions, with nothing else in it: four
subs over one table.

## Looking up

```raku name="basics"
use Locale::US;

say 'code-to-state("CA")         : ', code-to-state('CA').raku;
say 'code-to-state("ca")         : ', code-to-state('ca').raku;
say 'state-to-code("California") : ', state-to-code('California').raku;
say 'state-to-code("CALIFORNIA") : ', state-to-code('CALIFORNIA').raku;
say '';
say 'both lookups upper-case their argument, so input case does not matter.';
say 'every NAME comes back shouted — there is no display-cased form anywhere';
say 'in the module.';
say '';
say 'a miss is an undefined value, not an exception:';
say '  code-to-state("ZZ").defined : ', code-to-state('ZZ').defined;
say '  state-to-code("Atlantis")   : ', state-to-code('Atlantis').defined;
```

```output
code-to-state("CA")         : "CALIFORNIA"
code-to-state("ca")         : "CALIFORNIA"
state-to-code("California") : "CA"
state-to-code("CALIFORNIA") : "CA"

both lookups upper-case their argument, so input case does not matter.
every NAME comes back shouted — there is no display-cased form anywhere
in the module.

a miss is an undefined value, not an exception:
  code-to-state("ZZ").defined : False
  state-to-code("Atlantis")   : False
```

## The one thing to know

The table is not the fifty states. It is 59 rows: the states, the District of
Columbia, five territories and three freely associated states.

```raku name="table"
use Locale::US;

my @codes = all-state-codes.sort;
say 'rows in the table : ', @codes.elems;
say '';
my @extras = @codes.grep({ $_ !~~ any(<AL AK AZ AR CA CO CT DE FL GA HI ID IL IN
    IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI
    SC SD TN TX UT VT VA WA WV WI WY>) });
say 'the nine that are not one of the fifty states:';
for @extras -> $c { say sprintf('  %s = %s', $c, code-to-state($c)) }
say '';
say 'so `all-state-codes.elems == 50` is false, and any UI that renders';
say 'this list as "the states" is wrong. There is no UM row (U.S. Minor';
say 'Outlying Islands): code-to-state("UM").defined = ',
    code-to-state('UM').defined;
```

```output
rows in the table : 59

the nine that are not one of the fifty states:
  AS = AMERICAN SAMOA
  DC = DISTRICT OF COLUMBIA
  FM = FEDERATED STATES OF MICRONESIA
  GU = GUAM
  MH = MARSHALL ISLANDS
  MP = NORTHERN MARIANA ISLANDS
  PR = PUERTO RICO
  PW = PALAU
  VI = VIRGIN ISLANDS

so `all-state-codes.elems == 50` is false, and any UI that renders
this list as "the states" is wrong. There is no UM row (U.S. Minor
Outlying Islands): code-to-state("UM").defined = False
```

## Where the two engines differ

The two list-returning subs hand you the module's own internal table. Under
Rakudo that is an immutable `List` and a write is refused; under Raku++ it is
a mutable `Array`, and a write corrupts the module for the rest of the
process.

```raku name="mutable"
use Locale::US;

# always copy before you touch it
my @codes = all-state-codes.List;
my @names = all-state-names.List;
say 'a copy is safe on both engines : ', @codes.elems, ' codes, ', @names.elems, ' names';
@codes[0] = 'QQ';
say '  my copy now starts ', @codes[0];
say '  the module still says ', all-state-codes[0];
say '';
say 'Rakudo refuses a write through all-state-codes()[0] with';
say 'X::Assignment::RO. Raku++ accepts it, and a FRESH all-state-codes()';
say 'call then returns the damaged value for the rest of the process.';
say '';
say 'the same difference reaches the miss case:';
say '  code-to-state("ZZ") is Any on Raku++ and Nil on Rakudo.';
say '  .defined is False either way, so // works — but .raku, `with`, and';
say '  assignment into a typed variable do not agree. Use //.';
my $name = code-to-state('ZZ') // 'UNKNOWN';
say '  code-to-state("ZZ") // "UNKNOWN" = ', $name;
```

```output
a copy is safe on both engines : 59 codes, 59 names
  my copy now starts QQ
  the module still says AK

Rakudo refuses a write through all-state-codes()[0] with
X::Assignment::RO. Raku++ accepts it, and a FRESH all-state-codes()
call then returns the damaged value for the rest of the process.

the same difference reaches the miss case:
  code-to-state("ZZ") is Any on Raku++ and Nil on Rakudo.
  .defined is False either way, so // works — but .raku, `with`, and
  assignment into a typed variable do not agree. Use //.
  code-to-state("ZZ") // "UNKNOWN" = UNKNOWN
```

Reduced to one line with no module involved: `my constant @c = <a b c>` binds
an `Array` under Raku++ and a `List` under Rakudo, and `my constant %h` binds
a `Hash` rather than a `Map` — which is also why a missing key reads back as
`Any` on one engine and `Nil` on the other.

One naming note, identical on both: `VIRGIN ISLANDS` carries no `, U.S.`
qualifier, so a round trip through a system that expects the full official
name will not match.
