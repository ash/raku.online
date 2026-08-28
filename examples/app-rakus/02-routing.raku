#!/usr/bin/env rakupp
# App::Rakus — Every refusal, by status
# https://raku.online/modules/app-rakus/#every-refusal-by-status
#
# Install what it needs, then run it:
#     rakupp install App::Rakus
#     rakupp 02-routing.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use App::Rakus;

my $root = $*TMPDIR.add("rakus-routes-$*PID");
mkdir $root;
mkdir $root.add('docs');

for ['POST', '/'], ['GET', '/../secret'], ['GET', '/docs'], ['GET', '/missing.png'] -> ($method, $target) {
    my ($status, $, $, $extra) = handle($method, $target, $root.Str);
    say "$status $method $target" ~ ($extra ?? "  {$extra.key}: {$extra.value}" !! '');
}

rmdir $root.add('docs');
rmdir $root;

# Output:
#     405 POST /
#     403 GET /../secret
#     301 GET /docs  Location: /docs/
#     404 GET /missing.png
