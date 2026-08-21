---
name: Data::Generators
version: 0.1.11
auth: zef:antononcube
kind: Distribution · data generation
summary: Random words, strings, numbers, dates, pet names, job titles — and
  whole tabular datasets. The fastest way to have data before you have data.
status: full
license: Artistic-2.0
depends: Statistics::Distributions, Math::SpecialFunctions
suite: 9 files, green
tested: 2026-08-21
raku-land: https://raku.land/zef:antononcube/Data::Generators
source: https://github.com/antononcube/Raku-Data-Generators
---

## What it is for

You are writing something that eats data — a parser, a report, a table widget,
a load test — and you do not have the data yet. This module makes plausible
fakes of most things you will want: words that are real English words, strings
with a shape you specify, numbers in a range, date-times between two moments,
and entire tabular datasets with named columns.

Everything here is one function call, and every function takes the count first:

```raku sample name="tour"
use Data::Generators;

say random-word(4);
say random-pet-name(3);
say random-string(2, chars => 8, ranges => ["A".."Z", "0".."9"]);
say random-real((0, 100), 3).map(*.fmt('%.1f'));
```

```output
(remotely kitten roundelay ankylotic)
(Walter Sweetie Sasha)
(O72P0U5P PS4AVECI)
(12.3 87.4 55.0)
```

Your run will print different words and numbers — that is the point. What is
stable is the shape, and the pages of this handbook assert on shapes.

One thing to budget for: `use Data::Generators` costs about a second, on
**both** engines — the module parses its 85,000-word list and 20,000 pet-name
records at load time, before your first line runs. That is the module's design,
not an engine tax (Raku++ spends ~0.9s on it, Rakudo ~1.3s). Pay it once per
process, not once per call.

## Words

`random-word($n)` draws from a built-in list of about 85,000 English words.
Four word kinds are built in: `'known'` (the whole list), `'common'`,
`'stopword'`, and `'any'`.

```raku name="words"
use Data::Generators;

say random-word(1000).elems;
say so random-word(1000).all ~~ Str;
say random-word(1000).unique.elems > 500;
```

```output
1000
True
True
```

The word kinds are how you keep the fakes readable — `'common'` gives you words
a reader will recognise, `'stopword'` the little glue words:

```raku name="word-types"
use Data::Generators;

my @common = random-word(5, type => 'common');
my @stop   = random-word(5, type => 'stopword');
say @common.elems + @stop.elems;
say so (@common, @stop).flat.all ~~ Str;
say so random-word(200, type => 'stopword').map(*.chars).max <= 15;
```

```output
10
True
True
```

Two neighbours of `random-word` are pure fun with the same signature:
`random-pet-name` draws from real pet-license registries (ask for
`species => 'Cat'` or `'Dog'` specifically), and
`random-pretentious-job-title` builds titles like *Regional Communications
Orchestrator* — useful the moment your fake dataset needs a `title` column
nobody will mistake for production data.

```raku sample name="names-and-titles"
use Data::Generators;

say random-pet-name(4, species => 'Cat');
say random-pretentious-job-title(2);
```

```output
(Polly Butchie Quinn Maggie)
(Relational Factors Representative Interactive Operations Orchestrator)
```

## Strings with a shape

`random-string` takes the length in characters and the character sets to draw
from — each set a range or a list of characters, mixed freely:

```raku name="strings"
use Data::Generators;

my @s = random-string(100, chars => 4, ranges => ["a".."f", "0".."9"]);
say @s.elems;
say so @s.map(*.chars).all == 4;
say so @s.join.comb.all ~~ /<[a..f 0..9]>/;
```

```output
100
True
True
```

That `ranges => ["a".."f", "0".."9"]` — a list holding two Ranges — is exactly
the shape that taught Raku++ two lessons at once: a Range written *inside* an
array literal must stay a Range rather than spread into its elements, and the
module's own argument check smartmatches a junction *topic* against a code
block. Both now behave as Rakudo does; the page you are reading is built on the
engine that learned it.

