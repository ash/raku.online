#!/usr/bin/env rakupp
# JSON::OptIn — The mark
# https://raku.online/modules/json-optin/#the-mark
#
# Install what it needs, then run it:
#     rakupp install JSON::OptIn
#     rakupp 01-mark.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::OptIn;
use JSON::Class;
use JSON::Marshal;

class Account does JSON::Class {
    has Str $.user is json;
    has Int $.id   is json;
    has Str $.token;
}

for Account.^attributes -> $a {
    say $a.name, ' marked: ', ($a ~~ JSON::OptIn::OptedInAttribute).Str;
}

my $a = Account.new(user => 'ada', id => 7, token => 'secret');
say marshal($a, :!pretty, :sorted-keys);
say marshal($a, :!pretty, :sorted-keys, :opt-in);
say JSON::OptIn::OptedInAttribute.^methods(:local).elems;

# Output:
#     $!user marked: True
#     $!id marked: True
#     $!token marked: False
#     {"id":7,"token":"secret","user":"ada"}
#     {"id":7,"user":"ada"}
#     0
