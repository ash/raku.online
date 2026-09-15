#!/usr/bin/env rakupp
# Config::Clever — The one thing to know
# https://raku.online/modules/config-clever/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Config::Clever
#     rakupp 02-nested.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Config::Clever;

my $dir = $*TMPDIR.add("cfgn-{$*PID}");
$dir.mkdir;
$dir.add('default.json').spurt:
    '{ "app": "demo", "db": { "host": "localhost", "port": 5432, "name": "devdb" } }';
$dir.add('production.json').spurt:
    '{ "db": { "host": "db.internal" } }';

my %base = Config::Clever.load(:config-dir($dir.Str));
say 'base db   : ', %base<db>.keys.sort.join(',');

my %prod = Config::Clever.load(:environment<production>, :config-dir($dir.Str));
say 'prod top  : ', %prod.keys.sort.join(',');
say 'prod db   : ', %prod<db>.keys.sort.join(',');

.unlink for $dir.dir;
$dir.rmdir;

# Output:
#     base db   : host,name,port
#     prod top  : app,db
#     prod db   : host
