#!/usr/bin/env rakupp
# JSON::Name — Renaming an attribute
# https://raku.online/modules/json-name/#renaming-an-attribute
#
# Install what it needs, then run it:
#     rakupp install JSON::Name
#     rakupp 01-rename.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Name;
use JSON::Class;
use JSON::Marshal;
use JSON::Unmarshal;

class Event does JSON::Class {
    has Str $.kind   is json-name('@type');
    has Int $.at     is json-name('666.evil.name');
    has Str $.plain;
}

my $e = Event.new(kind => 'ping', at => 42, plain => 'ordinary');
say marshal($e, :!pretty, :sorted-keys);

my $back = unmarshal('{"@type":"pong","666.evil.name":7,"plain":"p"}', Event);
say $back.kind, ' ', $back.at, ' ', $back.plain;

for Event.^attributes -> $a {
    say $a.name, ' -> ',
        ($a ~~ JSON::Name::NamedAttribute ?? $a.json-name !! '(same)');
}

# Output:
#     {"666.evil.name":42,"@type":"ping","plain":"ordinary"}
#     pong 7 p
#     $!kind -> @type
#     $!at -> 666.evil.name
#     $!plain -> (same)
