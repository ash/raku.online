#!/usr/bin/env rakupp
# Hash::Merge — Merging, and who wins
# https://raku.online/modules/hash-merge/#merging-and-who-wins
#
# Install what it needs, then run it:
#     rakupp install Hash::Merge
#     rakupp 01-precedence.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Hash::Merge;

my %defaults = server => { host => 'localhost', port => 8080 }, debug => False;
my %config   = server => { port => 9000 },                      debug => True;

my %merged = merge-hash(%defaults, %config);
say %merged<server><host>, ' ', %merged<server><port>, ' ', %merged<debug>;

# Output:
#     localhost 9000 True
