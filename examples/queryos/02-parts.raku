#!/usr/bin/env rakupp
# QueryOS — Splitting a version string
# https://raku.online/modules/queryos/#splitting-a-version-string
#
# Install what it needs, then run it:
#     rakupp install QueryOS
#     rakupp 02-parts.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use QueryOS;

for '10.15.7', '22.6', '1.0.1.buster', 'bookworm', '' -> $v {
    my %p = os-version-parts($v);
    say sprintf('%-14s => %s', $v.raku,
        %p.keys.sort.map({ "$_={%p{$_}.raku}" }).join(' '));
}

# Output:
#     "10.15.7"      => version-name="" version-serial="10.15.7" vnum=10.157e0 vshort-name=""
#     "22.6"         => version-name="" version-serial="22.6" vnum=22.6e0 vshort-name=""
#     "1.0.1.buster" => version-name="buster" version-serial="1.0.1" vnum=1.01e0 vshort-name="buster"
#     "bookworm"     => version-name="bookworm" version-serial=0 vnum=0e0 vshort-name="bookworm"
#     ""             => version-name="" version-serial=0 vnum=0e0 vshort-name=""
