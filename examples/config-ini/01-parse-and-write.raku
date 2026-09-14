#!/usr/bin/env rakupp
# Config::INI — Reading and writing
# https://raku.online/modules/config-ini/#reading-and-writing
#
# Install what it needs, then run it:
#     rakupp install Config::INI
#     rakupp 01-parse-and-write.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Config::INI;
use Config::INI::Writer;

my %ini = Config::INI::parse(q:to/INI/);
    name = demo
    [db]
    host = localhost
    port = 5432
    [db.replica]
    host = replica.internal
    INI
say %ini.keys.sort.join(',');
say %ini<_><name>, ' ', %ini<db><port>, ' ', %ini<db.replica><host>;
say %ini<db><port> + 1;
print Config::INI::Writer::dump({ name => 'demo', db => { host => 'localhost' } });

# Output:
#     _,db,db.replica
#     demo 5432 replica.internal
#     5433
#     name=demo
#     
#     [db]
#     host=localhost
