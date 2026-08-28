#!/usr/bin/env rakupp
# App::Rakus — What a directory answers
# https://raku.online/modules/app-rakus/#what-a-directory-answers
#
# Install what it needs, then run it:
#     rakupp install App::Rakus
#     rakupp 04-listing.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use App::Rakus;

my $root = $*TMPDIR.add("rakus-list-$*PID");
mkdir $root;
$root.add('README.md').spurt('x' x 2048);
$root.add('.env').spurt('SECRET=1');
mkdir $root.add('assets');

my ($status, $type, $body, $) = handle('GET', '/', $root.Str);
my $page = $body.decode;
say $page.contains('README.md');
say $page.contains('2.0 KB');
say $page.contains('assets/');
say $page.contains('.env');

.unlink for $root.add('README.md'), $root.add('.env');
rmdir $root.add('assets');
rmdir $root;

# Output:
#     True
#     True
#     True
#     False
