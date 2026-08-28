#!/usr/bin/env rakupp
# App::Rakus — The routing is a pure function
# https://raku.online/modules/app-rakus/#the-routing-is-a-pure-function
#
# Install what it needs, then run it:
#     rakupp install App::Rakus
#     rakupp 01-tour.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use App::Rakus;

my $site = $*TMPDIR.add("rakus-page-$*PID");
mkdir $site;
$site.add('index.html').spurt("<h1>served</h1>\n");

my ($status, $type, $body, $) = handle('GET', '/', $site.Str);
say $status;
say $type;
print $body.decode;

$site.add('index.html').unlink;
rmdir $site;

# Output:
#     200
#     text/html; charset=utf-8
#     <h1>served</h1>
