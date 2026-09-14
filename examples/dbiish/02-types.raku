#!/usr/bin/env rakupp
# DBIish — Connect, insert, select
# https://raku.online/modules/dbiish/#connect-insert-select
#
# Install what it needs, then run it:
#     rakupp install DBIish
#     rakupp 02-types.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     Int, Num, Str, Buf, NULL
#     1-2-3
#     [7]
#     0
