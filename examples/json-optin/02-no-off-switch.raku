#!/usr/bin/env rakupp
# JSON::OptIn — The one thing to know
# https://raku.online/modules/json-optin/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install JSON::OptIn
#     rakupp 02-no-off-switch.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::OptIn;
use JSON::Class;
use JSON::Marshal;

class Record does JSON::Class {
    has Str $.keep is json;
    has Str $.no   is json(False);
    has Str $.bare;
}

for Record.^attributes -> $a {
    say $a.name, ' -> ', ($a ~~ JSON::OptIn::OptedInAttribute).Str;
}
say marshal(Record.new(keep => 'k', no => 'n', bare => 'b'),
            :!pretty, :sorted-keys, :opt-in);

# Output:
#     $!keep -> True
#     $!no -> True
#     $!bare -> False
#     {"keep":"k","no":"n"}
