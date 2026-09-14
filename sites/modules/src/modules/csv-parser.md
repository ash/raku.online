---
name: CSV::Parser
version: 0.1.4
auth: zef:tony-o
kind: Distribution · data format
summary: A CSV reader that works from an open file handle a line at a
  time — quoted fields, a header row that becomes the keys, and the
  separators and quote characters as options — for files too big to slurp.
status: full
suite: 5 files, green
tested: 2026-09-14
raku-land: https://raku.land/zef:tony-o/CSV::Parser
source: https://github.com/tony-o/perl6-csv-parser
---

## What it is for

Splitting a line on commas works until the first field that contains one.
CSV's quoting rules are simple to state and tedious to get right — quotes
around a field that has a comma or a newline in it, doubled quotes for a
literal one — and the files that need them are usually the large ones, an
export from a database or a spreadsheet, that you want to read row by row
rather than into memory at once. This distribution reads from a handle you
opened, hands back one row per call, and if the first row is a header it
uses those names as the keys.

## Rows from a handle

```raku name="rows"
use CSV::Parser;

my $file = $*TMPDIR.add("towns-{$*PID}.csv");
$file.spurt(qq:to/CSV/);
    name,population,motto
    Ashby,1200,"Small, but proud"
    Brill,950,"Says ""hello"""
    Cowes,10400,
    CSV
my $fh = $file.open;
my $csv = CSV::Parser.new(file_handle => $fh, contains_header_row => True);
until $fh.eof {
    my %row = $csv.get_line;
    next unless %row;
    say %row.keys.sort.map({ "$_=" ~ %row{$_} }).join(' | ');
}
$fh.close;
say $csv.headers.sort.map(*.value).join(',');
$file.unlink;
```

```output
motto=Small, but proud | name=Ashby | population=1200
motto=Says ""hello"" | name=Brill | population=950
motto= | name=Cowes | population=10400
name,population,motto
```

`get_line` reads the next record — a record, not a line, since a quoted
field may span several — and answers a hash. With `contains_header_row`
the keys are the header's names; without it they are the column positions
as strings, `"0"`, `"1"` and so on, which `headers` reports either way.
`field_separator`, `line_separator`, `field_operator` (the quote character)
and `escape_operator` turn it into a reader for tab-separated files or a
dialect with single quotes.

## The one thing to know

A doubled quote inside a quoted field is **left doubled**. The standard
way to write a literal `"` in CSV is `""`, and the second row above shows
what this parser does with it: `Says ""hello""` comes out with both pairs
intact, where every spreadsheet would show `Says "hello"`. The quoting is
otherwise honoured — the comma in *Small, but proud* did not split the
field — so this is an omission at one step of the unquoting, and one you
can repair after the fact with `.subst('""', '"', :g)` on the fields that
were quoted. Data that contains a lot of quotation marks is the case to
check before relying on it.
