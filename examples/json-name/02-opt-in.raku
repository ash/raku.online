#!/usr/bin/env rakupp
# JSON::Name — The one thing to know
# https://raku.online/modules/json-name/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install JSON::Name
#     rakupp 02-opt-in.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Name;
use JSON::Class;
use JSON::Marshal;
use JSON::OptIn;

class Record does JSON::Class {
    has Str $.renamed is json-name('R');
    has Str $.ordinary;
}

for Record.^attributes -> $a {
    say $a.name, ' opted in: ', ($a ~~ JSON::OptIn::OptedInAttribute).Str;
}

my $r = Record.new(renamed => 'one', ordinary => 'two');
say marshal($r, :!pretty, :sorted-keys);
say marshal($r, :!pretty, :sorted-keys, :opt-in);

# Output:
#     $!renamed opted in: True
#     $!ordinary opted in: False
#     {"R":"one","ordinary":"two"}
#     {"R":"one"}
