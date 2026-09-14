#!/usr/bin/env rakupp
# Config — Layers
# https://raku.online/modules/config/#layers
#
# Install what it needs, then run it:
#     rakupp install Config
#     rakupp 01-layers.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Config;

my $defaults = Config.new({ name => 'app', port => 8080, db => { host => 'localhost', port => 5432 } },
                          :!from-env, :!from-xdg);
say $defaults.get('db.port');
say $defaults.get('db.user', 'nobody');
say $defaults.has('db.host'), ' ', $defaults.has('db.user');

my $site = $defaults.read({ port => 9090, db => { host => 'db.internal' } });
say $site.get('port'), ' ', $site.get('db.host'), ' ', $site.get('db.port');
say $defaults.get('port');
say $site.keys.sort.join(',');

# Output:
#     5432
#     nobody
#     True False
#     9090 db.internal 5432
#     8080
#     db.host,db.port,name,port
