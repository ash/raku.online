---
name: Fortune
version: 0.1.0
auth: zef:samy
kind: Distribution · text
summary: Read and write the Unix fortune file format — records separated by a
  delimiter line, with an optional binary index — and ship a Slackware
  database so it works out of the box.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: Pod::To::Text
raku-land: https://raku.land/zef:samy/Fortune
source: https://codeberg.org/1-1sam/raku-Fortune.git
---

## What it is for

The `fortune` file format is a plain-text file of records separated by a line
holding one delimiter character, usually `%`, optionally paired with a binary
`.dat` index recording the version, flags and offsets. It is the simplest
possible "pick a random quote" store, and it is still what `fortune(6)` reads.

This distribution reads and writes both halves, and bundles the Slackware
database so there is something to draw from immediately.

## Drawing a fortune

Every draw is random, so an example asserts **properties**:

```raku name="fortune"
use Fortune;

my $db = $Fortune::DATABASE;
say 'the bundled database exists : ', $db.e;
say 'records in it               : ', Fortune.new($db.absolute).fortune.elems;
say '';
my @picks = (^25).map({ fortune() });
say '25 draws:';
say '  every result is a Str or Nil : ', ?all(@picks.map({ $_ ~~ Str|Nil }));
say '  every result is in the store : ',
    ?all(@picks.grep(*.defined).map({ $_ (elem) Fortune.new($db.absolute).fortune.Set }));
say '';
say ':short  — all 160 characters or fewer : ',
    ?all((^25).map({ fortune(:short) }).grep(*.defined).map({ .chars <= 160 }));
say ':long   — all longer than 160         : ',
    ?all((^25).map({ fortune(:long) }).grep(*.defined).map({ .chars > 160 }));
```

```output
the bundled database exists : True
records in it               : 16942

25 draws:
  every result is a Str or Nil : True
  every result is in the store : True

:short  — all 160 characters or fewer : True
:long   — all longer than 160         : True
```

`$Fortune::DATABASE` is the bundled file as an `IO::Path`. `fortune()` with no
arguments draws from it.

## Your own database

```raku name="own"
use Fortune;

my $dir = $*TMPDIR.add("fortune-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }

my $db = $dir.add('sayings');
$db.spurt("alpha\n\%\nbeta\n\%\ngamma\n\%\n");

my $f = Fortune.new($db.absolute);
say 'records  : ', $f.fortune.map(*.raku).join(' ');
say 'delimiter: ', $f.delimit.raku;
say 'order    : ', $f.order;
say 'rot13    : ', $f.rot13;
say '';
strfile($db.absolute);
say 'strfile wrote the index : ', $dir.add('sayings.dat').e;
say '  size                  : ', $dir.add('sayings.dat').s, ' bytes';
say '';
my $g = Fortune.new($db.absolute);
say 'reading again picks the index up: version=', $g.version,
    ' delimit=', $g.delimit.raku;
```

```output
records  : "alpha" "beta" "gamma" ""
delimiter: "\%"
order    : FORTUNE_UNORDER
rot13    : False

strfile wrote the index : True
  size                  : 64 bytes

reading again picks the index up: version=1 delimit="\%"
```

Look at that record list. Three sayings in the file and four records back,
because the terminating delimiter leaves a trailing empty one — which is the
thing to know.

## The one thing to know

`fortune()` returns `Nil` at random from a perfectly good database.

A correctly written fortune file **ends** with a delimiter line. The reader
splits on `"$delimit\n"`, so that terminator yields a trailing empty string,
which becomes a record. `fortune()` then does `.pick || Nil` — and the empty
string is false.

```raku name="nil-trap"
use Fortune;

my $dir = $*TMPDIR.add("fortune2-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }

my $db = $dir.add('one');
# ONE saying, written exactly the way every fortune file is written
$db.spurt("the only saying\n\%\n");

say 'records found : ', Fortune.new($db.absolute).fortune.map(*.raku).join(' ');
say '';
my %seen;
%seen{ fortune($db.absolute).defined ?? 'a quote' !! 'Nil' }++ for ^400;
say '400 draws from a one-record database:';
say sprintf('  %-8s : %s', $_, %seen{$_} > 100 ?? 'hundreds' !! 'a few') for %seen.keys.sort;
say '';
my $bundled = Fortune.new($Fortune::DATABASE.absolute);
say 'the shipped database has ', $bundled.fortune.grep(* eq '').elems,
    ' empty records among ', $bundled.fortune.elems;
```

```output
records found : "the only saying" ""

400 draws from a one-record database:
  Nil      : hundreds
  a quote  : hundreds

the shipped database has 3 empty records among 16942
```

Half the draws from a one-record file return `Nil`. Even the bundled database
has three empty records, so `fortune()` with no arguments returns `Nil` about
once in every five or six thousand calls. `say fortune()` then prints
`(Nil)`, and `fortune().chars` dies.

Filter the empties, or guard every call with `//`.

## Where the two engines differ

Only in the exception type raised for a non-ASCII delimiter —
`X::TypeCheck::Binding::Parameter` on Raku++, `X::AdHoc` on Rakudo — and in
how a typed attribute reports its own name. Every record, every draw property
and the index round trip were identical.

Two naming traps, the same on both engines. `Fortune.new($db).fortune` is the
**whole list of records**, not one quote — the attribute accessor and the
exported sub share a name, so `$f.fortune.pick` is what you want and
`fortune($db)` is the sub. And the single-file `fortune` candidate accepts
`:equal`, `:all` and `:offensive` in its signature and never reads them; only
the directory candidate consults them, and there `:all` is defeated by a
second unconditional filter.