## Numbers and date-times

`random-real` draws uniformly from a range given as `(min, max)`:

```raku name="reals"
use Data::Generators;

my @r = random-real((10, 20), 1000);
say @r.elems;
say so @r.all ~~ Num;
say so ([&&] @r.map({ 10 <= $_ <= 20 }));
say 14 < @r.sum / @r.elems < 16;
```

```output
1000
True
True
True
```

`random-date-time` spans 1900–2100 by default, and takes `:min`/`:max` bounds:

```raku name="date-times"
use Data::Generators;

my @dt = random-date-time(size => 100);
say @dt.elems;
say so @dt.all ~~ DateTime;
say so @dt.map(*.year).all ~~ 1900..2100;

my $min = DateTime.new('2024-01-01T00:00:00Z');
my $max = DateTime.new('2024-12-31T23:59:59Z');
say so random-date-time(:$min, :$max, size => 50).map(*.year).all == 2024;
```

```output
100
True
True
True
```

> Call it as `random-date-time(size => $n)` or with bounds — **not**
> `random-date-time($n)`. That form dies on **both** engines: the module's own
> candidate list catches a bare integer in a signature that wants a DateTime,
> and its own test suite avoids it too.

## Whole tabular datasets

`random-tabular-dataset` is the reason this module is on load-test duty
everywhere: one call gives you a list of hashes with named columns, ready to
feed to anything that eats rows.

```raku name="dataset"
use Data::Generators;

my @tbl = random-tabular-dataset(4, <name age score>);
say @tbl.elems;
say @tbl.head.keys.sort.join(',');
say so @tbl.all ~~ Map;
```

```output
4
age,name,score
True
```

Left to itself it picks a random generator per column. Pass `generators` — a
map from column name to a closure taking the row count — and each column means
something:

```raku name="dataset-generators"
use Data::Generators;

my @readings = random-tabular-dataset(5, <city temp>, generators => {
    city => { random-word($_) },
    temp => { random-real((-5, 35), $_) },
});
say @readings.elems;
say so @readings.map(*.<temp>).all ~~ Num;
say so ([&&] @readings.map({ -5 <= .<temp> <= 35 }));
```

```output
5
True
True
```

## Where the two engines differ

Everything above runs identically under Raku++ and Rakudo. Two things at the
edges do not.

**`generators` as a positional list dies under Rakudo 2026.06.** The
`generators => [ &gen1, &gen2 ]` list form (as opposed to the map form above)
trips a "Seq already consumed" error inside the module under Rakudo, and works
under Raku++. Use the map form — it is clearer anyway, and it works everywhere.

**`srand` pins the sequence under Raku++, and does not under Rakudo** — the
same divergence noted on the
[Statistics::Distributions page](/ecosystem/statistics-distributions/): a seed
makes a Raku++ run reproducible, and does not make a Rakudo run reproducible,
so do not build a cross-engine test on one.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install Data::Generators`, which pulls
   `Statistics::Distributions` and `Math::SpecialFunctions` with it and runs
   all three test suites before marking anything installed.
3. **Test** — the distribution's own suite: 9 files, green.
4. **Run** — every example on this page, twice under each engine, as the site
   is built.

Getting the suite green took five engine fixes, none of them reachable from
roast: a Rat index into a lazy sequence (how `Math::SpecialFunctions` reads its
memoised Bernoulli numbers), a Range inside an array literal spreading into its
elements (how this module writes character sets), a junction topic in
smartmatch keeping its junction instead of collapsing (how it validates
arguments), `Range` not doing `Positional`, and `pick`/`roll` not accepting the
spelled-out `Whatever` as a count (how it decides between drawing with and
without replacement). One more surfaced while writing this page:
`DateTime.new($dt + $offset)` read the argument as a *year*, which put every
random date-time in the year 8.
