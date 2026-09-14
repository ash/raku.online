#!/usr/bin/env rakupp
# DBIish — Connect, insert, select
# https://raku.online/modules/dbiish/#connect-insert-select
#
# Install what it needs, then run it:
#     rakupp install DBIish
#     rakupp 01-sqlite.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     Ashby: 1200
#     Cowes: 10400
#     {total => 12550}
#     [Brill]
