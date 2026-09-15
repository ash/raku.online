#!/usr/bin/env rakupp
# Config::Clever — Three layers
# https://raku.online/modules/config-clever/#three-layers
#
# Install what it needs, then run it:
#     rakupp install Config::Clever
#     rakupp 01-layers.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Config::Clever;

my $dir = $*TMPDIR.add("cfg-{$*PID}");
$dir.mkdir;
$dir.add('default.json').spurt:
    '{ "app": "demo", "port": 8080, "debug": false }';
$dir.add('production.json').spurt:
    '{ "port": 80 }';
$dir.add('local-production.json').spurt:
    '{ "debug": true }';

sub show($label, %c) {
    say $label, ': ', %c.keys.sort.map({ "$_=" ~ %c{$_} }).join(' ');
}

show 'default   ', Config::Clever.load(:config-dir($dir.Str));
show 'production', Config::Clever.load(:environment<production>, :config-dir($dir.Str));
show 'staging   ', Config::Clever.load(:environment<staging>, :config-dir($dir.Str));

.unlink for $dir.dir;
$dir.rmdir;

# Output:
#     default   : app=demo debug=False port=8080
#     production: app=demo debug=True port=80
#     staging   : app=demo debug=False port=8080
