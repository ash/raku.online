#!/usr/bin/env rakupp
# JSON::Tiny — Subclass it: JSON with comments
# https://raku.online/modules/json-tiny/#subclass-it-json-with-comments
#
# Install what it needs, then run it:
#     rakupp install JSON::Tiny
#     rakupp 04-json-with-comments.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Tiny::Grammar;
use JSON::Tiny::Actions;

grammar JSON::WithComments is JSON::Tiny::Grammar {
    token ws { [ \s | '//' \N* ]* }
}

my $config = q:to/END/;
    {
        "port": 8080,       // where to listen
        "workers": 4,       // one per core
        "debug": false
    }
    END

my $m = JSON::WithComments.parse($config, :actions(JSON::Tiny::Actions.new));
my %conf = $m.made;
say %conf<port>;
say %conf<workers>;
say %conf<debug>;

# Output:
#     8080
#     4
#     False
