#!/usr/bin/env rakupp
# Test::META — What it is for
# https://raku.online/modules/test-meta/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install Test::META
#     rakupp 01-meta-ok-passes.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Test;
use Test::META;

my $dist = $*TMPDIR.add("meta-demo-$*PID");
mkdir $dist;
mkdir $dist.add('lib');
$dist.add('lib/Greeter.rakumod').spurt('unit module Greeter;');
$dist.add('META6.json').spurt(q:to/END/);
    {
        "perl": "6.d",
        "name": "Greeter",
        "version": "0.0.1",
        "description": "Says hello",
        "auth": "zef:example",
        "authors": ["A. Author"],
        "license": "Artistic-2.0",
        "provides": { "Greeter": "lib/Greeter.rakumod" },
        "source-url": "https://github.com/example/Greeter.git"
    }
    END

my $*META-FILE = $dist.add('META6.json');
my $*DIST-DIR  = $dist;
plan 1;
meta-ok;

# One run printed:
#     1..1
#     # Subtest: Project META file is good
#         ok 1 - have a META file
#         ok 2 - META parses okay
#         ok 3 - have all required entries
#         ok 4 - 'provides' looks sane
#         ok 5 - Optional 'authors' and not 'author'
#         ok 6 - License is correct
#         ok 7 - name has a '::' rather than a hyphen (if this is intentional please pass :relaxed-name to meta-ok)
#         ok 8 - no 'v' in version strings (meta-version greater than 0)
#         ok 9 - version is present and doesn't have an asterisk
#         ok 10 - have usable source
#         1..10
#     ok 1 - Project META file is good
