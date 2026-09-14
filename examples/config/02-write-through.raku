#!/usr/bin/env rakupp
# Config — The one thing to know
# https://raku.online/modules/config/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Config
#     rakupp 02-write-through.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Config;

my $c = Config.new({ port => 8080, db => { port => 5432 } }, :!from-env, :!from-xdg);
my $d = $c.set('port', 9090);
say $c.get('port'), ' ', $d.get('port');
my $e = $c.set('db.port', 1);
say $c.get('db.port'), ' ', $e.get('db.port');

# Output:
#     8080 9090
#     1 1
