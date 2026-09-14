---
name: DBIish
version: 0.6.8
auth: zef:raku-community-modules
kind: Distribution · database
summary: One interface to SQLite, PostgreSQL, MySQL and Oracle — connect by
  driver name, send SQL with placeholders, and get rows back as lists or
  hashes with the database's types already turned into Raku's.
status: full
suite: 37 files, green
tested: 2026-09-14
license: BSD-2-Clause
depends: NativeHelpers::Blob, NativeLibs
raku-land: https://raku.land/zef:raku-community-modules/DBIish
source: https://github.com/raku-community-modules/DBIish
---

## What it is for

A program that keeps its data in a real database wants three things from a
library: a connection, a way to send SQL with the values kept *out* of the
string, and rows back in a shape it can loop over. That is the whole of this
distribution's surface, and it is the same surface whichever engine sits
behind it — `DBDish::SQLite`, `DBDish::Pg`, `DBDish::mysql` and
`DBDish::Oracle` are loaded by the name you hand to `connect`, and each one
binds the vendor's C client library through NativeCall.

SQLite is the one to start with, because it needs no server: the library
ships with macOS and with every Linux distribution's base packages, and a
database named `:memory:` lives exactly as long as your process does.

## Connect, insert, select

```raku name="sqlite"
use DBIish;

my $dbh = DBIish.connect('SQLite', database => ':memory:');
$dbh.execute('CREATE TABLE towns (name TEXT, population INTEGER, founded INTEGER)');

my $ins = $dbh.prepare('INSERT INTO towns (name, population, founded) VALUES (?, ?, ?)');
$ins.execute('Ashby', 1200, 1601);
$ins.execute('Brill', 950, 1354);
$ins.execute('Cowes', 10400, 1720);

my $sth = $dbh.execute('SELECT name, population FROM towns WHERE population > ? ORDER BY name', 1000);
for $sth.allrows(:array-of-hash) -> %row {
    say "%row<name>: %row<population>";
}
say $dbh.execute('SELECT sum(population) AS total FROM towns').row(:hash);
say $dbh.execute('SELECT name FROM towns WHERE founded < 1500').row;
$dbh.dispose;
```

```output
Ashby: 1200
Cowes: 10400
{total => 12550}
[Brill]
```

`prepare` once and `execute` many is the shape for a loop of inserts; for a
one-off query `$dbh.execute` prepares and runs in one call, and its
positional arguments fill the `?` placeholders in order. What comes back is a
statement handle, and the handle is where the rows live: `row` gives the next
one as an Array (or as a Hash with `:hash`), `allrows` the rest of them, and
`allrows(:array-of-hash)` the rest keyed by column name — which is the one to
reach for whenever the columns have names worth using.

The values already have their Raku types. An `INTEGER` column arrives as an
`Int`, `REAL` as a `Num`, `TEXT` as a `Str`, a `BLOB` as a `Buf`, and SQL's
`NULL` as an undefined `Any`:

```raku name="types"
use DBIish;

my $dbh = DBIish.connect('SQLite', database => ':memory:');
$dbh.execute('CREATE TABLE t (i INTEGER, r REAL, s TEXT, b BLOB, n INTEGER)');
$dbh.execute('INSERT INTO t VALUES (?, ?, ?, ?, NULL)', 7, 2.5, 'seven', Buf.new(1, 2, 3));

my @row = $dbh.execute('SELECT i, r, s, b, n FROM t').row;
say @row.map({ .defined ?? .^name !! 'NULL' }).join(', ');
say @row[3].list.join('-');

my $sth = $dbh.prepare('SELECT i FROM t WHERE i = ?');
say $sth.execute(7).row;
say $sth.execute(8).row.elems;
$dbh.dispose;
```

```output
Int, Num, Str, Buf, NULL
1-2-3
[7]
0
```

The last line is worth a look: a query that matches nothing answers `row` with
an **empty Array**, not with `Nil` or a failure, so the test for "no such row"
is `.elems` or an `if @row`, never `.defined`. A SQL error — a column that does
not exist, a constraint that fails — throws `X::DBDish::DBError`, with the
driver's own message in it.

## The one thing to know

The driver is loaded, and its C library opened, at `connect` — not at `use
DBIish`. A program compiles and starts happily on a machine without
`libsqlite3` or `libpq`, and fails at the first connection with a message from
NativeCall about a library it could not locate. Install the client library for
the databases you actually talk to, and expect the error at that line.

One more thing that follows from the dependency list. `NativeHelpers::Blob`
is a distribution Raku++ answers itself: `rakupp install DBIish` notes that it
is *provided by rakupp — using the bundled shadow* and writes nothing for it
into the store. A Rakudo sharing that store then cannot find it, and its
`DBDish::SQLite` refuses to compile. If both engines run on one machine, give
Rakudo its own copy with `zef install NativeHelpers::Blob`; after that the
examples above print the same thing under either.
