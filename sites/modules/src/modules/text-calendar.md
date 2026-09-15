---
name: Text::Calendar
version: 0.1.6
auth: zef:antononcube
kind: Distribution · calendars
summary: Render month grids as plain text — one month, several side by side,
  or a whole year — with a transposed layout and the raw week data available.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:antononcube/Text::Calendar
source: https://github.com/antononcube/Raku-Text-Calendar
---

## What it is for

Unix `cal` prints a month. This distribution prints the same thing from Raku,
with three differences that matter: weeks run Monday to Sunday rather than
Sunday-first, several months can be laid out side by side in rows, and the
week-by-week data is available as a list of hashes if you would rather do the
layout yourself.

## One month, and a year

```raku name="month"
use Text::Calendar;

say calendar-month-block(2026, 2);
say '';
say calendar-weekday-names().raku;
say calendar-month-names(:short).raku;
```

```output
February            
Mo Tu We Th Fr Sa Su
                   1
 2  3  4  5  6  7  8
 9 10 11 12 13 14 15
16 17 18 19 20 21 22
23 24 25 26 27 28   

["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
```

```raku name="year"
use Text::Calendar;

say calendar-year(2026, :per-row(4));
```

```output
                              2026

January                February               March                  April                  
Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   
          1  2  3  4                      1                      1          1  2  3  4  5   
 5  6  7  8  9 10 11    2  3  4  5  6  7  8    2  3  4  5  6  7  8    6  7  8  9 10 11 12   
12 13 14 15 16 17 18    9 10 11 12 13 14 15    9 10 11 12 13 14 15   13 14 15 16 17 18 19   
19 20 21 22 23 24 25   16 17 18 19 20 21 22   16 17 18 19 20 21 22   20 21 22 23 24 25 26   
26 27 28 29 30 31      23 24 25 26 27 28      23 24 25 26 27 28 29   27 28 29 30            

May                    June                   July                   August                 
Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   
             1  2  3    1  2  3  4  5  6  7          1  2  3  4  5                   1  2   
 4  5  6  7  8  9 10    8  9 10 11 12 13 14    6  7  8  9 10 11 12    3  4  5  6  7  8  9   
11 12 13 14 15 16 17   15 16 17 18 19 20 21   13 14 15 16 17 18 19   10 11 12 13 14 15 16   
18 19 20 21 22 23 24   22 23 24 25 26 27 28   20 21 22 23 24 25 26   17 18 19 20 21 22 23   
25 26 27 28 29 30 31   29 30                  27 28 29 30 31         24 25 26 27 28 29 30   

September              October                November               December               
Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   
    1  2  3  4  5  6             1  2  3  4                      1       1  2  3  4  5  6   
 7  8  9 10 11 12 13    5  6  7  8  9 10 11    2  3  4  5  6  7  8    7  8  9 10 11 12 13   
14 15 16 17 18 19 20   12 13 14 15 16 17 18    9 10 11 12 13 14 15   14 15 16 17 18 19 20   
21 22 23 24 25 26 27   19 20 21 22 23 24 25   16 17 18 19 20 21 22   21 22 23 24 25 26 27   
28 29 30               26 27 28 29 30 31      23 24 25 26 27 28 29   28 29 30 31            
```

Weeks are Monday-first, which is the ISO convention and not `cal`'s. There is
no option to change it.

## The other layouts

```raku name="layouts"
use Text::Calendar;

say calendar-month-block(2026, 2, :transposed);
say calendar-month-block(2026, 2, :empty('..'));
say '';
say calendar(2026, [2, 3], :per-row(2));
```

```output
    February 2026
Mo     2  9 16 23
Tu     3 10 17 24
We     4 11 18 25
Th     5 12 19 26
Fr     6 13 20 27
Sa     7 14 21 28
Su  1  8 15 22   
February            
Mo Tu We Th Fr Sa Su
.. .. .. .. .. ..  1
 2  3  4  5  6  7  8
 9 10 11 12 13 14 15
16 17 18 19 20 21 22
23 24 25 26 27 28 ..

February               March                  
Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   
                   1                      1   
 2  3  4  5  6  7  8    2  3  4  5  6  7  8   
 9 10 11 12 13 14 15    9 10 11 12 13 14 15   
16 17 18 19 20 21 22   16 17 18 19 20 21 22   
23 24 25 26 27 28      23 24 25 26 27 28 29   
```

`:transposed` puts weekdays down the left edge, `:empty` replaces the blank
cells with a string of your choosing, and `calendar` lays several months out
in rows of `:per-row`. The `$months` argument accepts an integer, a month
name, a list of either, or a list of `year => month` pairs.

## Reading the data instead of the grid

```raku name="dataset"
use Text::Calendar;

my @weeks = calendar-month-dataset(2026, 2);
say 'weeks in February 2026 : ', @weeks.elems;
for @weeks.kv -> $i, %w {
    say "  week $i: ", <Mo Tu We Th Fr Sa Su>.map({ %w{$_}.trim || '.' }).join(' ');
}
```

```output
weeks in February 2026 : 5
  week 0: . . . . . . 1
  week 1: 2 3 4 5 6 7 8
  week 2: 9 10 11 12 13 14 15
  week 3: 16 17 18 19 20 21 22
  week 4: 23 24 25 26 27 28 .
```

The values are **strings, already padded** — `"  "` for a blank, `"1"`
unpadded for a single digit — not integers. Trim and coerce if you want
numbers.

## The one thing to know

`calendar-month-block` omits the year from its title, and the `:transposed`
variant includes it.

```raku name="title-trap"
use Text::Calendar;

say 'plain title for 2024-02  : ', calendar-month-block(2024, 2).lines[0].raku;
say 'plain title for 2026-02  : ', calendar-month-block(2026, 2).lines[0].raku;
say 'transposed title         : ', calendar-month-block(2026, 2, :transposed).lines[0].raku;
say '';
say 'and the two grids are quite different:';
say '  2024-02 last row : ', calendar-month-block(2024, 2).lines[*-1].trim.raku;
say '  2026-02 last row : ', calendar-month-block(2026, 2).lines[*-1].trim.raku;
```

```output
plain title for 2024-02  : "February            "
plain title for 2026-02  : "February            "
transposed title         : "    February 2026"

and the two grids are quite different:
  2024-02 last row : "26 27 28 29"
  2026-02 last row : "23 24 25 26 27 28"
```

Two Februaries with different leap status and different weekday alignment
carry the identical title `February`. Archive a stack of these and nothing in
them records which year they are for. Switch on `:transposed` and the same
call titles itself `    February 2026`, centred and complete.

If you are saving the output, either use `:transposed` or write the year into
the filename.

## Where the two engines differ

On the single-month form of `calendar`. Passing a bare scalar month —
`calendar(2026, 2)` — renders the grid under Raku++ and **dies** under Rakudo
with `The months argument is expected to be Whatever, a list of month names or
integers between 1 and 12, or a list of year-month pairs.`

The cause is that the two-positional candidate normalises `$months` and then
re-dispatches to the one-positional candidate, which normalises the already
normalised value a second time; the engines disagree about what that second
pass yields for a bare scalar. Wrapping the month in a list — `calendar(2026,
[2])` — is portable and works identically on both, which is why every example
above does so.

Two smaller things. `calendar` (unlike `calendar-month-block`) pads every
block to 23 columns with trailing spaces and appends two blank lines. And
months 0 and 13 are rejected with the same generic message used for any
malformed month argument, so the error will not tell you which end you went
off.
