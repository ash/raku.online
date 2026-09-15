#!/usr/bin/env rakupp
# Config::INI — Reading a file
# https://raku.online/modules/config-ini/#reading-a-file
#
# Install what it needs, then run it:
#     rakupp install Config::INI
#     rakupp 01-parse.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Config::INI;

my $conf = q:to/END/;
# a leading comment
; another comment style
timeout = 30
name=top level

[server]
host = example.test
port = 8080

[server.tls]
enabled = yes   ; trailing comment
END

my %got = Config::INI::parse($conf);
for %got.keys.sort -> $sect {
    say "[$sect]";
    for %got{$sect}.keys.sort -> $k {
        say sprintf('    %-14s = %s', $k.raku, %got{$sect}{$k}.raku);
    }
}

# Output:
#     [_]
#         "name"         = "top level"
#         "timeout"      = "30"
#     [server]
#         "host"         = "example.test"
#         "port"         = "8080"
#     [server.tls]
#         "enabled"      = "yes"
